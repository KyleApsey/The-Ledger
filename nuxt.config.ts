export default defineNuxtConfig({
  modules: ['@vite-pwa/nuxt'],

  nitro: {
    preset: 'vercel',
  },

  runtimeConfig: {
    supabaseUrl: process.env.SUPABASE_URL || '',
    supabaseSecretKey: process.env.SUPABASE_SECRET_KEY || '',
    sessionSecret: process.env.SESSION_SECRET || '',
    // runtimeConfig.public is intentionally empty — secret keys must never reach the client bundle
  },

  css: ['~/assets/styles/main.scss'],

  vite: {
    css: {
      preprocessorOptions: {
        scss: {
          api: 'modern',
        },
      },
    },
  },

  pwa: {
    registerType: 'autoUpdate',
    manifest: {
      name: "The Ledger — Belle's Lounge",
      short_name: 'The Ledger',
      description: "Bar prep management for Belle's Lounge",
      theme_color: '#1a1a1a',
      background_color: '#1a1a1a',
      display: 'standalone',
      orientation: 'portrait',
      icons: [
        { src: '/icon-192.png', sizes: '192x192', type: 'image/png' },
        { src: '/icon-512.png', sizes: '512x512', type: 'image/png' },
      ],
    },
    workbox: {
      globPatterns: ['**/*.{js,css,html,png,svg,ico}'],
      runtimeCaching: [
        {
          urlPattern: /^\/api\/(?!admin).*/,
          handler: 'NetworkFirst',
          options: {
            cacheName: 'api-cache',
            networkTimeoutSeconds: 10,
            cacheableResponse: { statuses: [200] },
          },
        },
      ],
    },
    client: {
      installPrompt: true,
    },
  },

  devtools: { enabled: true },
})
