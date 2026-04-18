"use client";

import { useState, useRef } from "react";

export default function VideoShowcase() {
  const [playing, setPlaying] = useState(false);
  const videoRef = useRef<HTMLVideoElement>(null);

  const handlePlay = () => {
    setPlaying(true);
    videoRef.current?.play();
  };

  return (
    <section style={{ padding: "80px 24px", background: "#0A0A0A", borderTop: "1px solid rgba(255,255,255,0.08)" }}>
      <div style={{ maxWidth: 720, margin: "0 auto" }}>

        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 32 }}>
          <div style={{
            fontFamily: "var(--font-body)", fontSize: 12, fontWeight: 500,
            letterSpacing: "0.08em", color: "rgba(255,255,255,0.3)",
            textTransform: "uppercase" as const, marginBottom: 12,
          }}>
            В действии
          </div>
          <h2 style={{
            fontFamily: "var(--font-heading)", fontWeight: 600,
            fontSize: "clamp(22px, 3vw, 32px)", color: "#fff",
            letterSpacing: "-0.03em", lineHeight: 1.1,
          }}>
            Роботы в реальной работе
          </h2>
        </div>

        {/* Video player */}
        <div style={{ position: "relative", borderRadius: 16, overflow: "hidden", background: "#000", boxShadow: "0 24px 60px rgba(0,0,0,0.7)" }}>
          <video
            ref={videoRef}
            src="/video/showcase.mp4"
            loop
            playsInline
            preload="none"
            controls={playing}
            title="Роботы ROBOTS63 в действии"
            style={{ width: "100%", display: "block", aspectRatio: "16/9" }}
          />

          {/* Play button overlay */}
          {!playing && (
            <div
              onClick={handlePlay}
              style={{
                position: "absolute", inset: 0,
                display: "flex", alignItems: "center", justifyContent: "center",
                cursor: "pointer",
                background: "rgba(0,0,0,0.35)",
                transition: "background 0.2s",
              }}
              onMouseEnter={e => (e.currentTarget.style.background = "rgba(0,0,0,0.2)")}
              onMouseLeave={e => (e.currentTarget.style.background = "rgba(0,0,0,0.35)")}
            >
              <div style={{
                width: 64, height: 64, borderRadius: "50%",
                background: "rgba(255,255,255,0.95)",
                display: "flex", alignItems: "center", justifyContent: "center",
                boxShadow: "0 8px 32px rgba(0,0,0,0.4)",
                transition: "transform 0.2s",
              }}>
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none">
                  <path d="M6 4l14 8-14 8V4z" fill="#0A0A0A"/>
                </svg>
              </div>
            </div>
          )}
        </div>
      </div>
    </section>
  );
}
