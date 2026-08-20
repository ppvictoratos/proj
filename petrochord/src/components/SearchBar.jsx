import React, { useState } from 'react';
import './SearchBar.css';

export default function SearchBar({ onSearch }) {
  const [query, setQuery] = useState('');

  const handleSubmit = (e) => {
    e.preventDefault();
    onSearch(query);
    setQuery('');
  };

  return (
    <form className="search-bar" onSubmit={handleSubmit}>
      <span className="search-icon">⌕</span>
      <input
        type="text"
        className="search-input"
        placeholder="Search song name..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
    </form>
  );
}
