<script>
export default {
  middleware: ['auth'],

  data() {
    return {
      recipe: null,
      loading: true,
      error: '',
      showConfirm: false,
      notes: '',
      logging: false,
      logError: '',
      logSuccess: false,
    }
  },

  async mounted() {
    await this.loadRecipe()
  },

  computed: {
    itemId() {
      return this.$route.query.item_id || this.recipe?.item_id || null
    },
    canLog() {
      return !!this.itemId && !this.logSuccess
    },
  },

  methods: {
    async loadRecipe() {
      this.loading = true
      this.error = ''
      try {
        this.recipe = await $fetch(`/api/recipes/${this.$route.params.id}`, {
          headers: getAuthHeaders(),
        })
      } catch {
        this.error = 'Recipe not found.'
      } finally {
        this.loading = false
      }
    },

    formatQuantity(qty) {
      // Drop trailing zeros: 1.50 → 1.5, 1.00 → 1
      return parseFloat(qty).toString()
    },

    async logBatch() {
      if (!this.itemId || this.logging) return
      this.logging = true
      this.logError = ''
      try {
        await $fetch('/api/batches', {
          method: 'POST',
          headers: getAuthHeaders(),
          body: {
            id: crypto.randomUUID(),
            item_id: this.itemId,
            recipe_id: this.recipe.id,
            yield_liters: this.recipe.base_yield_liters,
            notes: this.notes.trim() || null,
          },
        })
        this.logSuccess = true
        this.showConfirm = false
        setTimeout(() => this.$router.replace('/checklist'), 1000)
      } catch {
        this.logError = 'Could not log batch. Try again.'
      } finally {
        this.logging = false
      }
    },
  },
}
</script>

<template>
  <div class="recipe-page">

    <header class="recipe-page__header">
      <button class="recipe-page__back" @click="$router.replace('/checklist')">
        ← Prep list
      </button>
    </header>

    <div v-if="loading" class="recipe-page__state">Loading…</div>
    <div v-else-if="error" class="recipe-page__state recipe-page__state--error">{{ error }}</div>

    <template v-else-if="recipe">

      <h1 class="recipe-page__title">{{ recipe.name }}</h1>

      <div class="recipe-page__meta">
        <span class="recipe-page__yield">Makes {{ recipe.base_yield_liters }} L</span>
      </div>

      <p v-if="recipe.notes" class="recipe-page__notes">{{ recipe.notes }}</p>

      <!-- Ingredients -->
      <section class="recipe-section">
        <h2 class="recipe-section__heading">Ingredients</h2>
        <ul class="ingredient-list">
          <li
            v-for="ing in recipe.recipe_ingredients"
            :key="ing.id"
            class="ingredient-list__item"
          >
            <span class="ingredient-list__qty">{{ formatQuantity(ing.quantity) }} {{ ing.unit }}</span>
            <span class="ingredient-list__name">{{ ing.name }}</span>
          </li>
        </ul>
      </section>

      <!-- Steps -->
      <section class="recipe-section">
        <h2 class="recipe-section__heading">Steps</h2>
        <ol class="step-list">
          <li
            v-for="step in recipe.recipe_steps"
            :key="step.id"
            class="step-list__item"
          >
            {{ step.instruction }}
          </li>
        </ol>
      </section>

    </template>

    <!-- Log batch CTA (sticky footer) -->
    <div v-if="!loading && recipe" class="recipe-page__footer">
      <div v-if="logSuccess" class="recipe-page__success">Batch logged!</div>
      <button
        v-else-if="!showConfirm"
        class="recipe-page__log-btn"
        :disabled="!canLog"
        @click="showConfirm = true"
      >
        Log This Batch
      </button>

      <!-- Confirm drawer -->
      <div v-else class="log-confirm">
        <p class="log-confirm__label">Log 1 batch of {{ recipe.name }}?</p>
        <textarea
          v-model="notes"
          class="log-confirm__notes"
          placeholder="Notes (optional)"
          rows="2"
        />
        <p v-if="logError" class="log-confirm__error">{{ logError }}</p>
        <div class="log-confirm__actions">
          <button class="log-confirm__cancel" :disabled="logging" @click="showConfirm = false">
            Cancel
          </button>
          <button class="log-confirm__submit" :disabled="logging" @click="logBatch">
            {{ logging ? 'Logging…' : 'Confirm' }}
          </button>
        </div>
      </div>
    </div>

  </div>
</template>

<style lang="scss" scoped>
.recipe-page {
  padding: var(--space-4) var(--space-6);
  padding-top: max(var(--space-4), env(safe-area-inset-top));
  // Extra bottom padding for the sticky footer
  padding-bottom: calc(120px + env(safe-area-inset-bottom));

  &__header {
    margin-bottom: var(--space-4);
  }

  &__back {
    background: none;
    border: none;
    color: var(--color-accent);
    font-size: var(--text-base);
    padding: 0;
    cursor: pointer;
  }

  &__title {
    font-size: var(--text-2xl);
    font-weight: 700;
    line-height: 1.2;
    margin-bottom: var(--space-2);
  }

  &__meta {
    margin-bottom: var(--space-4);
  }

  &__yield {
    display: inline-block;
    background: var(--color-surface-alt);
    border-radius: var(--radius-full);
    font-size: var(--text-sm);
    color: var(--color-text-muted);
    padding: var(--space-1) var(--space-3);
  }

  &__notes {
    font-size: var(--text-sm);
    color: var(--color-text-muted);
    font-style: italic;
    margin-bottom: var(--space-6);
    line-height: 1.5;
  }

  &__state {
    text-align: center;
    color: var(--color-text-muted);
    padding: var(--space-12) 0;

    &--error {
      color: var(--color-danger);
    }
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

  &__log-btn {
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

    &:active {
      opacity: 0.85;
    }

    &:disabled {
      opacity: 0.4;
      cursor: default;
    }
  }

  &__success {
    text-align: center;
    color: var(--color-success);
    font-weight: 600;
    padding: var(--space-4);
  }
}

// ---- Recipe sections ----

.recipe-section {
  margin-bottom: var(--space-8);

  &__heading {
    font-size: var(--text-sm);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--color-text-muted);
    margin-bottom: var(--space-3);
  }
}

.ingredient-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);

  &__item {
    display: flex;
    gap: var(--space-3);
    padding: var(--space-3) var(--space-4);
    background: var(--color-surface);
    border-radius: var(--radius-base);
    font-size: var(--text-base);
  }

  &__qty {
    flex-shrink: 0;
    color: var(--color-accent);
    font-variant-numeric: tabular-nums;
    min-width: 80px;
  }

  &__name {
    color: var(--color-text);
  }
}

.step-list {
  list-style: none;
  counter-reset: step;
  display: flex;
  flex-direction: column;
  gap: var(--space-3);

  &__item {
    counter-increment: step;
    display: flex;
    gap: var(--space-3);
    font-size: var(--text-base);
    line-height: 1.5;

    &::before {
      content: counter(step);
      flex-shrink: 0;
      width: 24px;
      height: 24px;
      background: var(--color-surface-alt);
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: var(--text-xs);
      font-weight: 600;
      color: var(--color-text-muted);
      margin-top: 1px;
    }
  }
}

// ---- Log confirm drawer ----

.log-confirm {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);

  &__label {
    font-size: var(--text-base);
    font-weight: 500;
    text-align: center;
  }

  &__notes {
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-family: var(--font-body);
    font-size: var(--text-sm);
    padding: var(--space-3);
    resize: none;
    width: 100%;

    &::placeholder {
      color: var(--color-text-muted);
    }

    &:focus {
      outline: none;
      border-color: var(--color-accent);
    }
  }

  &__error {
    color: var(--color-danger);
    font-size: var(--text-sm);
    text-align: center;
  }

  &__actions {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: var(--space-2);
  }

  &__cancel {
    padding: var(--space-3);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-base);
    cursor: pointer;

    &:active:not(:disabled) {
      background: var(--color-surface-alt);
    }
  }

  &__submit {
    padding: var(--space-3);
    background: var(--color-accent);
    border: none;
    border-radius: var(--radius-base);
    color: #000;
    font-size: var(--text-base);
    font-weight: 600;
    cursor: pointer;
    transition: opacity var(--transition-fast);

    &:active:not(:disabled) {
      opacity: 0.85;
    }

    &:disabled {
      opacity: 0.5;
    }
  }
}
</style>
