import { createRouter, createWebHashHistory } from 'vue-router'

import Home        from '../components/Home.vue'
import ChapterList from '../components/ChapterList.vue'
import ChapterView from '../components/ChapterView.vue'
import Contact     from '../components/Contact.vue'

export default createRouter({
  history: createWebHashHistory(import.meta.env.BASE_URL),
  routes: [
    { path: '/',             component: Home },
    { path: '/chapters',     component: ChapterList },
    { path: '/chapters/:slug', component: ChapterView },
    { path: '/contact',      component: Contact },
    { path: '/:pathMatch(.*)*', redirect: '/' }
  ]
})
