<script>
export default {
  middleware: ['auth'],

  data() {
    return {
      items: [],
      loading: true,
      error: '',
      loggingItemId: null,
    }
  },

  async mounted() {
    await this.load()
  },

  computed: {
    hasSession() {
      return this.items.some(i => i.stock_quantity !== null)
    },

    pending() {
      if (this.hasSession) {
        return this.items.filter(i => i.needs_prep && !i.batched_today)
      }
      return this.items.filter(i => !i.batched_today)
    },

    done() {
      return this.items.filter(i => i.batched_today)
    },

    allDone() {
      if (this.items.length === 0) return false
      return this.pending.length === 0
    },

    completionText() {
      const count = this.done.length
      if (count === 0 && this.hasSession) return 'All items at par — nothing to prep today'
      return `All done — ${count} batch${count !== 1 ? 'es' : ''} logged today`
    },

    staffName() {
      return getSession()?.name ?? ''
    },
  },

  methods: {
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.items = await $fetch('/api/items', { headers: getAuthHeaders() })
      } catch {
        this.error = 'Could not load prep list.'
      } finally {
        this.loading = false
      }
    },

    openRecipe(item) {
      this.$router.push(`/recipes/${item.recipe.id}?item_id=${item.id}&from=checklist`)
    },

    async markDone(item) {
      if (this.loggingItemId) return
      this.loggingItemId = item.id
      try {
        await $fetch('/api/batches', {
          method: 'POST',
          headers: getAuthHeaders(),
          body: {
            id: crypto.randomUUID(),
            item_id: item.id,
            yield_liters: 1,
          },
        })
        item.batched_today = true
      } catch {
        this.error = 'Could not log batch. Try again.'
      } finally {
        this.loggingItemId = null
      }
    },

    formatDeficit(item) {
      if (!item.deficit || item.deficit <= 0) return ''
      const val = parseFloat(item.deficit)
      const nice = val % 1 === 0 ? val : val.toFixed(1)
      return `${nice} ${item.stock_unit} short`
    },
  },
}
</script>

<template>
  <div class="checklist-page">

    <header class="checklist-page__header">
      <div>
        <h1 class="checklist-page__title">Today's Prep</h1>
        <ClientOnly><p v-if="staffName" class="checklist-page__who">{{ staffName }}</p></ClientOnly>
      </div>
      <button class="checklist-page__refresh" :disabled="loading" aria-label="Refresh" @click="load">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path d="M4 4v5h5M20 20v-5h-5" />
          <path d="M4.93 15A8 8 0 1020 12" />
        </svg>
      </button>
    </header>

    <div v-if="loading" class="checklist-page__state">Loading…</div>
    <div v-else-if="error" class="checklist-page__state checklist-page__state--error">{{ error }}</div>

    <template v-else>

      <!-- Stock check prompt (no session today) -->
      <div v-if="!hasSession && !allDone" class="stock-banner">
        <div class="stock-banner__body">
          <span class="stock-banner__text">Check stock first for a smarter prep list.</span>
          <NuxtLink to="/stock-check" class="stock-banner__link">Check Stock →</NuxtLink>
        </div>
      </div>

      <!-- All done banner -->
      <div v-if="allDone" class="checklist-banner">
        {{ completionText }}
      </div>

      <!-- Pending items -->
      <section v-if="pending.length" class="checklist-section">
        <h2 class="checklist-section__heading">
          Needs prep <span class="checklist-section__count">{{ pending.length }}</span>
        </h2>
        <ul class="item-list">
          <li v-for="item in pending" :key="item.id" class="item-card item-card--pending">

            <button v-if="item.recipe" class="item-card__body" @click="openRecipe(item)">
              <span class="item-card__status item-card__status--pending" aria-label="Needs prep" />
              <span class="item-card__info">
                <span class="item-card__name">{{ item.name }}</span>
                <span v-if="formatDeficit(item)" class="item-card__deficit">{{ formatDeficit(item) }}</span>
              </span>
              <svg class="item-card__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
                <path d="M9 18l6-6-6-6" />
              </svg>
            </button>

            <div v-else class="item-card__body item-card__body--no-recipe">
              <span class="item-card__status item-card__status--pending" aria-label="Needs prep" />
              <span class="item-card__info">
                <span class="item-card__name">{{ item.name }}</span>
                <span v-if="formatDeficit(item)" class="item-card__deficit">{{ formatDeficit(item) }}</span>
              </span>
              <button
                class="item-card__done-btn"
                :disabled="loggingItemId === item.id"
                @click="markDone(item)"
              >
                {{ loggingItemId === item.id ? '…' : 'Done' }}
              </button>
            </div>

          </li>
        </ul>
      </section>

      <!-- Done items -->
      <section v-if="done.length" class="checklist-section checklist-section--done">
        <h2 class="checklist-section__heading">
          Done <span class="checklist-section__count">{{ done.length }}</span>
        </h2>
        <ul class="item-list item-list--done">
          <li v-for="item in done" :key="item.id" class="item-card item-card--done">
            <div class="item-card__body">
              <span class="item-card__status item-card__status--done" aria-label="Done" />
              <span class="item-card__name">{{ item.name }}</span>
            </div>
          </li>
        </ul>
      </section>

    </template>

  </div>
</template>

<style lang="scss" scoped>
.checklist-page {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));

  &__header {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    margin-bottom: var(--space-6);
  }

  &__title {
    font-size: var(--text-2xl);
    font-weight: 600;
  }

  &__who {
    color: var(--color-text-muted);
    font-size: var(--text-sm);
    margin-top: var(--space-1);
  }

  &__refresh {
    background: none;
    border: none;
    color: var(--color-text-muted);
    cursor: pointer;
    padding: var(--space-2);
    margin-top: -2px;

    svg { width: 20px; height: 20px; }
    &:disabled { opacity: 0.4; }
  }

  &__state {
    text-align: center;
    color: var(--color-text-muted);
    padding: var(--space-12) 0;

    &--error { color: var(--color-danger); }
  }
}

// Stock check prompt banner
.stock-banner {
  margin-bottom: var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-left: 3px solid var(--color-accent);
  border-radius: var(--radius-base);
  padding: var(--space-3) var(--space-4);

  &__body {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-3);
  }

  &__text {
    font-size: var(--text-sm);
    color: var(--color-text-muted);
  }

  &__link {
    flex-shrink: 0;
    font-size: var(--text-sm);
    font-weight: 600;
    color: var(--color-accent);
    text-decoration: none;
  }
}

.checklist-banner {
  background: var(--color-success);
  color: #000;
  text-align: center;
  padding: var(--space-4);
  border-radius: var(--radius-base);
  font-weight: 600;
  margin-bottom: var(--space-6);
}

.checklist-section {
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

  &--done { opacity: 0.55; }
}

.item-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
}

.item-card {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  overflow: hidden;

  &__body {
    display: flex;
    align-items: center;
    gap: var(--space-3);
    width: 100%;
    padding: var(--space-4);
    background: none;
    border: none;
    color: var(--color-text);
    text-align: left;
    cursor: pointer;
    -webkit-tap-highlight-color: transparent;

    &:active { background: var(--color-surface-alt); }

    &--no-recipe {
      cursor: default;
      &:active { background: none; }
    }
  }

  &__status {
    flex-shrink: 0;
    width: 18px;
    height: 18px;
    border-radius: 50%;

    &--pending { border: 2px solid var(--color-border); }

    &--done {
      background: var(--color-success);
      border: 2px solid var(--color-success);
      position: relative;

      &::after {
        content: '';
        position: absolute;
        inset: 3px 2px 4px 4px;
        border-left: 2px solid #000;
        border-bottom: 2px solid #000;
        transform: rotate(-45deg) translateY(-1px);
      }
    }
  }

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

  &__deficit {
    font-size: var(--text-xs);
    color: var(--color-warning);
  }

  &__arrow {
    flex-shrink: 0;
    width: 18px;
    height: 18px;
    color: var(--color-text-muted);
  }

  &__done-btn {
    flex-shrink: 0;
    padding: var(--space-2) var(--space-4);
    background: var(--color-surface-alt);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-sm);
    cursor: pointer;
    min-width: 56px;
    text-align: center;

    &:active:not(:disabled) {
      background: var(--color-accent);
      color: #000;
      border-color: var(--color-accent);
    }

    &:disabled { opacity: 0.5; }
  }
}
</style>
