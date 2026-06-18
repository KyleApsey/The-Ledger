<script setup>
definePageMeta({ middleware: ['auth', 'admin'] })
</script>

<script>
export default {
  data() {
    return {
      recipes: [],
      loading: true,
      error: '',
      actionId: null, // recipe being acted on (archive/duplicate)
    }
  },

  async mounted() {
    await this.load()
  },

  computed: {
    active() {
      return this.recipes.filter(r => !r.archived_at)
    },
    archived() {
      return this.recipes.filter(r => r.archived_at)
    },
  },

  methods: {
    async load() {
      this.loading = true
      this.error = ''
      try {
        const supabase_res = await $fetch('/api/admin/recipes', { headers: getAuthHeaders() })
        this.recipes = supabase_res
      } catch {
        this.error = 'Could not load recipes.'
      } finally {
        this.loading = false
      }
    },

    async toggleArchive(recipe) {
      if (this.actionId) return
      this.actionId = recipe.id
      try {
        await $fetch(`/api/admin/recipes/${recipe.id}`, {
          method: 'PATCH',
          headers: getAuthHeaders(),
          body: { archive: !recipe.archived_at },
        })
        recipe.archived_at = recipe.archived_at ? null : new Date().toISOString()
      } catch {
        this.error = 'Could not update recipe.'
      } finally {
        this.actionId = null
      }
    },

    async duplicate(recipe) {
      if (this.actionId) return
      this.actionId = recipe.id
      try {
        const { id: newId } = await $fetch(`/api/admin/recipes/${recipe.id}/duplicate`, {
          method: 'POST',
          headers: getAuthHeaders(),
        })
        // Reload to show the copy
        await this.load()
        this.$router.push(`/recipes/${newId}`)
      } catch {
        this.error = 'Could not duplicate recipe.'
        this.actionId = null
      }
    },
  },
}
</script>

<template>
  <div class="recipes-manage">
    <header class="admin-header recipes-manage__header">
      <button class="admin-header__back" @click="$router.replace('/manage')">← Manage</button>
      <h1 class="admin-header__title">Recipes</h1>
      <NuxtLink to="/manage/recipes/new" class="recipes-manage__new-btn">+ New</NuxtLink>
    </header>

    <div v-if="loading" class="admin-state">Loading…</div>
    <p v-else-if="error" class="admin-state admin-state--error">{{ error }}</p>

    <template v-else>
      <section class="recipe-manage-section">
        <h2 class="recipe-manage-section__heading">
          Active <span class="recipe-manage-section__count">{{ active.length }}</span>
        </h2>
        <ul class="recipe-manage-list">
          <li v-for="recipe in active" :key="recipe.id" class="recipe-manage-card">
            <NuxtLink :to="`/recipes/${recipe.id}`" class="recipe-manage-card__name">
              {{ recipe.name }}
            </NuxtLink>
            <div class="recipe-manage-card__actions">
              <button
                class="recipe-manage-card__btn"
                :disabled="actionId === recipe.id"
                @click="duplicate(recipe)"
              >
                Copy
              </button>
              <button
                class="recipe-manage-card__btn recipe-manage-card__btn--danger"
                :disabled="actionId === recipe.id"
                @click="toggleArchive(recipe)"
              >
                Archive
              </button>
            </div>
          </li>
        </ul>
      </section>

      <section v-if="archived.length" class="recipe-manage-section recipe-manage-section--archived">
        <h2 class="recipe-manage-section__heading">
          Archived <span class="recipe-manage-section__count">{{ archived.length }}</span>
        </h2>
        <ul class="recipe-manage-list">
          <li v-for="recipe in archived" :key="recipe.id" class="recipe-manage-card recipe-manage-card--archived">
            <span class="recipe-manage-card__name">{{ recipe.name }}</span>
            <button
              class="recipe-manage-card__btn"
              :disabled="actionId === recipe.id"
              @click="toggleArchive(recipe)"
            >
              Restore
            </button>
          </li>
        </ul>
      </section>
    </template>
  </div>
</template>

<style lang="scss" scoped>
.recipes-manage {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  padding-bottom: calc(var(--nav-height) + var(--space-6) + env(safe-area-inset-bottom));

  &__header {
    display: flex;
    align-items: center;
  }

  &__new-btn {
    margin-left: auto;
    padding: var(--space-2) var(--space-3);
    background: var(--color-accent);
    border-radius: var(--radius-base);
    color: #000;
    font-size: var(--text-sm);
    font-weight: 600;
    text-decoration: none;
    white-space: nowrap;
    -webkit-tap-highlight-color: transparent;

    &:active { opacity: 0.85; }
  }
}

.recipe-manage-section {
  margin-bottom: var(--space-8);

  &__heading {
    font-size: var(--text-sm);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--color-text-muted);
    margin-bottom: var(--space-3);
    display: flex;
    align-items: center;
    gap: var(--space-2);
  }

  &__count {
    background: var(--color-surface-alt);
    border-radius: var(--radius-full);
    font-size: var(--text-xs);
    padding: 1px 7px;
    color: var(--color-text);
    letter-spacing: 0;
  }

  &--archived {
    opacity: 0.6;
  }
}

.recipe-manage-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.recipe-manage-card {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-3) var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);

  &__name {
    flex: 1;
    font-size: var(--text-base);
    color: var(--color-text);
    text-decoration: none;
    min-width: 0;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  &__actions {
    display: flex;
    gap: var(--space-2);
    flex-shrink: 0;
  }

  &__btn {
    padding: var(--space-2) var(--space-3);
    background: var(--color-surface-alt);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-xs);
    cursor: pointer;

    &:disabled { opacity: 0.5; }

    &--danger {
      color: var(--color-danger);
      border-color: var(--color-danger);
    }
  }
}
</style>
