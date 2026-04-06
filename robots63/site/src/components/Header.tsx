"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
export default function Header() {
  const [scrolled, setScrolled] = useState(false);
  const [menuOpen, setMenuOpen] = useState(false);
  const pathname = usePathname();

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 20);
    window.addEventListener("scroll", onScroll);
    return () => window.removeEventListener("scroll", onScroll);
  }, []);

  useEffect(() => { setMenuOpen(false); }, [pathname]);

  const navLinks = [
    { href: "/catalog", label: "Каталог" },
    { href: "/catalog?category=humanoid", label: "Гуманоиды" },
    { href: "/catalog?category=robot-dog", label: "Робособаки" },
  ];

  return (
    <header style={{
      position: "fixed", top: 0, left: 0, right: 0, zIndex: 100,
      background: scrolled ? "rgba(255,255,255,0.95)" : "rgba(10,10,10,0.4)",
      backdropFilter: "blur(20px)",
      WebkitBackdropFilter: "blur(20px)",
      borderBottom: scrolled ? "1px solid rgba(0,0,0,0.06)" : "1px solid rgba(255,255,255,0.08)",
      transition: "all 0.4s ease",
    }}>
      <div style={{
        maxWidth: 1200, margin: "0 auto", padding: "0 24px",
        height: 64, display: "flex", alignItems: "center", justifyContent: "space-between"
      }}>

        <Link href="/" style={{ textDecoration: "none" }} aria-label="ROBOTS63 — Главная">
          <span style={{
            fontFamily: "var(--font-heading), sans-serif",
            fontWeight: 700,
            fontSize: 20,
            letterSpacing: "-0.03em",
            color: scrolled ? "#0A0A0A" : "#fff",
            transition: "color 0.4s ease",
          }}>
            ROBOTS63
          </span>
        </Link>

        <nav style={{ display: "flex", alignItems: "center", gap: 4 }} className="desktop-nav" aria-label="Основная навигация">
          {navLinks.map((item) => (
            <Link
              key={item.href}
              href={item.href}
              className={`nav-link ${pathname === item.href ? "nav-link-active" : ""}`}
              style={{ color: scrolled ? undefined : "rgba(255,255,255,0.75)" }}
            >
              {item.label}
            </Link>
          ))}

          <Link href="/contact" style={{
            marginLeft: 12, padding: "10px 24px", fontSize: 14,
            fontFamily: "var(--font-body), sans-serif", fontWeight: 500,
            textDecoration: "none", borderRadius: 100,
            background: scrolled ? "#0A0A0A" : "#fff",
            color: scrolled ? "#fff" : "#0A0A0A",
            transition: "all 0.4s ease",
          }}>
            Связаться
          </Link>
        </nav>

        <button
          className="burger-btn"
          onClick={() => setMenuOpen(!menuOpen)}
          style={{ background: "none", border: "none", cursor: "pointer", padding: 8, display: "none", flexDirection: "column" as const, gap: 5 }}
          aria-label={menuOpen ? "Закрыть меню" : "Открыть меню"}
          aria-expanded={menuOpen}
        >
          {[0, 1, 2].map((i) => (
            <span key={i} style={{
              display: "block", width: 20, height: 1.5, background: "#1A1A1A", borderRadius: 2,
              transition: "all 0.3s var(--ease-out)",
              transform: menuOpen && i === 0 ? "rotate(45deg) translate(4px,4px)" : menuOpen && i === 2 ? "rotate(-45deg) translate(4px,-4px)" : "none",
              opacity: menuOpen && i === 1 ? 0 : 1,
            }} />
          ))}
        </button>
      </div>

      <div style={{
        background: "rgba(255,255,255,0.98)",
        backdropFilter: "blur(20px)",
        borderTop: menuOpen ? "1px solid rgba(0,0,0,0.06)" : "1px solid transparent",
        padding: menuOpen ? "12px 24px 20px" : "0 24px",
        maxHeight: menuOpen ? 300 : 0,
        overflow: "hidden",
        transition: "max-height 0.4s var(--ease-out), padding 0.3s ease",
      }}>
        {[...navLinks, { href: "/contact", label: "Связаться" }].map((item, i) => (
          <Link
            key={item.href}
            href={item.href}
            style={{
              display: "block",
              fontFamily: "var(--font-body), sans-serif", fontWeight: 450,
              fontSize: 16, color: i === navLinks.length ? "var(--fg)" : "var(--fg-secondary)",
              textDecoration: "none",
              padding: "14px 0",
              borderBottom: i < navLinks.length ? "1px solid var(--border-light)" : "none",
            }}
          >
            {item.label}
          </Link>
        ))}
      </div>

      <style>{`
        @media (max-width: 768px) {
          .desktop-nav { display: none !important; }
          .burger-btn { display: flex !important; }
        }
      `}</style>
    </header>
  );
}
