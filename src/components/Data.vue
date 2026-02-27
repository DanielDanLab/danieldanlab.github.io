<!-- src/views/Data.vue -->
<template>
    <div class="data-page">
      <h1>Raw Data Files</h1>
  
      <!-- snappy line -->
      <p class="tagline">
        Click on the respective file to download it for a guaranteed most pleasurable learning experience.
      </p>
  
      <ul>
        <li v-for="file in files" :key="file">
          <a :href="`/data/${file}`" download>{{ file }}</a>
        </li>
      </ul>
    </div>
  </template>
  
  <script setup>
  const files = [
    'dictionary.yml',
    'Product Reviews.csv',
    'sample.csv',
    'sample.pdf'
  ]
  </script>
  
  <style scoped>
  .data-page {
    max-width: 800px;
    margin: 2rem auto;
    text-align: center;
  }
  
  .tagline {
    font-style: italic;
    margin: 1rem 0 2rem;
    color: #555;
  }
  
  .data-page ul {
    list-style: none;
    padding: 0;
  }
  
  .data-page li + li {
    margin-top: 0.75rem;
  }
  
  .data-page a {
    color: #42b983;
    text-decoration: none;
    font-weight: 500;
  }
  
  .data-page a:hover {
    text-decoration: underline;
  }
  </style>
  
