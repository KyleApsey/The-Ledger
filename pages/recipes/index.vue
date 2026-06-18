<script setup>
definePageMeta({ middleware: ['auth'] })
</script>

<script>
const CATEGORY_LABELS = {
  syrups_infusions: 'Syrups & Infusions',
  juices: 'Juices',
  garnishes: 'Garnishes',
}
const CATEGORY_ORDER = ['syrups_infusions', 'juices', 'garnishes']

export default {
  data() {
    return {
      recipes: [],
      loading: true,
      error: '',
      search: '',
    }
  },

  async mounted() {
    await this.load()
  },

  computed: {
    filtered() {
      const q = this.search.toLowerCase().trim()
      if (!q) return this.recipes
      return this.recipes.filter(r => r.name.toLowerCase().includes(q))
    },

    grouped() {
      const groups = {}
      for (const r of this.filtered) {
        const cat = r.items?.category ?? 'other'
        if (!groups[cat]) groups[cat] = []
        groups[cat].push(r)
      }
      return Object.entries(groups)
        .sort(([a], [b]) => {
          const ai = CATEGORY_ORDER.indexOf(a)
          const bi = CATEGORY_ORDER.indexOf(b)
          return (ai === -1 ? 99 : ai) - (bi === -1 ? 99 : bi)
        })
        .map(([key, recipes]) => ({
          key,
          label: CATEGORY_LABELS[key] ?? 'Other',
          recipes,
        }))
    },
  },

  methods: {
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.recipes = await $fetch('/api/recipes', { headers: getAuthHeaders() })
      } catch {
        this.error = 'Could not load recipes.'
      } finally {
        this.loading = false
      }
    },
  },
}
</script>

<template>
  <div class="recipes-browse">

    <header class="recipes-browse__header">
      <h1 class="recipes-browse__title">Recipes</h1>
      <div class="recipes-browse__search-wrap">
        <input
          v-model="search"
          class="recipes-browse__search"
          type="search"
          placeholder="Search recipes…"
          autocomplete="off"
        />
      </div>
    </header>

    <div v-if="loading" class="admin-state">Loading…</div>
    <p v-else-if="error" class="admin-state admin-state--error">{{ error }}</p>
    <p v-else-if="filtered.length === 0" class="admin-state">No recipes found.</p>

    <template v-else>
      <section v-for="group in grouped" :key="group.key" class="recipe-browse-section">
        <h2 class="recipe-browse-section__heading">{{ group.label }}</h2>
        <ul class="recipe-browse-list">
          <li v-for="recipe in group.recipes" :key="recipe.id">
            <NuxtLink :to="`/recipes/${recipe.id}`" class="recipe-browse-card">
              <span class="recipe-browse-card__name">{{ recipe.name }}</span>
              <span class="recipe-browse-card__yield">{{ recipe.base_yield_liters }} L</span>
              <svg class="recipe-browse-card__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <path d="M9 18l6-6-6-6" />
              </svg>
            </NuxtLink>
          </li>
        </ul>
      </section>
    </template>

  </div>
</template>

<style lang="scss" scoped>
.recipes-browse {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  padding-bottom: calc(var(--nav-height) + var(--space-6) + env(safe-area-inset-bottom));

  &__header {
    margin-bottom: var(--space-6);
  }

  &__title {
    font-size: var(--text-2xl);
    font-weight: 600;
    margin-bottom: var(--space-4);
  }

  &__search-wrap {
    position: relative;
  }

  &__search {
    width: 100%;
    padding: var(--space-3) var(--space-4);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-base);
    font-family: var(--font-body);

    &::placeholder { color: var(--color-text-muted); }
    &:focus {
      outline: none;
      border-color: var(--color-accent);
    }

    // Remove default search clear button style on Safari
    &::-webkit-search-cancel-button { -webkit-appearance: none; }
  }
}

.recipe-browse-section {
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

.recipe-browse-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.recipe-browse-card {
  display: flex;
  align-items: center;
  gap: var(--space-3);
  padding: var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  text-decoration: none;
  color: var(--color-text);
  -webkit-tap-highlight-color: transparent;

  &:active {
    background: var(--color-surface-alt);
  }

  &__name {
    flex: 1;
    font-size: var(--text-base);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  &__yield {
    flex-shrink: 0;
    font-size: var(--text-xs);
    color: var(--color-text-muted);
    background: var(--color-surface-alt);
    border-radius: var(--radius-full);
    padding: 2px var(--space-2);
  }

  &__arrow {
    flex-shrink: 0;
    width: 18px;
    height: 18px;
    color: var(--color-text-muted);
  }
}
</style>
