"use client";

import { useEffect, useRef, useState } from "react";
import Link from "next/link";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import ProductCard from "@/components/ProductCard";
import ShaderLines from "@/components/ShaderLines";
import { SplineScene } from "@/components/ui/splite";
import { Spotlight } from "@/components/ui/spotlight";
import type { Product } from "@/lib/products";

function useInView(threshold = 0.12) {
  const ref = useRef<HTMLDivElement>(null);
  const [inView, setInView] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el) return;
    const obs = new IntersectionObserver(([e]) => { if (e.isIntersecting) setInView(true); }, { threshold });
    obs.observe(el);
    return () => obs.disconnect();
  }, [threshold]);
  return { ref, inView };
}

function FadeIn({ children, delay = 0, className }: { children: React.ReactNode; delay?: number; className?: string }) {
  const { ref, inView } = useInView();
  return (
    <div ref={ref} className={className} style={{
      transition: `opacity 0.7s var(--ease-out) ${delay}ms, transform 0.7s var(--ease-out) ${delay}ms`,
      opacity: inView ? 1 : 0,
      transform: inView ? "translateY(0)" : "translateY(24px)",
    }}>{children}</div>
  );
}

interface Props {
  humanoids: Product[];
  robotDogs: Product[];
}

export default function HomeClient({ humanoids, robotDogs }: Props) {
  const [heroReady, setHeroReady] = useState(false);
  useEffect(() => { setTimeout(() => setHeroReady(true), 100); }, []);

  return (
    <>
      <Header />

      {/* ═══════ HERO ═══════ */}
      <section className="relative min-h-screen overflow-hidden bg-black/[0.96] flex items-center">
        {/* Shader lines bg */}
        <div className="absolute inset-0 z-0">
          <ShaderLines opacity={0.1} />
        </div>

        {/* Spotlight */}
        <Spotlight
          className="-top-40 left-0 md:left-60 md:-top-20"
          fill="white"
        />

        <div className="relative z-10 max-w-[1200px] mx-auto px-6 py-32 w-full">
          <div className="hero-grid grid grid-cols-1 md:grid-cols-2 gap-10 items-center">
            {/* Left — text */}
            <div style={{
              opacity: heroReady ? 1 : 0,
              transform: heroReady ? "none" : "translateY(30px)",
              transition: "all 0.8s cubic-bezier(0.16, 1, 0.3, 1) 0.2s",
            }}>
              <div className="inline-flex items-center gap-2 rounded-full px-4 py-1.5 mb-8 border border-white/10 bg-white/5">
                <div className="w-1.5 h-1.5 rounded-full bg-green-500" />
                <span className="text-[13px] font-medium text-white/60" style={{ fontFamily: "var(--font-body)" }}>
                  Официальный дистрибьютор в СНГ
                </span>
              </div>

              <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold bg-clip-text text-transparent bg-gradient-to-b from-neutral-50 to-neutral-400 mb-3" style={{
                fontFamily: "var(--font-heading)",
                letterSpacing: "-0.03em",
                lineHeight: 1.05,
              }}>
                Гуманоидные роботы и робособаки
              </h1>

              <p className="text-xl md:text-2xl mb-6" style={{
                fontFamily: "var(--font-heading)",
                color: "rgba(255,255,255,0.35)",
                letterSpacing: "-0.02em",
                fontStyle: "italic",
              }}>
                Роботы, которые меняют мир
              </p>

              <p className="text-base md:text-lg text-neutral-400 max-w-lg mb-10" style={{
                fontFamily: "var(--font-body)",
                lineHeight: 1.65,
              }}>
                Передовые роботы с ИИ от ведущих мировых производителей. Официальные поставки и поддержка по всему СНГ.
              </p>

              <div className="flex gap-3 flex-wrap">
                <Link href="/catalog" className="inline-flex items-center gap-2 rounded-full px-7 py-3.5 text-[15px] font-medium bg-white text-black no-underline hover:bg-white/90 transition-all" style={{ fontFamily: "var(--font-body)" }}>
                  Смотреть каталог
                  <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
                </Link>
                <Link href="/contact" className="inline-flex items-center gap-2 rounded-full px-7 py-3.5 text-[15px] font-medium text-white/80 border border-white/15 no-underline hover:bg-white/5 transition-all" style={{ fontFamily: "var(--font-body)" }}>
                  Оставить заявку
                </Link>
              </div>
            </div>

            {/* Right — Spline 3D */}
            <div className="relative w-full h-[350px] md:h-[520px]" style={{
              opacity: heroReady ? 1 : 0,
              transform: heroReady ? "none" : "scale(0.95)",
              transition: "all 1s cubic-bezier(0.16, 1, 0.3, 1) 0.4s",
            }}>
              <SplineScene
                scene="https://prod.spline.design/kZDDjO5HuC9GJUM2/scene.splinecode"
                className="w-full h-full"
              />
            </div>
          </div>

          {/* Stats bar */}
          <div className="grid grid-cols-2 md:grid-cols-4 mt-16 rounded-2xl overflow-hidden" style={{
            background: "rgba(255,255,255,0.05)",
            opacity: heroReady ? 1 : 0,
            transform: heroReady ? "none" : "translateY(24px)",
            transition: "all 0.7s cubic-bezier(0.16, 1, 0.3, 1) 0.6s",
          }}>
            {[
              { num: "10+", label: "Моделей в каталоге" },
              { num: "5+", label: "Мировых брендов" },
              { num: "100%", label: "Официальные поставки" },
              { num: "СНГ", label: "Россия и весь СНГ" },
            ].map((s) => (
              <div key={s.label} className="text-center py-7 px-6" style={{ background: "rgba(255,255,255,0.02)" }}>
                <div className="text-3xl font-semibold text-white mb-1" style={{
                  fontFamily: "var(--font-heading)", letterSpacing: "-0.02em",
                }}>
                  {s.num}
                </div>
                <div className="text-[13px] text-white/35" style={{ fontFamily: "var(--font-body)" }}>
                  {s.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════ ГУМАНОИДЫ ═══════ */}
      <section style={{ padding: "100px 24px", background: "var(--bg-soft)", borderTop: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <FadeIn>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 48, flexWrap: "wrap" as const, gap: 16 }}>
              <div>
                <div className="section-label">Каталог</div>
                <h2 className="section-title">Гуманоидные роботы</h2>
                <p style={{ fontFamily: "var(--font-body)", fontSize: 16, color: "var(--fg-secondary)", maxWidth: 420, marginTop: 12, lineHeight: 1.6 }}>
                  Автономные гуманоиды с ИИ для промышленности, исследований и сервиса
                </p>
              </div>
              <Link href="/catalog?category=humanoid" className="btn-secondary" style={{ padding: "10px 20px", fontSize: 14 }}>
                Все гуманоиды
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </Link>
            </div>
          </FadeIn>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 20 }}>
            {humanoids.slice(0, 4).map((p, i) => <FadeIn key={p.id} delay={i * 80}><ProductCard product={p} /></FadeIn>)}
          </div>
        </div>
      </section>

      {/* ═══════ ABOUT ═══════ */}
      <section style={{ padding: "100px 24px", background: "#fff" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <FadeIn>
            <div style={{ maxWidth: 560, marginBottom: 56 }}>
              <div className="section-label">О компании</div>
              <h2 className="section-title" style={{ marginBottom: 20 }}>
                Почему ROBOTS63
              </h2>
              <p style={{ fontFamily: "var(--font-body)", fontSize: 17, color: "var(--fg-secondary)", lineHeight: 1.7 }}>
                Работаем напрямую с производителями — полный цикл от консультации до технической поддержки на месте.
              </p>
            </div>
          </FadeIn>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(240px, 1fr))", gap: 16 }}>
            {[
              { icon: "01", title: "Прямые поставки", desc: "Работаем напрямую с Unitree, AgiBot и Deep Robotics — без посредников и переплат" },
              { icon: "02", title: "Доставка по СНГ", desc: "Россия, Казахстан, Беларусь, Узбекистан — полная логистика и таможенное оформление" },
              { icon: "03", title: "Техподдержка", desc: "Настройка, обучение персонала и гарантийное обслуживание на протяжении всего цикла" },
              { icon: "04", title: "Только с ИИ", desc: "Каждая модель с машинным обучением, компьютерным зрением и автономной навигацией" },
            ].map((item, i) => (
              <FadeIn key={item.title} delay={i * 80}>
                <div style={{
                  padding: "32px 24px", borderRadius: 16,
                  border: "1px solid var(--border)", background: "#fff",
                  transition: "border-color 0.3s var(--ease-out), transform 0.3s var(--ease-out)",
                }} className="highlight-card">
                  <div style={{
                    fontFamily: "var(--font-mono), monospace", fontSize: 13, fontWeight: 600,
                    color: "var(--fg-muted)", marginBottom: 16,
                  }}>{item.icon}</div>
                  <div style={{
                    fontFamily: "var(--font-heading)", fontWeight: 600, fontSize: 17,
                    color: "var(--fg)", marginBottom: 8, letterSpacing: "-0.01em",
                  }}>{item.title}</div>
                  <div style={{
                    fontFamily: "var(--font-body)", fontSize: 14,
                    color: "var(--fg-secondary)", lineHeight: 1.6,
                  }}>{item.desc}</div>
                </div>
              </FadeIn>
            ))}
          </div>
        </div>
      </section>

      {/* ═══════ РОБОСОБАКИ ═══════ */}
      <section style={{ padding: "100px 24px", background: "var(--bg-soft)", borderTop: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <FadeIn>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 48, flexWrap: "wrap" as const, gap: 16 }}>
              <div>
                <div className="section-label">Каталог</div>
                <h2 className="section-title">Робособаки</h2>
                <p style={{ fontFamily: "var(--font-body)", fontSize: 16, color: "var(--fg-secondary)", maxWidth: 420, marginTop: 12, lineHeight: 1.6 }}>
                  Четырёхногие роботы для инспекции, патрулирования и промышленных задач
                </p>
              </div>
              <Link href="/catalog?category=robot-dog" className="btn-secondary" style={{ padding: "10px 20px", fontSize: 14 }}>
                Все робособаки
                <svg width="14" height="14" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </Link>
            </div>
          </FadeIn>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 20 }}>
            {robotDogs.slice(0, 4).map((p, i) => <FadeIn key={p.id} delay={i * 80}><ProductCard product={p} /></FadeIn>)}
          </div>
        </div>
      </section>

      {/* ═══════ BRANDS ═══════ */}
      <section style={{ padding: "80px 24px", background: "#fff", borderTop: "1px solid var(--border)" }}>
        <FadeIn>
          <div style={{ maxWidth: 1200, margin: "0 auto", textAlign: "center" as const }}>
            <div style={{ fontFamily: "var(--font-body)", fontSize: 13, fontWeight: 500, color: "var(--fg-muted)", marginBottom: 32 }}>
              Официальные партнёры
            </div>
            <div style={{ display: "flex", justifyContent: "center", alignItems: "center", gap: "clamp(32px, 6vw, 80px)", flexWrap: "wrap" as const }}>
              {["Unitree", "AgiBot", "Deep Robotics"].map((b) => (
                <Link key={b} href={`/catalog?brand=${encodeURIComponent(b)}`} style={{
                  fontFamily: "var(--font-heading)", fontWeight: 600,
                  fontSize: "clamp(20px, 3vw, 32px)", color: "#D4D4D4",
                  textDecoration: "none", letterSpacing: "-0.02em",
                  transition: "color 0.3s var(--ease-out)",
                }}
                onMouseEnter={(e) => ((e.target as HTMLElement).style.color = "var(--fg)")}
                onMouseLeave={(e) => ((e.target as HTMLElement).style.color = "#D4D4D4")}
                >
                  {b}
                </Link>
              ))}
            </div>
          </div>
        </FadeIn>
      </section>

      {/* ═══════ CTA ═══════ */}
      <section style={{
        background: "var(--fg)", padding: "80px 24px",
        textAlign: "center" as const,
      }}>
        <FadeIn>
          <div style={{ maxWidth: 520, margin: "0 auto" }}>
            <h2 style={{
              fontFamily: "var(--font-heading)", fontWeight: 600,
              fontSize: "clamp(28px, 3.5vw, 44px)", color: "#fff",
              lineHeight: 1.15, marginBottom: 16, letterSpacing: "-0.02em",
            }}>
              Готовы начать?
            </h2>
            <p style={{
              fontFamily: "var(--font-body)", fontSize: 17,
              color: "rgba(255,255,255,0.55)", lineHeight: 1.6, marginBottom: 36,
            }}>
              Оставьте заявку — подберём робота под ваши задачи и бюджет
            </p>
            <Link href="/contact" style={{
              fontFamily: "var(--font-body)", fontWeight: 500,
              fontSize: 15, color: "var(--fg)", background: "#fff",
              textDecoration: "none", padding: "14px 36px",
              borderRadius: 100, display: "inline-flex", alignItems: "center", gap: 8,
              transition: "all 0.25s var(--ease-out)",
            }}
            onMouseEnter={(e) => { (e.currentTarget).style.background = "rgba(255,255,255,0.9)"; (e.currentTarget).style.transform = "translateY(-1px)"; }}
            onMouseLeave={(e) => { (e.currentTarget).style.background = "#fff"; (e.currentTarget).style.transform = "none"; }}
            >
              Оставить заявку
              <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
            </Link>
          </div>
        </FadeIn>
      </section>

      <Footer />
    </>
  );
}
