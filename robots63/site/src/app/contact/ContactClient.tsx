"use client";

import Header from "@/components/Header";
import Footer from "@/components/Footer";
import Link from "next/link";

// ── ЗАМЕНИ ЭТИ ССЫЛКИ ──────────────────────────────────────────────────────
const CONTACTS = {
  telegram: "https://t.me/BalePa_96",
  vk: "https://vk.me/valcoin",
  max: "https://max.ru/u/f9LHodD0cOL_LJX2JIsmykAOYri5XKwJryb1RJfKqJzz0aMXnMt-5S8olcE",
};
// ────────────────────────────────────────────────────────────────────────────

const socials = [
  {
    id: "telegram",
    label: "Telegram",
    hint: "Написать напрямую — ответим быстро",
    href: CONTACTS.telegram,
    color: "#229ED9",
    bg: "#E8F6FD",
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm4.64 6.8l-1.69 7.96c-.12.55-.46.69-.94.43l-2.59-1.91-1.25 1.2c-.14.14-.26.26-.52.26l.18-2.63 4.71-4.25c.2-.18-.04-.28-.32-.1L7.51 14.83l-2.54-.79c-.55-.17-.56-.55.12-.82l9.94-3.83c.46-.17.86.11.71.41z" fill="currentColor"/>
      </svg>
    ),
  },
  {
    id: "vk",
    label: "VKontakte",
    hint: "Написать напрямую в ВК",
    href: CONTACTS.vk,
    color: "#0077FF",
    bg: "#E8F0FD",
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
        <path d="M12 2C6.477 2 2 6.477 2 12s4.477 10 10 10 10-4.477 10-10S17.523 2 12 2zm5.027 13.508h-1.372c-.52 0-.68-.414-1.61-1.37-.817-.802-1.176-.912-1.376-.912-.279 0-.359.08-.359.47v1.25c0 .333-.105.53-1.003.53-1.476 0-3.113-.898-4.266-2.572C5.57 10.934 5.1 9.06 5.1 8.68c0-.2.08-.386.47-.386h1.372c.35 0 .483.16.617.548.68 1.976 1.816 3.707 2.286 3.707.175 0 .255-.08.255-.52V9.99c-.054-.943-.55-1.022-.55-1.358 0-.16.128-.333.335-.333H12.1c.294 0 .4.16.4.51v2.74c0 .294.13.4.215.4.175 0 .321-.106.642-.427 1-.106 2.14-2.58 2.14-2.58.12-.254.335-.49.71-.49h1.372c.415 0 .506.214.415.507-.174.8-1.867 3.2-1.867 3.2-.147.24-.2.347 0 .614.147.2.63.614.952.987.588.668 1.036 1.228 1.157 1.615.107.374-.08.56-.459.56z" fill="currentColor"/>
      </svg>
    ),
  },
  {
    id: "max",
    label: "MAX",
    hint: "Написать в мессенджер MAX",
    href: CONTACTS.max,
    color: "#4A67FF",
    bg: "#EEEEFF",
    icon: (
      <svg width="28" height="28" viewBox="0 0 24 24" fill="none">
        <rect width="24" height="24" rx="12" fill="currentColor" fillOpacity="0.12"/>
        <text x="12" y="16" textAnchor="middle" fontFamily="sans-serif" fontWeight="800" fontSize="11" fill="currentColor">MAX</text>
      </svg>
    ),
  },
];

export default function ContactClient() {
  return (
    <>
      <Header />

      {/* ── HERO ── */}
      <div style={{
        background: "#0A0A0A", padding: "140px 24px 80px",
        minHeight: "60vh", display: "flex", alignItems: "center",
        position: "relative", overflow: "hidden",
      }}>
        <div style={{
          position: "absolute", inset: 0,
          background: "radial-gradient(ellipse at 50% 60%, rgba(161,98,7,0.12) 0%, transparent 60%)",
          pointerEvents: "none",
        }} />
        <div style={{ maxWidth: 640, margin: "0 auto", textAlign: "center", position: "relative", zIndex: 2 }}>
          <div style={{
            fontFamily: "var(--font-body)", fontSize: 12, fontWeight: 600,
            letterSpacing: "0.14em", textTransform: "uppercase" as const,
            color: "#A16207", marginBottom: 24,
          }}>
            Связаться с нами
          </div>
          <h1 style={{
            fontFamily: "var(--font-heading)", fontWeight: 700,
            fontSize: "clamp(40px, 6vw, 72px)", lineHeight: 1.05, marginBottom: 24,
          }}>
            <span style={{ color: "#fff" }}>Напишите </span>
            <span style={{ background: "linear-gradient(135deg, #A16207, #EAB308)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>нам</span>
          </h1>
          <p style={{
            fontFamily: "var(--font-body)", fontSize: 18,
            color: "rgba(255,255,255,0.5)", lineHeight: 1.65,
            maxWidth: 460, margin: "0 auto",
          }}>
            Выберите удобный мессенджер — обсудим задачи, подберём модель и рассчитаем стоимость
          </p>
        </div>
      </div>

      {/* ── SOCIALS ── */}
      <section style={{ padding: "80px 24px", background: "#FAFAF9" }}>
        <div style={{ maxWidth: 600, margin: "0 auto" }}>

          <div style={{
            fontFamily: "var(--font-body)", fontSize: 14, fontWeight: 500,
            color: "#888", textAlign: "center", marginBottom: 32, letterSpacing: "0.02em",
          }}>
            Напишите в любой из мессенджеров — всё обсудим
          </div>

          <div style={{ display: "flex", flexDirection: "column", gap: 14 }}>
            {socials.map((s) => (
              <a
                key={s.id}
                href={s.href}
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  display: "flex", alignItems: "center", gap: 20,
                  background: "#fff", borderRadius: 16,
                  border: "1px solid #E8E8E6", padding: "20px 24px",
                  textDecoration: "none", cursor: "pointer",
                  transition: "all 0.18s ease", boxShadow: "0 2px 12px rgba(0,0,0,0.04)",
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLElement).style.transform = "translateY(-2px)";
                  (e.currentTarget as HTMLElement).style.boxShadow = "0 8px 32px rgba(0,0,0,0.1)";
                  (e.currentTarget as HTMLElement).style.borderColor = s.color;
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLElement).style.transform = "none";
                  (e.currentTarget as HTMLElement).style.boxShadow = "0 2px 12px rgba(0,0,0,0.04)";
                  (e.currentTarget as HTMLElement).style.borderColor = "#E8E8E6";
                }}
              >
                <div style={{
                  width: 52, height: 52, borderRadius: 14,
                  background: s.bg, color: s.color,
                  display: "flex", alignItems: "center", justifyContent: "center",
                  flexShrink: 0,
                }}>
                  {s.icon}
                </div>
                <div style={{ flex: 1 }}>
                  <div style={{
                    fontFamily: "var(--font-heading)", fontWeight: 600,
                    fontSize: 18, color: "#0A0A0A", letterSpacing: "-0.01em",
                    marginBottom: 2,
                  }}>
                    {s.label}
                  </div>
                  <div style={{
                    fontFamily: "var(--font-body)", fontSize: 14, color: "#888",
                  }}>
                    {s.hint}
                  </div>
                </div>
                <div style={{ color: "#C8C8C8", flexShrink: 0 }}>
                  <svg width="20" height="20" viewBox="0 0 20 20" fill="none">
                    <path d="M7.5 5l5 5-5 5" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                </div>
              </a>
            ))}
          </div>

          {/* Divider */}
          <div style={{ display: "flex", alignItems: "center", gap: 16, margin: "40px 0" }}>
            <div style={{ flex: 1, height: 1, background: "#E8E8E6" }} />
            <span style={{ fontFamily: "var(--font-body)", fontSize: 13, color: "#AAA" }}>или</span>
            <div style={{ flex: 1, height: 1, background: "#E8E8E6" }} />
          </div>

          {/* Info block */}
          <div style={{
            background: "#fff", borderRadius: 16, border: "1px solid #E8E8E6",
            padding: "32px", textAlign: "center",
          }}>
            <div style={{
              fontFamily: "var(--font-heading)", fontWeight: 600,
              fontSize: 20, color: "#0A0A0A", marginBottom: 8, letterSpacing: "-0.02em",
            }}>
              Работаем по всему СНГ
            </div>
            <div style={{
              fontFamily: "var(--font-body)", fontSize: 14, color: "#888",
              lineHeight: 1.7, marginBottom: 24,
            }}>
              Россия · Казахстан · Беларусь · Узбекистан
            </div>
            <div style={{
              fontFamily: "var(--font-body)", fontSize: 14, color: "#555",
              lineHeight: 1.8,
            }}>
              Берём на себя таможню, доставку и техподдержку.<br/>
              Отвечаем в течение рабочего дня.
            </div>
          </div>

          <div style={{ textAlign: "center", marginTop: 28 }}>
            <Link href="/catalog" style={{
              fontFamily: "var(--font-body)", fontSize: 14,
              color: "#A16207", textDecoration: "none",
              fontWeight: 600, letterSpacing: "0.04em",
            }}>
              ← Вернуться в каталог
            </Link>
          </div>
        </div>
      </section>

      {/* ── FOOTER SOCIALS STRIP ── */}
      <section style={{
        background: "#0A0A0A", padding: "48px 24px",
        borderTop: "1px solid rgba(255,255,255,0.06)",
      }}>
        <div style={{ maxWidth: 800, margin: "0 auto", textAlign: "center" }}>
          <div style={{
            fontFamily: "var(--font-body)", fontSize: 13, color: "rgba(255,255,255,0.35)",
            letterSpacing: "0.08em", textTransform: "uppercase" as const, marginBottom: 24,
          }}>
            Мы в мессенджерах
          </div>
          <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" }}>
            {socials.map((s) => (
              <a
                key={s.id}
                href={s.href}
                target="_blank"
                rel="noopener noreferrer"
                style={{
                  display: "flex", alignItems: "center", gap: 10,
                  background: "rgba(255,255,255,0.06)",
                  border: "1px solid rgba(255,255,255,0.1)",
                  borderRadius: 100, padding: "10px 20px",
                  textDecoration: "none", color: "#fff",
                  fontFamily: "var(--font-body)", fontWeight: 500, fontSize: 14,
                  transition: "all 0.18s ease",
                }}
                onMouseEnter={(e) => {
                  (e.currentTarget as HTMLElement).style.background = s.color;
                  (e.currentTarget as HTMLElement).style.borderColor = s.color;
                }}
                onMouseLeave={(e) => {
                  (e.currentTarget as HTMLElement).style.background = "rgba(255,255,255,0.06)";
                  (e.currentTarget as HTMLElement).style.borderColor = "rgba(255,255,255,0.1)";
                }}
              >
                <span style={{ color: s.color, display: "flex" }}>{s.icon}</span>
                {s.label}
              </a>
            ))}
          </div>
          <div style={{
            fontFamily: "var(--font-body)", fontSize: 14,
            color: "rgba(255,255,255,0.35)", marginTop: 20,
          }}>
            Напишите нам — всё обсудим
          </div>
        </div>
      </section>

      <Footer />
    </>
  );
}
