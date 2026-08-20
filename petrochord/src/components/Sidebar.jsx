import React from 'react';
import './Sidebar.css';

export default function Sidebar({ songs, activeSong, onSelect, isOpen, onToggle }) {
  return (
    <div className={`sidebar ${isOpen ? 'open' : 'collapsed'}`}>
      <button className="sidebar-toggle" onClick={onToggle}>
        {isOpen ? '◀' : '▶'}
      </button>
      {isOpen && (
        <>
          <div className="sidebar-header">
            <h2>PETROCHORD</h2>
            <span className="subtitle">Song Generator</span>
          </div>
          <div className="song-list">
            {songs.length === 0 ? (
              <p className="empty-msg">No songs yet. Drop a file or search.</p>
            ) : (
              songs.map((song) => (
                <div
                  key={song.id}
                  className={`song-item ${activeSong?.id === song.id ? 'active' : ''}`}
                  onClick={() => onSelect(song)}
                >
                  <span className="song-icon">
                    {song.source === 'file' ? '♪' : '⌕'}
                  </span>
                  <div className="song-info">
                    <span className="song-title">{song.title}</span>
                    {song.artist && <span className="song-artist">{song.artist}</span>}
                  </div>
                  <span className={`song-status ${song.status}`}>
                    {song.status === 'pending' ? '◌' : song.status === 'ready' ? '●' : '✗'}
                  </span>
                </div>
              ))
            )}
          </div>
        </>
      )}
    </div>
  );
}
