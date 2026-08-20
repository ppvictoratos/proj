import React, { useState, useCallback } from 'react';
import Sidebar from './components/Sidebar';
import DropZone from './components/DropZone';
import SearchBar from './components/SearchBar';
import ComplexitySlider from './components/ComplexitySlider';
import TabViewer from './components/TabViewer';
import './App.css';

export default function App() {
  const [songs, setSongs] = useState([]);
  const [activeSong, setActiveSong] = useState(null);
  const [complexity, setComplexity] = useState('moderate');
  const [sidebarOpen, setSidebarOpen] = useState(true);

  const addSong = useCallback((song) => {
    setSongs((prev) => [...prev, song]);
    setActiveSong(song);
  }, []);

  const handleFileDrop = useCallback((file) => {
    const song = {
      id: Date.now(),
      title: file.name.replace(/\.[^/.]+$/, ''),
      artist: 'Unknown',
      source: 'file',
      file,
      tabs: null,
      status: 'pending',
    };
    addSong(song);
  }, [addSong]);

  const handleSearch = useCallback((query) => {
    if (!query.trim()) return;
    const song = {
      id: Date.now(),
      title: query,
      artist: '',
      source: 'search',
      tabs: null,
      status: 'pending',
    };
    addSong(song);
  }, [addSong]);

  return (
    <div className="app">
      <Sidebar
        songs={songs}
        activeSong={activeSong}
        onSelect={setActiveSong}
        isOpen={sidebarOpen}
        onToggle={() => setSidebarOpen(!sidebarOpen)}
      />
      <main className={`main-content ${sidebarOpen ? '' : 'expanded'}`}>
        <header className="top-bar">
          <SearchBar onSearch={handleSearch} />
          <ComplexitySlider value={complexity} onChange={setComplexity} />
        </header>
        <div className="center-area">
          {activeSong?.tabs ? (
            <TabViewer song={activeSong} complexity={complexity} />
          ) : (
            <DropZone onFileDrop={handleFileDrop} />
          )}
        </div>
      </main>
    </div>
  );
}
