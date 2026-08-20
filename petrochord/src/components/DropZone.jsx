import React, { useState, useCallback } from 'react';
import './DropZone.css';

const AUDIO_TYPES = ['audio/mpeg', 'audio/wav', 'audio/flac', 'audio/ogg', 'audio/mp4', 'audio/aac'];

export default function DropZone({ onFileDrop }) {
  const [dragging, setDragging] = useState(false);

  const handleDragOver = useCallback((e) => {
    e.preventDefault();
    setDragging(true);
  }, []);

  const handleDragLeave = useCallback(() => {
    setDragging(false);
  }, []);

  const handleDrop = useCallback((e) => {
    e.preventDefault();
    setDragging(false);
    const file = e.dataTransfer.files[0];
    if (file && (AUDIO_TYPES.includes(file.type) || file.name.match(/\.(mp3|wav|flac|ogg|m4a|aac)$/i))) {
      onFileDrop(file);
    }
  }, [onFileDrop]);

  const handleClick = useCallback(() => {
    const input = document.createElement('input');
    input.type = 'file';
    input.accept = 'audio/*';
    input.onchange = (e) => {
      const file = e.target.files[0];
      if (file) onFileDrop(file);
    };
    input.click();
  }, [onFileDrop]);

  return (
    <div
      className={`dropzone ${dragging ? 'dragging' : ''}`}
      onDragOver={handleDragOver}
      onDragLeave={handleDragLeave}
      onDrop={handleDrop}
      onClick={handleClick}
    >
      <div className="dropzone-content">
        <div className="dropzone-icon">♪</div>
        <p className="dropzone-title">Drop audio file here</p>
        <p className="dropzone-hint">or click to browse</p>
        <p className="dropzone-formats">MP3, WAV, FLAC, OGG, M4A</p>
      </div>
    </div>
  );
}
