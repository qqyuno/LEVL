"use client";

import Link from "next/link";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer style={{
      background: "var(--bg-soft)", borderTop: "1px solid var(--border)",
      padding: "64px 24px 32px",
    }}>
      <div style={{ maxWidth: 1200, margin: "0 auto" }}>
        <div style={{
          display: "grid", gridTemplateColumns: "1.5fr 1fr 1fr 1fr",
          gap: 40, marginBottom: 56,
        }} className="footer-grid">

          {/* Brand */}
          <div>
            <Link href="/" aria-label="ROBOTS63 — Главная" style={{ textDecoration: "none", display: "inline-block", marginBottom: 16 }}>
              <span style={{
                fontFamily: "var(--font-heading), sans-serif",
                fontWeight: 700, fontSize: 20, letterSpacing: "-0.03em",
                color: "var(--fg)",
              }}>ROBOTS63</span>
            </Link>
            <p style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 14,
              color: "var(--fg-muted)", lineHeight: 1.7, maxWidth: 240,
            }}>
              Официальный дистрибьютор гуманоидных роботов и робособак с ИИ по всему СНГ.
            </p>
          </div>

          {/* Каталог */}
          <div>
            <div style={{
              fontFamily: "var(--font-body), sans-serif", fontWeight: 600,
              fontSize: 13, color: "var(--fg)", marginBottom: 16,
            }}>
              Каталог
            </div>
            <Link href="/catalog?category=humanoid" className="footer-link">Гуманоиды</Link>
            <Link href="/catalog?category=robot-dog" className="footer-link">Робособаки</Link>
            <Link href="/catalog" className="footer-link">Все модели</Link>
          </div>

          {/* Бренды */}
          <div>
            <div style={{
              fontFamily: "var(--font-body), sans-serif", fontWeight: 600,
              fontSize: 13, color: "var(--fg)", marginBottom: 16,
            }}>
              Бренды
            </div>
            {["Unitree", "AgiBot", "Deep Robotics"].map((brand) => (
              <Link
                key={brand}
                href={`/catalog?brand=${encodeURIComponent(brand)}`}
                className="footer-link"
              >
                {brand}
              </Link>
            ))}
          </div>

          {/* Контакты */}
          <div>
            <div style={{
              fontFamily: "var(--font-body), sans-serif", fontWeight: 600,
              fontSize: 13, color: "var(--fg)", marginBottom: 16,
            }}>
              Контакты
            </div>
            {[
              { label: "Telegram", href: "https://t.me/BalePa_96", color: "#229ED9" },
              { label: "VKontakte", href: "https://vk.me/valcoin", color: "#0077FF" },
              { label: "MAX", href: "https://max.ru/u/f9LHodD0cOL_LJX2JIsmykAOYri5XKwJryb1RJfKqJzz0aMXnMt-5S8olcE", color: "#4A67FF" },
            ].map((s) => (
              <a
                key={s.label}
                href={s.href}
                target="_blank"
                rel="noopener noreferrer"
                className="footer-link"
                style={{ display: "block", color: s.color, fontWeight: 500 }}
              >
                {s.label}
              </a>
            ))}
            <div style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 13,
              color: "var(--fg-muted)", lineHeight: 1.6, marginTop: 16,
            }}>
              Россия · Казахстан · Беларусь
            </div>
          </div>
        </div>

        {/* Divider */}
        <div style={{ height: 1, background: "var(--border)", marginBottom: 24 }} />

        {/* Bottom */}
        <div style={{
          display: "flex", justifyContent: "space-between",
          alignItems: "center", flexWrap: "wrap" as const, gap: 12,
        }}>
          <span style={{
            fontFamily: "var(--font-body), sans-serif", fontSize: 13,
            color: "var(--fg-muted)",
          }}>
            &copy; {currentYear} ROBOTS63
          </span>
          <div style={{ display: "flex", gap: 20, flexWrap: "wrap" as const }}>
            {[
              { href: "/catalog", label: "Каталог" },
              { href: "/about", label: "О компании" },
              { href: "/contact", label: "Контакты" },
              { href: "/privacy", label: "Конфиденциальность" },
              { href: "/terms", label: "Соглашение" },
            ].map((item) => (
              <Link key={item.href} href={item.href} className="footer-link" style={{ margin: 0 }}>
                {item.label}
              </Link>
            ))}
          </div>
        </div>
      </div>

      <style>{`
        @media (max-width: 900px) {
          .footer-grid { grid-template-columns: 1fr 1fr !important; gap: 32px !important; }
        }
        @media (max-width: 560px) {
          .footer-grid { grid-template-columns: 1fr !important; }
        }
      `}</style>
    </footer>
  );
}
