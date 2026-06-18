<script setup>
definePageMeta({ layout: 'auth' })
</script>

<script>
const PAD_KEYS = ['1', '2', '3', '4', '5', '6', '7', '8', '9']

export default {
  data() {
    return {
      staff: [],
      selected: null,   // { id, name }
      pin: '',
      loading: false,
      error: '',
    }
  },

  async mounted() {
    if (isSessionValid()) {
      this.$router.replace('/checklist')
      return
    }
    try {
      this.staff = await $fetch('/api/staff')
    } catch {
      this.error = 'Could not load staff list.'
    }
  },

  methods: {
    selectStaff(member) {
      this.selected = member
      this.pin = ''
      this.error = ''
    },

    back() {
      this.selected = null
      this.pin = ''
      this.error = ''
    },

    pressDigit(digit) {
      if (this.loading || this.pin.length >= 4) return
      this.pin += digit
      if (this.pin.length === 4) this.submit()
    },

    backspace() {
      if (this.loading) return
      this.pin = this.pin.slice(0, -1)
      this.error = ''
    },

    async submit() {
      this.loading = true
      this.error = ''
      try {
        const { token } = await $fetch('/api/auth/login', {
          method: 'POST',
          body: { staff_id: this.selected.id, pin: this.pin },
        })
        setSession(token)
        this.$router.replace('/checklist')
      } catch {
        this.error = 'Incorrect PIN'
        this.pin = ''
      } finally {
        this.loading = false
      }
    },
  },

  computed: {
    padKeys() {
      return PAD_KEYS
    },
  },
}
</script>

<template>
  <div class="pin-page">

    <!-- Staff picker -->
    <div v-if="!selected" class="staff-picker">
      <h1 class="staff-picker__title">Who's prepping?</h1>

      <p v-if="error" class="staff-picker__error">{{ error }}</p>

      <ul v-if="staff.length" class="staff-picker__list">
        <li v-for="member in staff" :key="member.id">
          <button class="staff-picker__item" @click="selectStaff(member)">
            {{ member.name }}
          </button>
        </li>
      </ul>

      <p v-else-if="!error" class="staff-picker__empty">Loading…</p>
    </div>

    <!-- PIN entry -->
    <div v-else class="pin-entry">
      <button class="pin-entry__back" @click="back">← Back</button>

      <p class="pin-entry__who">{{ selected.name }}</p>

      <div class="pin-entry__dots" aria-label="PIN entered" aria-live="polite">
        <span
          v-for="i in 4"
          :key="i"
          class="pin-entry__dot"
          :class="{ 'pin-entry__dot--filled': pin.length >= i }"
        />
      </div>

      <p class="pin-entry__error" aria-live="assertive">{{ error }}</p>

      <div class="pin-entry__pad">
        <button
          v-for="digit in padKeys"
          :key="digit"
          class="pin-entry__key"
          :disabled="loading"
          @click="pressDigit(digit)"
        >
          {{ digit }}
        </button>

        <!-- empty cell then 0 then backspace -->
        <span />
        <button class="pin-entry__key pin-entry__key--zero" :disabled="loading" @click="pressDigit('0')">0</button>
        <button class="pin-entry__key pin-entry__key--backspace" :disabled="loading" @click="backspace">⌫</button>
      </div>
    </div>

  </div>
</template>

<style lang="scss" scoped>
.pin-page {
  display: flex;
  flex-direction: column;
  min-height: 100dvh;
  padding: var(--space-10) var(--space-6) var(--space-6);
  padding-top: max(var(--space-10), env(safe-area-inset-top));
  padding-bottom: max(var(--space-6), env(safe-area-inset-bottom));
}

// ---- Staff picker ----

.staff-picker {
  flex: 1;

  &__title {
    font-size: var(--text-2xl);
    font-weight: 600;
    margin-bottom: var(--space-8);
    text-align: center;
  }

  &__list {
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: var(--space-3);
  }

  &__item {
    width: 100%;
    padding: var(--space-5) var(--space-6);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    font-size: var(--text-lg);
    color: var(--color-text);
    text-align: left;
    cursor: pointer;
    transition: background var(--transition-fast), border-color var(--transition-fast);

    &:active {
      background: var(--color-surface-alt);
      border-color: var(--color-accent);
    }
  }

  &__error,
  &__empty {
    text-align: center;
    color: var(--color-text-muted);
    font-size: var(--text-sm);
    margin-top: var(--space-4);
  }

  &__error {
    color: var(--color-danger);
  }
}

// ---- PIN entry ----

.pin-entry {
  flex: 1;
  display: flex;
  flex-direction: column;

  &__back {
    background: none;
    border: none;
    color: var(--color-accent);
    font-size: var(--text-base);
    padding: 0;
    margin-bottom: var(--space-8);
    cursor: pointer;
    align-self: flex-start;
  }

  &__who {
    font-size: var(--text-2xl);
    font-weight: 600;
    text-align: center;
    margin-bottom: var(--space-8);
  }

  &__dots {
    display: flex;
    justify-content: center;
    gap: var(--space-5);
    margin-bottom: var(--space-3);
  }

  &__dot {
    width: 18px;
    height: 18px;
    border-radius: 50%;
    border: 2px solid var(--color-border);
    transition: background var(--transition-fast), border-color var(--transition-fast);

    &--filled {
      background: var(--color-accent);
      border-color: var(--color-accent);
    }
  }

  &__error {
    min-height: 1.25rem;
    text-align: center;
    color: var(--color-danger);
    font-size: var(--text-sm);
    margin-bottom: var(--space-6);
  }

  &__pad {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: var(--space-3);
    margin-top: auto;
  }

  &__key {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 68px;
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    font-size: var(--text-2xl);
    font-weight: 500;
    color: var(--color-text);
    cursor: pointer;
    transition: background var(--transition-fast);
    -webkit-tap-highlight-color: transparent;

    &:active:not(:disabled) {
      background: var(--color-surface-alt);
    }

    &:disabled {
      opacity: 0.4;
    }

    &--backspace {
      color: var(--color-text-muted);
      font-size: var(--text-xl);
    }
  }
}
</style>
