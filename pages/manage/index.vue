<script setup>
definePageMeta({ middleware: ['auth', 'admin'] })
</script>

<script>
export default {
  methods: {
    signOut() {
      clearSession()
      this.$router.replace('/pin')
    },
  },
}
</script>

<template>
  <div class="manage-hub">
    <header class="manage-hub__header">
      <h1 class="manage-hub__title">Manage</h1>
    </header>

    <nav class="manage-nav">
      <NuxtLink to="/manage/items" class="manage-nav__item">
        <span class="manage-nav__label">Items</span>
        <svg class="manage-nav__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>
      </NuxtLink>
      <NuxtLink to="/manage/recipes" class="manage-nav__item">
        <span class="manage-nav__label">Recipes</span>
        <svg class="manage-nav__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>
      </NuxtLink>
      <NuxtLink to="/manage/staff" class="manage-nav__item">
        <span class="manage-nav__label">Staff</span>
        <svg class="manage-nav__arrow" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M9 18l6-6-6-6"/></svg>
      </NuxtLink>
    </nav>

    <div class="manage-hub__footer">
      <button class="manage-hub__signout" @click="signOut">Sign out</button>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.manage-hub {
  padding: var(--space-6);
  padding-top: max(var(--space-6), env(safe-area-inset-top));
  display: flex;
  flex-direction: column;
  min-height: calc(100dvh - var(--nav-height));

  &__header {
    margin-bottom: var(--space-8);
  }

  &__title {
    font-size: var(--text-2xl);
    font-weight: 600;
  }

  &__footer {
    margin-top: auto;
    padding-top: var(--space-8);
  }

  &__signout {
    width: 100%;
    padding: var(--space-4);
    background: none;
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    color: var(--color-text-muted);
    font-size: var(--text-base);
    cursor: pointer;

    &:active {
      background: var(--color-surface);
    }
  }
}

.manage-nav {
  display: flex;
  flex-direction: column;
  gap: var(--space-2);

  &__item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: var(--space-5) var(--space-4);
    background: var(--color-surface);
    border: 1px solid var(--color-border);
    border-radius: var(--radius-base);
    text-decoration: none;
    color: var(--color-text);
    transition: background var(--transition-fast);

    &:active {
      background: var(--color-surface-alt);
    }
  }

  &__label {
    font-size: var(--text-lg);
  }

  &__arrow {
    width: 18px;
    height: 18px;
    color: var(--color-text-muted);
  }
}
</style>
