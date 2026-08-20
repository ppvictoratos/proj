import React from 'react';
import './ComplexitySlider.css';

const LEVELS = ['simple', 'moderate', 'complex'];

export default function ComplexitySlider({ value, onChange }) {
  return (
    <div className="complexity-slider">
      <span className="complexity-label">COMPLEXITY</span>
      <div className="complexity-buttons">
        {LEVELS.map((level) => (
          <button
            key={level}
            className={`complexity-btn ${value === level ? 'active' : ''}`}
            onClick={() => onChange(level)}
          >
            {level.toUpperCase()}
          </button>
        ))}
      </div>
    </div>
  );
}
