<script>
export default {
  middleware: ['auth'],

  data() {
    return {
      recipe: null,
      loading: true,
      error: '',
      // Yield scaling
      scaleFactor: 1,
      // Batch logging
      showConfirm: false,
      notes: '',
      logging: false,
      logError: '',
      logSuccess: false,
      // Waste logging
      showWasteDrawer: false,
      wasteQty: '',
      wasteReason: '',
      loggingWaste: false,
      wasteError: '',
      wasteLogged: false,
    }
  },

  async mounted() {
    await this.loadRecipe()
  },

  computed: {
    itemId() {
      return this.$route.query.item_id || this.recipe?.item_id || null
    },

    backPath() {
      return this.$route.query.from === 'checklist' ? '/checklist' : '/recipes'
    },

    backLabel() {
      return this.$route.query.from === 'checklist' ? '← Prep list' : '← Recipes'
    },

    canLog() {
      return !!this.itemId && !this.logSuccess && !this.wasteLogged
    },

    scaledYield() {
      if (!this.recipe) return 0
      return Math.round(this.recipe.base_yield_liters * this.scaleFactor * 100) / 100
    },

    scaledIngredients() {
      if (!this.recipe) return []
      return this.recipe.recipe_ingredients.map(ing => ({
        ...ing,
        displayQty: this.formatQuantity(ing.quantity * this.scaleFactor),
      }))
    },

    lastBatchLabel() {
      const b = this.recipe?.last_batch
      if (!b) return null
      const scale = b.scale_factor && b.scale_factor !== 1 ? `${b.scale_factor}× ` : ''
      const date = new Date(b.logged_at).toLocaleDateString('en-US', {
        month: 'short', day: 'numeric', timeZone: 'America/Detroit',
      })
      const who = b.staff?.name ?? 'someone'
      return `${scale}on ${date} by ${who}`
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
      const n = parseFloat(qty)
      if (n === Math.floor(n)) return String(Math.floor(n))
      return parseFloat(n.toFixed(3)).toString()
    },

    stepScale(delta) {
      const next = Math.round((this.scaleFactor + delta) * 10) / 10
      if (next < 0.5) return
      this.scaleFactor = next
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
            yield_liters: this.scaledYield,
            scale_factor: this.scaleFactor,
            notes: this.notes.trim() || null,
          },
        })
        this.logSuccess = true
        this.showConfirm = false
      } catch {
        this.logError = 'Could not log batch. Try again.'
      } finally {
        this.logging = false
      }
    },

    async logWaste() {
      if (this.loggingWaste) return
      const qty = parseFloat(this.wasteQty)
      if (isNaN(qty) || qty <= 0) return
      this.loggingWaste = true
      this.wasteError = ''
      try {
        await $fetch('/api/waste', {
          method: 'POST',
          headers: getAuthHeaders(),
          body: {
            id: crypto.randomUUID(),
            item_id: this.itemId,
            quantity: qty,
            unit: 'liters',
            reason: this.wasteReason.trim() || null,
          },
        })
        this.wasteLogged = true
        this.showWasteDrawer = false
        setTimeout(() => this.$router.replace(this.backPath), 1200)
      } catch {
        this.wasteError = 'Could not log waste. Try again.'
      } finally {
        this.loggingWaste = false
      }
    },
  },
}
</script>

<template>
  <div class="recipe-page">

    <header class="recipe-page__header">
      <button class="recipe-page__back" @click="$router.replace(backPath)">
        {{ backLabel }}
      </button>
    </header>

    <div v-if="loading" class="recipe-page__state">Loading…</div>
    <div v-else-if="error" class="recipe-page__state recipe-page__state--error">{{ error }}</div>

    <template v-else-if="recipe">

      <h1 class="recipe-page__title">{{ recipe.name }}</h1>

      <!-- Yield history (E3) -->
      <p v-if="lastBatchLabel" class="recipe-page__last-batch">Last made: {{ lastBatchLabel }}</p>

      <!-- Yield scaling control -->
      <div class="recipe-page__yield-row">
        <span class="recipe-page__yield-label">Makes</span>
        <button
          class="recipe-page__step-btn"
          :disabled="scaleFactor <= 0.5"
          aria-label="Decrease yield"
          @click="stepScale(-0.5)"
        >−</button>
        <span class="recipe-page__scale-badge">{{ scaleFactor }}×</span>
        <button
          class="recipe-page__step-btn"
          aria-label="Increase yield"
          @click="stepScale(0.5)"
        >+</button>
        <span class="recipe-page__yield-total">{{ scaledYield }} L</span>
      </div>

      <p v-if="recipe.notes" class="recipe-page__notes">{{ recipe.notes }}</p>

      <!-- Ingredients (scaled) -->
      <section class="recipe-section">
        <h2 class="recipe-section__heading">Ingredients</h2>
        <ul class="ingredient-list">
          <li
            v-for="ing in scaledIngredients"
            :key="ing.id"
            class="ingredient-list__item"
          >
            <span class="ingredient-list__qty">{{ ing.displayQty }} {{ ing.unit }}</span>
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

    <!-- Log batch footer (sticky) -->
    <div v-if="!loading && recipe" class="recipe-page__footer">

      <!-- Waste logged success -->
      <div v-if="wasteLogged" class="recipe-page__success">Waste logged. Heading back…</div>

      <!-- Batch logged success + options -->
      <template v-else-if="logSuccess && !showWasteDrawer">
        <div class="recipe-page__success">Batch logged!</div>
        <div class="recipe-page__post-log">
          <button v-if="itemId" class="recipe-page__waste-link" @click="showWasteDrawer = true">
            Log waste instead
          </button>
          <NuxtLink :to="backPath" class="recipe-page__done-link">Done →</NuxtLink>
        </div>
      </template>

      <!-- Waste log drawer -->
      <div v-else-if="showWasteDrawer" class="waste-drawer">
        <p class="waste-drawer__label">Log waste for {{ recipe.name }}</p>
        <div class="waste-drawer__row">
          <input
            v-model="wasteQty"
            class="waste-drawer__qty"
            type="number"
            min="0.1"
            step="0.5"
            inputmode="decimal"
            placeholder="0.0"
          />
          <span class="waste-drawer__unit">L</span>
        </div>
        <input
          v-model="wasteReason"
          class="waste-drawer__reason"
          type="text"
          placeholder="Reason (optional)"
          maxlength="200"
        />
        <p v-if="wasteError" class="waste-drawer__error">{{ wasteError }}</p>
        <div class="waste-drawer__actions">
          <button class="waste-drawer__cancel" :disabled="loggingWaste" @click="showWasteDrawer = false">
            Cancel
          </button>
          <button
            class="waste-drawer__submit"
            :disabled="loggingWaste || !wasteQty || parseFloat(wasteQty) <= 0"
            @click="logWaste"
          >
            {{ loggingWaste ? 'Logging…' : 'Log Waste' }}
          </button>
        </div>
      </div>

      <!-- Confirm drawer -->
      <div v-else-if="showConfirm" class="log-confirm">
        <p class="log-confirm__label">Log {{ scaledYield }} L of {{ recipe.name }}?</p>
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

      <!-- Primary CTA -->
      <button
        v-else
        class="recipe-page__log-btn"
        :disabled="!canLog"
        @click="showConfirm = true"
      >
        Log {{ scaledYield }} L
      </button>

    </div>

  </div>
</template>

<style lang="scss" scoped>
.recipe-page {
  padding: var(--space-4) var(--space-6);
  padding-top: max(var(--space-4), env(safe-area-inset-top));
  padding-bottom: calc(var(--nav-height) + env(safe-area-inset-bottom) + 240px);

  &__header { margin-bottom: var(--space-4); }

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

  &__last-batch {
    font-size: var(--text-xs);
    color: var(--color-text-muted);
    margin-bottom: var(--space-3);
  }

  &__yield-row {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    margin-bottom: var(--space-4);
  }

  &__yield-label {
    font-size: var(--text-sm);
    color: var(--color-text-muted);
    margin-right: var(--space-1);
  }

  &__step-btn {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: 1px solid var(--color-border);
    background: var(--color-surface);
    color: var(--color-text);
    font-size: var(--text-lg);
    line-height: 1;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;

    &:active:not(:disabled) { background: var(--color-surface-alt); }
    &:disabled { opacity: 0.35; }
  }

  &__scale-badge {
    min-width: 44px;
    text-align: center;
    font-size: var(--text-base);
    font-weight: 600;
    color: var(--color-accent);
  }

  &__yield-total {
    font-size: var(--text-sm);
    color: var(--color-text-muted);
    margin-left: var(--space-1);
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
    &--error { color: var(--color-danger); }
  }

  &__footer {
    position: fixed;
    bottom: calc(var(--nav-height) + env(safe-area-inset-bottom));
    left: 0;
    right: 0;
    padding: var(--space-4) var(--space-6);
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

    &:active { opacity: 0.85; }
    &:disabled { opacity: 0.4; cursor: default; }
  }

  &__success {
    text-align: center;
    color: var(--color-success);
    font-weight: 600;
    padding: var(--space-3) 0 var(--space-2);
  }

  &__post-log {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: var(--space-4);
    padding-top: var(--space-1);
  }

  &__waste-link {
    background: none;
    border: none;
    color: var(--color-text-muted);
    font-size: var(--text-sm);
    cursor: pointer;
    padding: 0;
    text-decoration: underline dotted;
  }

  &__done-link {
    font-size: var(--text-base);
    font-weight: 600;
    color: var(--color-accent);
    text-decoration: none;
  }
}

// Recipe content sections
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

  &__name { color: var(--color-text); }
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

// Confirm drawer
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

    &::placeholder { color: var(--color-text-muted); }
    &:focus { outline: none; border-color: var(--color-accent); }
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

    &:active:not(:disabled) { background: var(--color-surface-alt); }
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

    &:active:not(:disabled) { opacity: 0.85; }
    &:disabled { opacity: 0.5; }
  }
}

// Waste log drawer
.waste-drawer {
  display: flex;
  flex-direction: column;
  gap: var(--space-3);

  &__label {
    font-size: var(--text-base);
    font-weight: 500;
    text-align: center;
  }

  &__row {
    display: flex;
    align-items: center;
    gap: var(--space-2);
  }

  &__qty {
    flex: 1;
    padding: var(--space-3);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-base);

    &:focus { outline: none; border-color: var(--color-accent); }
  }

  &__unit {
    font-size: var(--text-sm);
    color: var(--color-text-muted);
    min-width: 20px;
  }

  &__reason {
    padding: var(--space-3);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-family: var(--font-body);
    font-size: var(--text-sm);
    width: 100%;

    &::placeholder { color: var(--color-text-muted); }
    &:focus { outline: none; border-color: var(--color-accent); }
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

    &:active:not(:disabled) { background: var(--color-surface-alt); }
  }

  &__submit {
    padding: var(--space-3);
    background: var(--color-danger);
    border: none;
    border-radius: var(--radius-base);
    color: #fff;
    font-size: var(--text-base);
    font-weight: 600;
    cursor: pointer;

    &:active:not(:disabled) { opacity: 0.85; }
    &:disabled { opacity: 0.5; }
  }
}
</style>
