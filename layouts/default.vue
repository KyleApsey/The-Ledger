<script>
export default {
  data() {
    return {
      isAdmin: false,
    }
  },

  mounted() {
    const session = getSession()
    this.isAdmin = session?.is_admin ?? false
    this.checkInactivity()
  },

  methods: {
    checkInactivity() {
      if (isIdleExpired()) {
        clearSession()
        this.$router.replace('/pin')
      }
    },

    touch() {
      updateActivity()
    },
  },
}
</script>

<template>
  <div class="layout" @click="touch" @touchstart.passive="touch" @keydown="touch">
    <main class="layout__content">
      <slot />
    </main>

    <nav class="bottom-nav" aria-label="Main navigation">
      <NuxtLink to="/checklist" class="bottom-nav__tab" active-class="bottom-nav__tab--active">
        <svg class="bottom-nav__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <path d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2" />
          <rect x="9" y="3" width="6" height="4" rx="1" />
          <path d="M9 12h6M9 16h4" />
        </svg>
        <span class="bottom-nav__label">Prep</span>
      </NuxtLink>

      <NuxtLink v-if="isAdmin" to="/manage" class="bottom-nav__tab" active-class="bottom-nav__tab--active">
        <svg class="bottom-nav__icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true">
          <circle cx="12" cy="12" r="3" />
          <path d="M19.07 4.93a10 10 0 010 14.14M4.93 4.93a10 10 0 000 14.14" />
          <path d="M12 2v2M12 20v2M2 12h2M20 12h2" />
        </svg>
        <span class="bottom-nav__label">Manage</span>
      </NuxtLink>
    </nav>
  </div>
</template>

<style lang="scss" scoped>
.layout {
  display: flex;
  flex-direction: column;
  min-height: 100dvh;

  &__content {
    flex: 1;
    overflow-y: auto;
    // Reserve space so content doesn't hide behind fixed nav
    padding-bottom: calc(var(--nav-height) + env(safe-area-inset-bottom));
  }
}

.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  height: calc(var(--nav-height) + env(safe-area-inset-bottom));
  padding-bottom: env(safe-area-inset-bottom);
  background: var(--color-surface);
  border-top: 1px solid var(--color-border);
  display: flex;

  &__tab {
    flex: 1;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    gap: var(--space-1);
    color: var(--color-text-muted);
    text-decoration: none;
    font-size: var(--text-xs);
    transition: color var(--transition-fast);

    &--active {
      color: var(--color-accent);
    }
  }

  &__icon {
    width: 22px;
    height: 22px;
  }

  &__label {
    letter-spacing: 0.02em;
  }
}
</style>
