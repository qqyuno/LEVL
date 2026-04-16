import Header from "@/components/Header";
import Footer from "@/components/Footer";
import Link from "next/link";

export const metadata = {
  title: "О компании — ROBOTS63",
  description: "ROBOTS63 — официальный дистрибьютор гуманоидных роботов и робособак в СНГ. Поставляем роботов Unitree, AGIBOT, UBTECH, Deep Robotics, Boston Dynamics по России, Казахстану и Беларуси.",
  alternates: { canonical: "https://robots63.com/about" },
  openGraph: {
    title: "О компании ROBOTS63 — дистрибьютор роботов в СНГ",
    description: "Официальный дистрибьютор гуманоидных роботов и робособак. Поставки, таможня, техподдержка по всему СНГ.",
    locale: "ru_RU",
    type: "website",
  },
};

const orgJsonLd = {
  "@context": "https://schema.org",
  "@type": "Organization",
  name: "ROBOTS63",
  url: "https://robots63.com",
  description: "Официальный дистрибьютор гуманоидных роботов и робособак в СНГ. Поставки Unitree, AGIBOT, UBTECH, Deep Robotics, Boston Dynamics.",
  areaServed: [
    { "@type": "Country", name: "Russia" },
    { "@type": "Country", name: "Kazakhstan" },
    { "@type": "Country", name: "Belarus" },
    { "@type": "Country", name: "Uzbekistan" },
  ],
  knowsAbout: ["Гуманоидные роботы", "Робособаки", "Искусственный интеллект", "Unitree", "AGIBOT", "UBTECH", "Deep Robotics", "Boston Dynamics"],
  contactPoint: {
    "@type": "ContactPoint",
    contactType: "sales",
    availableLanguage: ["Russian"],
    url: "https://t.me/BalePa_96",
  },
  sameAs: ["https://t.me/robots63", "https://vk.com/valcoin"],
};

const stats = [
  { value: "15+", label: "Моделей в каталоге" },
  { value: "8+", label: "Брендов мирового уровня" },
  { value: "4", label: "Страны СНГ" },
];

const brands = [
  { name: "Unitree", desc: "Лидер рынка робособак и гуманоидов. G1, H1, Go2 — технологии, доступные бизнесу." },
  { name: "AGIBOT", desc: "A2 Ultra и X2 — передовые гуманоиды для промышленных задач." },
  { name: "UBTECH", desc: "Walker S1 — один из наиболее функциональных двуногих роботов в мире." },
  { name: "Deep Robotics", desc: "Lite3 и Jueying — выносливые робособаки для сложных условий эксплуатации." },
  { name: "Boston Dynamics", desc: "Atlas — иконический гуманоид, эталон динамического движения." },
  { name: "Xiaomi", desc: "CyberDog 2 — технологичная робособака с открытой экосистемой разработки." },
];

const services = [
  { icon: "📦", title: "Поставка", desc: "Официальный импорт напрямую от производителей. Все документы в порядке." },
  { icon: "🛃", title: "Таможня", desc: "Берём на себя таможенное оформление и сертификацию. Без лишних хлопот." },
  { icon: "🚚", title: "Доставка", desc: "Доставляем по всей России, Казахстану, Беларуси и Узбекистану." },
  { icon: "🔧", title: "Техподдержка", desc: "Помогаем с запуском, настройкой и интеграцией после покупки." },
  { icon: "💼", title: "B2B-условия", desc: "Работаем с компаниями, университетами, исследовательскими центрами." },
  { icon: "⚡", title: "Быстрый ответ", desc: "Отвечаем в течение рабочего дня через Telegram, ВКонтакте или MAX." },
];

export default function AboutPage() {
  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(orgJsonLd) }} />
      <Header />

      {/* Hero */}
      <div style={{ background: "#0A0A0A", padding: "140px 24px 80px", position: "relative", overflow: "hidden" }}>
        <div style={{
          position: "absolute", inset: 0,
          background: "radial-gradient(ellipse at 30% 50%, rgba(161,98,7,0.10) 0%, transparent 60%)",
          pointerEvents: "none",
        }} />
        <div style={{ maxWidth: 760, margin: "0 auto", position: "relative", zIndex: 2 }}>
          <div style={{
            fontFamily: "var(--font-body)", fontSize: 12, fontWeight: 600,
            letterSpacing: "0.14em", textTransform: "uppercase" as const,
            color: "#A16207", marginBottom: 24,
          }}>
            О компании
          </div>
          <h1 style={{
            fontFamily: "var(--font-heading)", fontWeight: 700,
            fontSize: "clamp(36px, 6vw, 68px)", lineHeight: 1.05,
            letterSpacing: "-0.03em", marginBottom: 24, color: "#fff",
          }}>
            Роботы с ИИ —<br />
            <span style={{ background: "linear-gradient(135deg, #A16207, #EAB308)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>
              доступно в СНГ
            </span>
          </h1>
          <p style={{
            fontFamily: "var(--font-body)", fontSize: 18,
            color: "rgba(255,255,255,0.5)", lineHeight: 1.65, maxWidth: 520,
          }}>
            ROBOTS63 — официальный дистрибьютор ведущих мировых производителей роботов.
            Мы берём на себя поставку, таможню, доставку и техническую поддержку.
          </p>
        </div>
      </div>

      {/* Stats */}
      <section style={{ background: "#fff", borderBottom: "1px solid #E8E8E6" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto", padding: "0 24px" }}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)" }} className="stats-grid-about">
            {stats.map((s, i) => (
              <div key={s.label} style={{
                padding: "40px 24px", textAlign: "center",
                borderRight: i < stats.length - 1 ? "1px solid #E8E8E6" : "none",
              }}>
                <div style={{
                  fontFamily: "var(--font-heading)", fontWeight: 700,
                  fontSize: 40, color: "#0A0A0A", letterSpacing: "-0.04em",
                  marginBottom: 4,
                }}>
                  {s.value}
                </div>
                <div style={{
                  fontFamily: "var(--font-body)", fontSize: 13, color: "#888",
                }}>
                  {s.label}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Mission */}
      <section style={{ padding: "80px 24px", background: "#FAFAF9" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto", display: "grid", gridTemplateColumns: "1fr 1fr", gap: 64, alignItems: "center" }} className="about-two-col">
          <div>
            <div style={{
              fontFamily: "var(--font-body)", fontSize: 11, fontWeight: 600,
              letterSpacing: "0.12em", textTransform: "uppercase" as const,
              color: "#A16207", marginBottom: 20,
            }}>
              Наша миссия
            </div>
            <h2 style={{
              fontFamily: "var(--font-heading)", fontWeight: 600,
              fontSize: "clamp(26px, 3vw, 40px)", color: "#0A0A0A",
              letterSpacing: "-0.02em", marginBottom: 24, lineHeight: 1.15,
            }}>
              Сделать роботов доступными для бизнеса в СНГ
            </h2>
            <p style={{
              fontFamily: "var(--font-body)", fontSize: 16, color: "#555",
              lineHeight: 1.8, marginBottom: 16,
            }}>
              Мировой рынок роботизации растёт. Гуманоиды и робособаки уже работают на складах,
              в производстве, исследованиях и образовании. Но выйти на этот рынок в России и СНГ
              раньше было сложно — языковой барьер, таможня, отсутствие поддержки.
            </p>
            <p style={{
              fontFamily: "var(--font-body)", fontSize: 16, color: "#555",
              lineHeight: 1.8,
            }}>
              ROBOTS63 решает эту проблему. Мы работаем напрямую с производителями и берём на себя
              весь путь от завода до вашего склада.
            </p>
          </div>
          <div style={{
            background: "#0A0A0A", borderRadius: 20, padding: "40px",
            position: "relative", overflow: "hidden",
          }}>
            <div style={{
              position: "absolute", top: -40, right: -40, width: 200, height: 200,
              borderRadius: "50%",
              background: "radial-gradient(circle, rgba(161,98,7,0.3) 0%, transparent 70%)",
            }} />
            <div style={{
              fontFamily: "var(--font-heading)", fontSize: 18, fontWeight: 600,
              color: "#fff", marginBottom: 24, letterSpacing: "-0.01em",
            }}>
              Почему выбирают нас
            </div>
            {[
              "Прямые контракты с производителями",
              "Полное таможенное сопровождение",
              "Русскоязычная техподдержка",
              "Работаем с юридическими лицами",
              "Документы, сертификаты, гарантия",
            ].map((item) => (
              <div key={item} style={{
                display: "flex", alignItems: "flex-start", gap: 12, marginBottom: 16,
              }}>
                <div style={{
                  width: 20, height: 20, borderRadius: "50%",
                  background: "rgba(161,98,7,0.25)", display: "flex",
                  alignItems: "center", justifyContent: "center", flexShrink: 0, marginTop: 1,
                }}>
                  <svg width="10" height="10" viewBox="0 0 10 10" fill="none">
                    <path d="M2 5l2.5 2.5L8 3" stroke="#EAB308" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                  </svg>
                </div>
                <span style={{ fontFamily: "var(--font-body)", fontSize: 14, color: "rgba(255,255,255,0.7)", lineHeight: 1.6 }}>
                  {item}
                </span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Services */}
      <section style={{ padding: "80px 24px", background: "#fff", borderTop: "1px solid #E8E8E6" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ textAlign: "center", marginBottom: 56 }}>
            <div style={{
              fontFamily: "var(--font-body)", fontSize: 11, fontWeight: 600,
              letterSpacing: "0.12em", textTransform: "uppercase" as const,
              color: "#A16207", marginBottom: 16,
            }}>
              Что мы делаем
            </div>
            <h2 style={{
              fontFamily: "var(--font-heading)", fontWeight: 600,
              fontSize: "clamp(26px, 3vw, 40px)", color: "#0A0A0A",
              letterSpacing: "-0.02em",
            }}>
              Полный цикл — от заказа до запуска
            </h2>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 20 }} className="services-grid">
            {services.map((s) => (
              <div key={s.title} style={{
                background: "#FAFAF9", borderRadius: 16,
                border: "1px solid #E8E8E6", padding: "28px 28px",
              }}>
                <div style={{ fontSize: 28, marginBottom: 14 }}>{s.icon}</div>
                <div style={{
                  fontFamily: "var(--font-heading)", fontWeight: 600,
                  fontSize: 16, color: "#0A0A0A", marginBottom: 8,
                  letterSpacing: "-0.01em",
                }}>
                  {s.title}
                </div>
                <div style={{
                  fontFamily: "var(--font-body)", fontSize: 14, color: "#666",
                  lineHeight: 1.65,
                }}>
                  {s.desc}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Brands */}
      <section style={{ padding: "80px 24px", background: "#FAFAF9", borderTop: "1px solid #E8E8E6" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto" }}>
          <div style={{ marginBottom: 48 }}>
            <div style={{
              fontFamily: "var(--font-body)", fontSize: 11, fontWeight: 600,
              letterSpacing: "0.12em", textTransform: "uppercase" as const,
              color: "#A16207", marginBottom: 16,
            }}>
              Бренды
            </div>
            <h2 style={{
              fontFamily: "var(--font-heading)", fontWeight: 600,
              fontSize: "clamp(26px, 3vw, 40px)", color: "#0A0A0A",
              letterSpacing: "-0.02em",
            }}>
              Работаем с лучшими
            </h2>
          </div>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 16 }} className="brands-grid">
            {brands.map((b) => (
              <div key={b.name} style={{
                background: "#fff", borderRadius: 16,
                border: "1px solid #E8E8E6", padding: "24px 28px",
              }}>
                <div style={{
                  fontFamily: "var(--font-heading)", fontWeight: 700,
                  fontSize: 18, color: "#0A0A0A", marginBottom: 8,
                  letterSpacing: "-0.02em",
                }}>
                  {b.name}
                </div>
                <div style={{
                  fontFamily: "var(--font-body)", fontSize: 13, color: "#666",
                  lineHeight: 1.65,
                }}>
                  {b.desc}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section style={{ background: "#0A0A0A", padding: "80px 24px", textAlign: "center" as const }}>
        <div style={{ maxWidth: 480, margin: "0 auto" }}>
          <h2 style={{
            fontFamily: "var(--font-heading)", fontWeight: 600,
            fontSize: "clamp(24px, 3vw, 36px)", color: "#fff",
            lineHeight: 1.15, marginBottom: 14, letterSpacing: "-0.02em",
          }}>
            Готовы обсудить проект?
          </h2>
          <p style={{
            fontFamily: "var(--font-body)", fontSize: 16,
            color: "rgba(255,255,255,0.5)", marginBottom: 32, lineHeight: 1.6,
          }}>
            Напишите нам — подберём модель, рассчитаем стоимость, поставим в срок
          </p>
          <div style={{ display: "flex", gap: 12, justifyContent: "center", flexWrap: "wrap" as const }}>
            <Link href="/contact" style={{
              fontFamily: "var(--font-body)", fontWeight: 500,
              fontSize: 15, color: "var(--fg)", background: "#fff",
              textDecoration: "none", padding: "14px 36px",
              borderRadius: 100, display: "inline-block",
              transition: "all 0.25s",
            }}>
              Написать нам
            </Link>
            <Link href="/catalog" style={{
              fontFamily: "var(--font-body)", fontWeight: 500,
              fontSize: 15, color: "#fff",
              background: "rgba(255,255,255,0.08)",
              border: "1px solid rgba(255,255,255,0.12)",
              textDecoration: "none", padding: "14px 36px",
              borderRadius: 100, display: "inline-block",
              transition: "all 0.25s",
            }}>
              Смотреть каталог
            </Link>
          </div>
        </div>
      </section>

      <style>{`
        @media (max-width: 860px) {
          .about-two-col { grid-template-columns: 1fr !important; gap: 32px !important; }
          .services-grid { grid-template-columns: 1fr 1fr !important; }
          .brands-grid { grid-template-columns: 1fr 1fr !important; }
          .stats-grid-about { grid-template-columns: 1fr 1fr 1fr !important; }
        }
        @media (max-width: 560px) {
          .services-grid { grid-template-columns: 1fr !important; }
          .brands-grid { grid-template-columns: 1fr !important; }
          .stats-grid-about { grid-template-columns: 1fr !important; }
        }
      `}</style>

      <Footer />
    </>
  );
}
