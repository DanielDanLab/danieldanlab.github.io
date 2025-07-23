// vite.config.js
import { defineConfig } from "vite";
import vue from "@vitejs/plugin-vue";
import path from "path";
import { webcrypto } from "crypto";

// Polyfill the Web Crypto API in Node
globalThis.crypto = webcrypto;

export default defineConfig(({mode}) => {
  const isProd = mode === "production"
  return {
    
    // Use root "/" in development, and your GitHub Pages sub-path in production
    base: process.env.NODE_ENV === 'production'
    ? '/danieldanlab.github.io/'
    : '/',
    //base: isProd ? "/" : "./",
    resolve: {
      alias: {
        "@": path.resolve(__dirname, "./src"),
      },
    },
    plugins: [vue()],
    build: {
      outDir: "docs",
    },
  };
});
