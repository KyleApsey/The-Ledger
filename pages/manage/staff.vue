<script setup>
definePageMeta({ middleware: ['auth', 'admin'] })
</script>

<script>
export default {
  data() {
    return {
      staff: [],
      loading: true,
      error: '',
      // Add form
      form: { name: '', pin: '', is_admin: false },
      adding: false,
      addError: '',
      showForm: false,
    }
  },

  async mounted() {
    await this.load()
  },

  methods: {
    async load() {
      this.loading = true
      this.error = ''
      try {
        this.staff = await $fetch('/api/admin/staff', { headers: getAuthHeaders() })
      } catch {
        this.error = 'Could not load staff.'
      } finally {
        this.loading = false
      }
    },

    async toggleAdmin(member) {
      try {
        await $fetch(`/api/admin/staff/${member.id}`, {
          method: 'PATCH',
          headers: getAuthHeaders(),
          body: { is_admin: !member.is_admin },
        })
        member.is_admin = !member.is_admin
      } catch {
        this.error = 'Could not update staff member.'
      }
    },

    async addStaff() {
      if (this.adding) return
      this.addError = ''
      if (!this.form.name.trim()) { this.addError = 'Name is required.'; return }
      if (!/^\d{4}$/.test(this.form.pin)) { this.addError = 'PIN must be 4 digits.'; return }

      this.adding = true
      try {
        const created = await $fetch('/api/admin/staff', {
          method: 'POST',
          headers: getAuthHeaders(),
          body: { name: this.form.name.trim(), pin: this.form.pin, is_admin: this.form.is_admin },
        })
        this.staff.push(created)
        this.staff.sort((a, b) => a.name.localeCompare(b.name))
        this.form = { name: '', pin: '', is_admin: false }
        this.showForm = false
      } catch (e) {
        this.addError = e?.data?.message ?? 'Could not add staff member.'
      } finally {
        this.adding = false
      }
    },
  },
}
</script>

<template>
  <div class="staff-manage">
    <header class="admin-header">
      <button class="admin-header__back" @click="$router.replace('/manage')">← Manage</button>
      <h1 class="admin-header__title">Staff</h1>
    </header>

    <div v-if="loading" class="admin-state">Loading…</div>
    <p v-else-if="error" class="admin-state admin-state--error">{{ error }}</p>

    <ul v-else class="staff-list">
      <li v-for="member in staff" :key="member.id" class="staff-card">
        <div class="staff-card__info">
          <span class="staff-card__name">{{ member.name }}</span>
          <span v-if="member.is_admin" class="staff-card__badge">Admin</span>
        </div>
        <button
          class="staff-card__toggle"
          :class="{ 'staff-card__toggle--active': member.is_admin }"
          @click="toggleAdmin(member)"
        >
          {{ member.is_admin ? 'Remove admin' : 'Make admin' }}
        </button>
      </li>
    </ul>

    <!-- Add form -->
    <div v-if="showForm" class="add-staff-form">
      <h2 class="add-staff-form__heading">Add staff member</h2>
      <input
        v-model="form.name"
        class="add-staff-form__input"
        type="text"
        placeholder="Name"
        autocomplete="off"
      />
      <input
        v-model="form.pin"
        class="add-staff-form__input"
        type="text"
        inputmode="numeric"
        pattern="[0-9]*"
        maxlength="4"
        placeholder="4-digit PIN"
        autocomplete="off"
      />
      <label class="add-staff-form__checkbox">
        <input v-model="form.is_admin" type="checkbox" />
        Admin access
      </label>
      <p v-if="addError" class="add-staff-form__error">{{ addError }}</p>
      <div class="add-staff-form__actions">
        <button class="add-staff-form__cancel" @click="showForm = false; addError = ''">Cancel</button>
        <button class="add-staff-form__submit" :disabled="adding" @click="addStaff">
          {{ adding ? 'Adding…' : 'Add' }}
        </button>
      </div>
    </div>

    <button v-else class="admin-add-btn" @click="showForm = true">+ Add staff member</button>
  </div>
</template>

<style lang="scss" scoped>
.staff-manage {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  padding-bottom: calc(var(--nav-height) + var(--space-6) + env(safe-area-inset-bottom));
}

.staff-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: var(--space-2);
  margin-bottom: var(--space-6);
}

.staff-card {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: var(--space-4);
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  gap: var(--space-3);

  &__info {
    display: flex;
    align-items: center;
    gap: var(--space-2);
  }

  &__name {
    font-size: var(--text-base);
  }

  &__badge {
    font-size: var(--text-xs);
    background: var(--color-accent);
    color: #000;
    border-radius: var(--radius-full);
    padding: 1px 8px;
    font-weight: 600;
  }

  &__toggle {
    flex-shrink: 0;
    padding: var(--space-2) var(--space-3);
    background: var(--color-surface-alt);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-xs);
    cursor: pointer;

    &--active {
      color: var(--color-danger);
    }
  }
}

.add-staff-form {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-base);
  padding: var(--space-5);
  display: flex;
  flex-direction: column;
  gap: var(--space-3);

  &__heading {
    font-size: var(--text-base);
    font-weight: 600;
  }

  &__input {
    background: var(--color-bg);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text);
    font-size: var(--text-base);
    padding: var(--space-3) var(--space-4);
    width: 100%;

    &:focus {
      outline: none;
      border-color: var(--color-accent);
    }
  }

  &__checkbox {
    display: flex;
    align-items: center;
    gap: var(--space-2);
    font-size: var(--text-sm);
    color: var(--color-text-muted);
    cursor: pointer;
  }

  &__error {
    color: var(--color-danger);
    font-size: var(--text-sm);
  }

  &__actions {
    display: grid;
    grid-template-columns: 1fr 2fr;
    gap: var(--space-2);
    margin-top: var(--space-1);
  }

  &__cancel {
    padding: var(--space-3);
    background: var(--color-surface-alt);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-base);
    cursor: pointer;
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

    &:disabled { opacity: 0.5; }
  }
}
</style>
