<script setup>
definePageMeta({ middleware: ['auth', 'admin'] })
</script>

<script>
export default {
  data() {
    return {
      items: [],
      loadingItems: true,
      // Form fields
      name: '',
      base_yield_liters: '',
      item_id: '',
      notes: '',
      ingredients: [{ name: '', quantity: '', unit: '' }],
      steps: [{ instruction: '' }],
      // Submit state
      submitting: false,
      submitError: '',
      formError: '',
    }
  },

  async mounted() {
    await this.loadItems()
  },

  computed: {
    activeItems() {
      return this.items.filter(i => i.is_active)
    },
  },

  methods: {
    async loadItems() {
      this.loadingItems = true
      try {
        this.items = await $fetch('/api/admin/items', { headers: getAuthHeaders() })
      } catch {
        // Non-fatal: item link is optional
      } finally {
        this.loadingItems = false
      }
    },

    addIngredient() {
      this.ingredients.push({ name: '', quantity: '', unit: '' })
    },

    removeIngredient(index) {
      if (this.ingredients.length > 1) {
        this.ingredients.splice(index, 1)
      }
    },

    addStep() {
      this.steps.push({ instruction: '' })
    },

    removeStep(index) {
      if (this.steps.length > 1) {
        this.steps.splice(index, 1)
      }
    },

    validate() {
      if (!this.name.trim()) return 'Recipe name is required.'
      const y = parseFloat(this.base_yield_liters)
      if (isNaN(y) || y <= 0) return 'Yield must be a positive number.'
      for (const ing of this.ingredients) {
        if (!ing.name.trim()) return 'Each ingredient needs a name.'
        const q = parseFloat(ing.quantity)
        if (isNaN(q) || q <= 0) return 'Each ingredient needs a positive quantity.'
        if (!ing.unit.trim()) return 'Each ingredient needs a unit.'
      }
      for (const step of this.steps) {
        if (!step.instruction.trim()) return 'Each step needs an instruction.'
      }
      return null
    },

    async submit() {
      if (this.submitting) return
      this.formError = ''
      const validationError = this.validate()
      if (validationError) {
        this.formError = validationError
        return
      }
      this.submitting = true
      this.submitError = ''
      try {
        const { id } = await $fetch('/api/admin/recipes', {
          method: 'POST',
          headers: getAuthHeaders(),
          body: {
            name: this.name.trim(),
            base_yield_liters: parseFloat(this.base_yield_liters),
            item_id: this.item_id || null,
            notes: this.notes.trim() || null,
            ingredients: this.ingredients.map(i => ({
              name: i.name.trim(),
              quantity: i.quantity,
              unit: i.unit.trim(),
            })),
            steps: this.steps.map(s => ({ instruction: s.instruction.trim() })),
          },
        })
        this.$router.replace(`/recipes/${id}`)
      } catch (err) {
        this.submitError = err?.data?.message ?? 'Could not create recipe. Try again.'
      } finally {
        this.submitting = false
      }
    },
  },
}
</script>

<template>
  <div class="recipe-new">
    <header class="admin-header">
      <button class="admin-header__back" @click="$router.replace('/manage/recipes')">← Recipes</button>
      <h1 class="admin-header__title">New Recipe</h1>
    </header>

    <form class="recipe-new__form" @submit.prevent="submit">

      <!-- Name -->
      <div class="form-field">
        <label class="form-field__label" for="recipe-name">Name</label>
        <input
          id="recipe-name"
          v-model="name"
          class="form-field__input"
          type="text"
          placeholder="e.g. Simple Syrup"
          autocomplete="off"
          maxlength="120"
        />
      </div>

      <!-- Yield -->
      <div class="form-field">
        <label class="form-field__label" for="recipe-yield">Base yield (liters)</label>
        <input
          id="recipe-yield"
          v-model="base_yield_liters"
          class="form-field__input form-field__input--narrow"
          type="number"
          min="0.01"
          step="0.01"
          inputmode="decimal"
          placeholder="1.0"
        />
      </div>

      <!-- Linked item (optional) -->
      <div class="form-field">
        <label class="form-field__label" for="recipe-item">Linked item <span class="form-field__opt">(optional)</span></label>
        <select
          id="recipe-item"
          v-model="item_id"
          class="form-field__input"
          :disabled="loadingItems"
        >
          <option value="">None</option>
          <option v-for="item in activeItems" :key="item.id" :value="item.id">{{ item.name }}</option>
        </select>
      </div>

      <!-- Notes (optional) -->
      <div class="form-field">
        <label class="form-field__label" for="recipe-notes">Notes <span class="form-field__opt">(optional)</span></label>
        <textarea
          id="recipe-notes"
          v-model="notes"
          class="form-field__input form-field__textarea"
          rows="2"
          placeholder="Storage tip, yield note, etc."
          maxlength="500"
        />
      </div>

      <!-- Ingredients -->
      <div class="recipe-new__section">
        <h2 class="recipe-new__section-heading">Ingredients</h2>
        <div
          v-for="(ing, index) in ingredients"
          :key="index"
          class="ingredient-row"
        >
          <input
            v-model="ing.name"
            class="ingredient-row__name"
            type="text"
            placeholder="Name"
            autocomplete="off"
          />
          <input
            v-model="ing.quantity"
            class="ingredient-row__qty"
            type="number"
            min="0"
            step="any"
            inputmode="decimal"
            placeholder="Qty"
          />
          <input
            v-model="ing.unit"
            class="ingredient-row__unit"
            type="text"
            placeholder="Unit"
            autocomplete="off"
            maxlength="20"
          />
          <button
            type="button"
            class="ingredient-row__remove"
            :disabled="ingredients.length === 1"
            aria-label="Remove ingredient"
            @click="removeIngredient(index)"
          >×</button>
        </div>
        <button type="button" class="recipe-new__add-btn" @click="addIngredient">+ Add ingredient</button>
      </div>

      <!-- Steps -->
      <div class="recipe-new__section">
        <h2 class="recipe-new__section-heading">Steps</h2>
        <div
          v-for="(step, index) in steps"
          :key="index"
          class="step-row"
        >
          <span class="step-row__num">{{ index + 1 }}</span>
          <textarea
            v-model="step.instruction"
            class="step-row__instruction"
            rows="2"
            :placeholder="`Step ${index + 1}`"
          />
          <button
            type="button"
            class="step-row__remove"
            :disabled="steps.length === 1"
            aria-label="Remove step"
            @click="removeStep(index)"
          >×</button>
        </div>
        <button type="button" class="recipe-new__add-btn" @click="addStep">+ Add step</button>
      </div>

      <!-- Errors -->
      <p v-if="formError" class="recipe-new__error">{{ formError }}</p>
      <p v-if="submitError" class="recipe-new__error">{{ submitError }}</p>

      <!-- Actions -->
      <div class="recipe-new__actions">
        <button
          type="button"
          class="recipe-new__cancel"
          :disabled="submitting"
          @click="$router.replace('/manage/recipes')"
        >
          Cancel
        </button>
        <button
          type="submit"
          class="recipe-new__submit"
          :disabled="submitting"
        >
          {{ submitting ? 'Saving…' : 'Save recipe' }}
        </button>
      </div>

    </form>
  </div>
</template>

<style lang="scss" scoped>
.recipe-new {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  padding-bottom: calc(var(--nav-height) + var(--space-10) + env(safe-area-inset-bottom));

  &__form {
    margin-top: var(--space-6);
    display: flex;
    flex-direction: column;
    gap: var(--space-6);
  }

  &__section {
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  &__section-heading {
    font-size: var(--text-sm);
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: var(--color-text-muted);
  }

  &__add-btn {
    align-self: flex-start;
    background: none;
    border: 1px dashed var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-sm);
    padding: var(--space-2) var(--space-3);
    cursor: pointer;

    &:active { background: var(--color-surface-alt); }
  }

  &__error {
    color: var(--color-danger);
    font-size: var(--text-sm);
    text-align: center;
  }

  &__actions {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: var(--space-3);
    padding-top: var(--space-2);
  }

  &__cancel {
    padding: var(--space-4);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-base);
    cursor: pointer;

    &:active:not(:disabled) { background: var(--color-surface-alt); }
    &:disabled { opacity: 0.5; }
  }

  &__submit {
    padding: var(--space-4);
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

.form-field {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);

  &__label {
    font-size: var(--text-sm);
    font-weight: 500;
    color: var(--color-text);
  }

  &__opt {
    color: var(--color-text-muted);
    font-weight: 400;
  }

  &__input {
    padding: var(--space-3) var(--space-4);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-base);
    font-family: var(--font-body);
    width: 100%;

    &::placeholder { color: var(--color-text-muted); }
    &:focus { outline: none; border-color: var(--color-accent); }

    &--narrow { max-width: 140px; }
  }

  &__textarea {
    resize: vertical;
    min-height: 60px;
  }
}

.ingredient-row {
  display: grid;
  grid-template-columns: 1fr 72px 72px 32px;
  gap: var(--space-2);
  align-items: center;

  input {
    padding: var(--space-3);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-sm);
    font-family: var(--font-body);
    width: 100%;

    &::placeholder { color: var(--color-text-muted); }
    &:focus { outline: none; border-color: var(--color-accent); }
  }

  &__name { grid-column: 1; }
  &__qty  { grid-column: 2; }
  &__unit { grid-column: 3; }

  &__remove {
    grid-column: 4;
    width: 32px;
    height: 32px;
    background: none;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-base);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;

    &:disabled { opacity: 0.3; cursor: default; }
    &:active:not(:disabled) { background: var(--color-surface-alt); }
  }
}

.step-row {
  display: grid;
  grid-template-columns: 24px 1fr 32px;
  gap: var(--space-2);
  align-items: flex-start;

  &__num {
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
    flex-shrink: 0;
    margin-top: calc(var(--space-3) + 1px);
  }

  &__instruction {
    padding: var(--space-3);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-sm);
    font-family: var(--font-body);
    width: 100%;
    resize: vertical;
    min-height: 52px;

    &::placeholder { color: var(--color-text-muted); }
    &:focus { outline: none; border-color: var(--color-accent); }
  }

  &__remove {
    width: 32px;
    height: 32px;
    background: none;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-base);
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    margin-top: calc(var(--space-3) + 1px);

    &:disabled { opacity: 0.3; cursor: default; }
    &:active:not(:disabled) { background: var(--color-surface-alt); }
  }
}
</style>
