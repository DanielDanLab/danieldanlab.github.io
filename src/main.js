
import { createApp } from 'vue'
import App from './App.vue'
// Explicitly point to the router’s entry file
import router from './router/index.js'
// Adjust this to wherever your global CSS lives
import './assets/style.css'

createApp(App)
  .use(router)
  .mount('#app')
