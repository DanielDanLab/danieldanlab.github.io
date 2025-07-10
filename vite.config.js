// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
import { webcrypto } from 'crypto'

// Polyfill the Web Crypto API in Node
globalThis.crypto = webcrypto

export default defineConfig({
  // Use root "/" in development, and your GitHub Pages sub-path in production
  base: process.env.NODE_ENV === 'production'
    ? '/danieldanlab.github.io/'
    : '/',
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    }
  },
  plugins: [
    vue(),
  ],
  build: {
    outDir: 'docs',
  },
  assetsInclude: [
    '**/*.R', '**/*.md'
  ]
})
