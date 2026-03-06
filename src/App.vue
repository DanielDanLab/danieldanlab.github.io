<template>
  <div id="app">
    <nav>
      <router-link to="/">Home</router-link>
      <router-link to="/chapters">Chapters</router-link>
      <router-link to="/data">Data</router-link>
      <router-link to="/contact">Contact</router-link>
            <router-link to="/errata">Errata</router-link>
          <!-- Private stats link: only visible to admin -->
    <a
      href="https://danieldanlab.goatcounter.com"
      target="_blank"
      rel="noopener"
      class="stats-link"
      title="Site Statistics"
    >&#128202;</a>
    </nav>
    <router-view />
  </div>
</template>


<script setup>
// No imports needed here; the router is injected in main.js
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  color: #2c3e50;
  margin: 0;
  padding: 0;
}
nav {
  background: #f5f5f5;
  padding: 1em;
}
nav a {
  margin-right: 1em;
  text-decoration: none;
  color: #42b983;
}
nav a.router-link-active {
  .stats-link {
  position: fixed;
  bottom: 1.5rem;
  left: 1.5rem;
  font-size: 1.4rem;
  opacity: 0.25;
  text-decoration: none;
  transition: opacity 0.2s;
  z-index: 1000;
}
.stats-link:hover {
  opacity: 0.85;
}
  font-weight: bold;
}
</style>
