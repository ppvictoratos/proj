import React from 'react';
import './TabViewer.css';

export default function TabViewer({ song, complexity }) {
  const tabs = song.tabs?.[complexity];

  if (!tabs) {
    return (
      <div className="tab-viewer">
        <p className="no-tabs">No tabs available for {complexity} complexity.</p>
      </div>
    );
  }

  return (
    <div className="tab-viewer">
      <div className="container">
        <h1 className="tab-title">{tabs.title}</h1>
        <p className="tab-artist">{tabs.artist}</p>

        <div className="metadata">
          {tabs.key && <span>Key: {tabs.key}</span>}
          {tabs.tempo && <span>Tempo: {tabs.tempo} BPM</span>}
          {tabs.tuning && <span>Tuning: {tabs.tuning}</span>}
          {tabs.capo && <span>Capo: {tabs.capo}</span>}
        </div>

        {tabs.sections?.map((section, i) => (
          <div key={i} className="section">
            <h3 className="section-title">{section.name}</h3>
            {section.progression && (
              <div className="progression">{section.progression}</div>
            )}
            {section.tab && (
              <pre className="tabs">{section.tab}</pre>
            )}
            {section.description && (
              <p className="description">{section.description}</p>
            )}
          </div>
        ))}

        {tabs.chords && (
          <div className="section">
            <h3 className="section-title">All Chords Used</h3>
            {tabs.chords.map((chord, i) => (
              <div key={i}>
                <p className="chord-name">{chord.name}</p>
                <pre className="tabs">{chord.diagram}</pre>
              </div>
            ))}
          </div>
        )}

        {tabs.structure && (
          <div className="section">
            <h3 className="section-title">Song Structure</h3>
            <div className="progression">{tabs.structure}</div>
          </div>
        )}

        {tabs.tips && (
          <div className="section">
            <h3 className="section-title">Practice Tips</h3>
            {tabs.tips.map((tip, i) => (
              <p key={i} className="description">• {tip}</p>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
