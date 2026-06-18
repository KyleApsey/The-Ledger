<script setup>
definePageMeta({ middleware: ['auth'] })
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
      quantities: {},  // item.id → string value for the input
      loading: true,
      saving: false,
      error: '',
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
        this.items = await $fetch('/api/prep/items-for-check', { headers: getAuthHeaders() })
        this.quantities = Object.fromEntries(this.items.map(i => [i.id, '0']))
      } catch {
        this.error = 'Could not load items.'
      } finally {
        this.loading = false
      }
    },

    parLabel(item) {
      return `par: ${item.par_level} ${item.stock_unit}`
    },

    async save() {
      if (this.saving) return
      this.saving = true
      this.error = ''
      try {
        const entries = this.items.map(item => ({
          item_id: item.id,
          stock_quantity: Math.max(0, parseFloat(this.quantities[item.id]) || 0),
        }))
        await $fetch('/api/prep/session', {
          method: 'POST',
          headers: getAuthHeaders(),
          body: { entries },
        })
        this.$router.replace('/checklist')
      } catch {
        this.error = 'Could not save stock check. Try again.'
        this.saving = false
      }
    },
  },
}
</script>

<template>
  <div class="stock-check">

    <header class="admin-header">
      <button class="admin-header__back" @click="$router.replace('/checklist')">← Prep list</button>
      <h1 class="admin-header__title">Stock Check</h1>
      <p class="stock-check__subtitle">Enter how much you have of each item.</p>
    </header>

    <div v-if="loading" class="admin-state">Loading…</div>
    <p v-else-if="error && items.length === 0" class="admin-state admin-state--error">{{ error }}</p>

    <template v-else>
      <section v-for="group in grouped" :key="group.key" class="stock-group">
        <h2 class="stock-group__heading">{{ group.label }}</h2>
        <ul class="stock-list">
          <li v-for="item in group.items" :key="item.id" class="stock-item">
            <div class="stock-item__info">
              <span class="stock-item__name">{{ item.name }}</span>
              <span class="stock-item__par">{{ parLabel(item) }}</span>
            </div>
            <div class="stock-item__input-wrap">
              <input
                v-model="quantities[item.id]"
                class="stock-item__input"
                type="number"
                min="0"
                step="0.5"
                inputmode="decimal"
              />
              <span class="stock-item__unit">{{ item.stock_unit }}</span>
            </div>
          </li>
        </ul>
      </section>

      <p v-if="error" class="stock-check__error">{{ error }}</p>
    </template>

    <!-- Sticky footer -->
    <div v-if="!loading && items.length > 0" class="stock-check__footer">
      <button class="stock-check__save-btn" :disabled="saving" @click="save">
        {{ saving ? 'Saving…' : 'Save & See Prep List' }}
      </button>
    </div>

  </div>
</template>

<style lang="scss" scoped>
.stock-check {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  padding-bottom: calc(80px + env(safe-area-inset-bottom));

  &__subtitle {
    color: var(--color-text-muted);
    font-size: var(--text-sm);
    margin-top: var(--space-1);
  }

  &__error {
    color: var(--color-danger);
    font-size: var(--text-sm);
    text-align: center;
    margin-top: var(--space-4);
  }

  &__footer {
    position: fixed;
    bottom: 0;
    left: 0;
    right: 0;
    padding: var(--space-4) var(--space-6);
    padding-bottom: calc(var(--space-4) + env(safe-area-inset-bottom));
    background: var(--color-bg);
    border-top: 1px solid var(--color-border);
  }

  &__save-btn {
    width: 100%;
    padding: var(--space-4);
    background: var(--color-accent);
    border: none;
    border-radius: var(--radius-base);
    color: #000;
    font-size: var(--text-lg);
    font-weight: 600;
    cursor: pointer;
    transition: opacity var(--transition-fast);

    &:active { opacity: 0.85; }
    &:disabled { opacity: 0.5; cursor: default; }
  }
}

.stock-group {
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

.stock-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.stock-item {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);

  &__info {
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
  }

  &__input-wrap {
    display: flex;
    align-items: center;
    gap: var(--space-1);
    flex-shrink: 0;
  }

  &__input {
    width: 64px;
    padding: var(--space-2) var(--space-2);
    background: var(--color-bg);
    border: 1px solid var(--color-accent);
    border-radius: var(--radius-sm);
    color: var(--color-text);
    font-size: var(--text-sm);
    text-align: right;

    &:focus {
      outline: none;
      border-color: var(--color-accent);
    }

    // Remove number spinners
    &::-webkit-inner-spin-button,
    &::-webkit-outer-spin-button { -webkit-appearance: none; }
    -moz-appearance: textfield;
  }

  &__unit {
    font-size: var(--text-xs);
    color: var(--color-text-muted);
    min-width: 40px;
  }
}
</style>
