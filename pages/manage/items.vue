<script setup>
definePageMeta({ middleware: ['auth', 'admin'] })
</script>

<script>
const CATEGORY_LABELS = {
  syrups_infusions: 'Syrups & Infusions',
  juices: 'Juices',
  garnishes: 'Garnishes',
}

export default {
  data() {
    return {
      items: [],
      loading: true,
      error: '',
      editingParId: null,
      editingParValue: '',
      savingId: null,
    }
  },

  async mounted() {
    await this.load()
  },

  computed: {
    grouped() {
      const groups = {}
      for (const item of this.items) {
        if (!groups[item.category]) groups[item.category] = []
        groups[item.category].push(item)
      }
      return Object.entries(groups).map(([key, items]) => ({
        key,
        label: CATEGORY_LABELS[key] ?? key,
        items,
      }))
    },
  },

  methods: {
    async load() {
      this.loading = true
      this.error = ''
      try {
        // Use admin endpoint for full item list (including inactive)
        const supabaseItems = await $fetch('/api/admin/items', { headers: getAuthHeaders() })
        this.items = supabaseItems
      } catch {
        // Fall back to staff items endpoint (active only)
        try {
          this.items = await $fetch('/api/items', { headers: getAuthHeaders() })
        } catch {
          this.error = 'Could not load items.'
        }
      } finally {
        this.loading = false
      }
    },

    async toggleActive(item) {
      if (this.savingId) return
      this.savingId = item.id
      try {
        await $fetch(`/api/admin/items/${item.id}`, {
          method: 'PATCH',
          headers: getAuthHeaders(),
          body: { is_active: !item.is_active },
        })
        item.is_active = !item.is_active
      } catch {
        this.error = 'Could not update item.'
      } finally {
        this.savingId = null
      }
    },

    startEditPar(item) {
      this.editingParId = item.id
      this.editingParValue = String(item.par_level)
      this.$nextTick(() => {
        const el = this.$el.querySelector(`[data-par-input="${item.id}"]`)
        if (el) el.focus()
      })
    },

    async savePar(item) {
      const val = parseFloat(this.editingParValue)
      if (isNaN(val) || val <= 0) { this.editingParId = null; return }
      if (val === item.par_level) { this.editingParId = null; return }
      try {
        await $fetch(`/api/admin/items/${item.id}`, {
          method: 'PATCH',
          headers: getAuthHeaders(),
          body: { par_level: val },
        })
        item.par_level = val
      } catch {
        this.error = 'Could not update par level.'
      } finally {
        this.editingParId = null
      }
    },
  },
}
</script>

<template>
  <div class="items-manage">
    <header class="admin-header">
      <button class="admin-header__back" @click="$router.replace('/manage')">← Manage</button>
      <h1 class="admin-header__title">Items</h1>
    </header>

    <div v-if="loading" class="admin-state">Loading…</div>
    <p v-else-if="error" class="admin-state admin-state--error">{{ error }}</p>

    <template v-else>
      <section v-for="group in grouped" :key="group.key" class="item-group">
        <h2 class="item-group__heading">{{ group.label }}</h2>
        <ul class="item-manage-list">
          <li
            v-for="item in group.items"
            :key="item.id"
            class="item-manage-card"
            :class="{ 'item-manage-card--inactive': !item.is_active }"
          >
            <div class="item-manage-card__main">
              <span class="item-manage-card__name">{{ item.name }}</span>

              <!-- Par level — tap to edit -->
              <span v-if="editingParId !== item.id" class="item-manage-card__par" @click="startEditPar(item)">
                Par: {{ item.par_level }}
              </span>
              <input
                v-else
                :data-par-input="item.id"
                v-model="editingParValue"
                class="item-manage-card__par-input"
                type="number"
                min="0.1"
                step="0.5"
                @blur="savePar(item)"
                @keydown.enter="savePar(item)"
                @keydown.escape="editingParId = null"
              />
            </div>

            <button
              class="item-manage-card__toggle"
              :class="{ 'item-manage-card__toggle--inactive': !item.is_active }"
              :disabled="savingId === item.id"
              @click="toggleActive(item)"
            >
              {{ item.is_active ? 'Active' : 'Inactive' }}
            </button>
          </li>
        </ul>
      </section>
    </template>
  </div>
</template>

<style lang="scss" scoped>
.items-manage {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  padding-bottom: calc(var(--nav-height) + var(--space-6) + env(safe-area-inset-bottom));
}

.item-group {
  margin-bottom: var(--space-6);

  &__heading {
    font-size: var(--text-sm);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--color-text-muted);
    margin-bottom: var(--space-3);
  }
}

.item-manage-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.item-manage-card {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  transition: opacity var(--transition-fast);

  &--inactive {
    opacity: 0.45;
  }

  &__main {
    flex: 1;
    min-width: 0;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  &__name {
    font-size: var(--text-base);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  &__par {
    font-size: var(--text-xs);
    color: var(--color-text-muted);
    cursor: pointer;
    text-decoration: underline dotted;
  }

  &__par-input {
    font-size: var(--text-xs);
    background: var(--color-bg);
    border: 1px solid var(--color-accent);
    border-radius: var(--radius-sm);
    color: var(--color-text);
    padding: 1px var(--space-2);
    width: 60px;

    &:focus { outline: none; }
  }

  &__toggle {
    flex-shrink: 0;
    padding: var(--space-2) var(--space-3);
    border-radius: var(--radius-base);
    font-size: var(--text-xs);
    font-weight: 600;
    cursor: pointer;
    transition: all var(--transition-fast);
    background: var(--color-success);
    border: none;
    color: #000;

    &--inactive {
      background: var(--color-surface-alt);
      border: 1px solid var(--color-border);
      color: var(--color-text-muted);
    }

    &:disabled { opacity: 0.5; }
  }
}
</style>
