"use client";

import { useState, useEffect } from "react";
import Link from "next/link";

export default function CookieBanner() {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const consent = localStorage.getItem("cookie_consent");
    if (!consent) setVisible(true);
  }, []);

  const accept = () => {
    localStorage.setItem("cookie_consent", "accepted");
    setVisible(false);
    // Активируем Яндекс.Метрику после согласия
    if (typeof window !== "undefined" && (window as any).ym) {
      (window as any).ym(process.env.NEXT_PUBLIC_METRICA_ID, "init", {
        clickmap: true,
        trackLinks: true,
        accurateTrackBounce: true,
        webvisor: true,
      });
    }
  };

  const decline = () => {
    localStorage.setItem("cookie_consent", "declined");
    setVisible(false);
  };

  if (!visible) return null;

  return (
    <div style={{
      position: "fixed", bottom: 24, left: "50%", transform: "translateX(-50%)",
      zIndex: 9999, width: "calc(100% - 48px)", maxWidth: 560,
      background: "#0A0A0A", borderRadius: 16,
      border: "1px solid rgba(255,255,255,0.1)",
      boxShadow: "0 24px 80px rgba(0,0,0,0.5)",
      padding: "20px 24px",
      display: "flex", alignItems: "center", gap: 20,
      flexWrap: "wrap",
      animation: "slideUp 0.4s cubic-bezier(0.16,1,0.3,1)",
    }}>
      <style>{`
        @keyframes slideUp {
          from { opacity: 0; transform: translateX(-50%) translateY(20px); }
          to   { opacity: 1; transform: translateX(-50%) translateY(0); }
        }
      `}</style>

      <div style={{ flex: 1, minWidth: 200 }}>
        <div style={{
          fontFamily: "var(--font-body), sans-serif",
          fontWeight: 600, fontSize: 14, color: "#fff", marginBottom: 4,
        }}>
          Мы используем cookies
        </div>
        <div style={{
          fontFamily: "var(--font-body), sans-serif",
          fontSize: 13, color: "rgba(255,255,255,0.45)", lineHeight: 1.5,
        }}>
          Для аналитики и улучшения сайта.{" "}
            <Link href="/privacy" style={{ color: "rgba(255,255,255,0.6)", textDecoration: "underline" }}>Подробнее</Link>
        </div>
      </div>

      <div style={{ display: "flex", gap: 8, flexShrink: 0 }}>
        <button
          onClick={decline}
          style={{
            fontFamily: "var(--font-body), sans-serif",
            fontSize: 13, fontWeight: 500,
            color: "rgba(255,255,255,0.4)",
            background: "transparent", border: "none",
            padding: "8px 14px", cursor: "pointer", borderRadius: 8,
            transition: "color 0.15s",
          }}
          onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = "rgba(255,255,255,0.7)"; }}
          onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = "rgba(255,255,255,0.4)"; }}
        >
          Отклонить
        </button>
        <button
          onClick={accept}
          style={{
            fontFamily: "var(--font-body), sans-serif",
            fontSize: 13, fontWeight: 600,
            color: "#0A0A0A", background: "#fff",
            border: "none", padding: "8px 20px",
            borderRadius: 8, cursor: "pointer",
            transition: "all 0.15s",
          }}
          onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.background = "#E8E8E8"; }}
          onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.background = "#fff"; }}
        >
          Принять
        </button>
      </div>
    </div>
  );
}
