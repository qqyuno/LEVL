"use client";

export default function VideoShowcase() {
  return (
    <section style={{ padding: "100px 24px", background: "#0A0A0A", borderTop: "1px solid rgba(255,255,255,0.08)" }}>
      <div style={{ maxWidth: 1200, margin: "0 auto" }}>
        {/* Header */}
        <div style={{ textAlign: "center", marginBottom: 48 }}>
          <div style={{
            fontFamily: "var(--font-body)", fontSize: 13, fontWeight: 500,
            letterSpacing: "0.06em", color: "rgba(255,255,255,0.35)",
            textTransform: "uppercase", marginBottom: 16,
          }}>
            В действии
          </div>
          <h2 style={{
            fontFamily: "var(--font-heading)", fontWeight: 600,
            fontSize: "clamp(28px, 4vw, 44px)", color: "#fff",
            letterSpacing: "-0.03em", lineHeight: 1.1, marginBottom: 16,
          }}>
            Роботы в реальной работе
          </h2>
          <p style={{
            fontFamily: "var(--font-body)", fontSize: 16,
            color: "rgba(255,255,255,0.4)", maxWidth: 440, margin: "0 auto", lineHeight: 1.6,
          }}>
            Смотрите на что способны современные роботы с ИИ прямо сейчас
          </p>
        </div>

        {/* Video */}
        <div style={{
          borderRadius: 20, overflow: "hidden",
          border: "1px solid rgba(255,255,255,0.08)",
          background: "#000",
          boxShadow: "0 40px 80px rgba(0,0,0,0.6)",
        }}>
          <video
            src="/video/showcase.mp4"
            autoPlay
            muted
            loop
            playsInline
            style={{ width: "100%", display: "block" }}
          />
        </div>
      </div>
    </section>
  );
}
