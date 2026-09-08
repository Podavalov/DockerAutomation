/// <reference types="vitest/config" />
import react from '@vitejs/plugin-react'
import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 5173,
    proxy: {
      // Локальный запуск без nginx: проксируем API прямо на Django
      '/api': 'http://backend:8000',
    },
    // HMR-websocket идёт через nginx на порту 80; локально (без nginx) — через сам Vite
    hmr: { clientPort: Number(process.env.VITE_HMR_CLIENT_PORT) || 80 },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/setupTests.ts',
  },
})
