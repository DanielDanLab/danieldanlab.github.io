<template>
    <div class="home">
      <h1 class="book-title">Text Analytics in Marketing</h1>
      <p class="book-subtitle">
        Your companion website for the book 
        Text Analytics in Marketing
      </p>
      <p class="book-meta">
        <strong>Authors:</strong> Daniel Dan, Thomas Reutterer<br/>
        <strong>Published:</strong> February 2026<br/>
                      If you use this book in class, please send me an email at daniel.dan@modul.ac.at — I will be happy to support you.
      </p>
      <router-link to="/chapters" class="btn-chapters">
        Go to Chapters
      </router-link>
    </div>
  </template>
  
  <script setup>
  // no imports
  </script>
  
  <style scoped>
  .home {
    text-align: center;
    margin-top: 4rem;
  }
  .book-title {
    font-size: 2.5rem;
    margin-bottom: 0.5rem;
  }
  .book-subtitle {
    font-size: 1.2rem;
    color: #555;
    margin-bottom: 1.5rem;
  }
  .book-meta {
    font-size: 1.1rem;
    color: #777;
    margin-bottom: 2rem;
  }
  .btn-chapters {
    display: inline-block;
    background: #42b983;
    color: white;
    padding: 0.75rem 1.5rem;
    border-radius: 4px;
    text-decoration: none;
    font-weight: bold;
  }
  .btn-chapters:hover {
    background: #36996f;
  }
  </style>
  
