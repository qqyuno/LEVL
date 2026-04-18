import { notFound } from "next/navigation";
import Link from "next/link";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import ProductCard from "@/components/ProductCard";
import ProductImage from "@/components/ProductImage";
import { products, getProductBySlug } from "@/lib/products";

export async function generateStaticParams() {
  return products.map((p) => ({ slug: p.slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const product = getProductBySlug(slug);
  if (!product) return {};
  const desc = product.description.slice(0, 155).replace(/\s\S+$/, "…");
  return {
    title: `${product.name} — купить в СНГ`,
    description: desc,
    alternates: { canonical: `https://robots63.com/catalog/${product.slug}` },
    openGraph: {
      title: `${product.name} | ROBOTS63`,
      description: desc,
      images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: product.name }],
      type: "website",
      locale: "ru_RU",
    },
  };
}

const categoryLabel: Record<string, string> = {
  humanoid: "Гуманоид",
  "robot-dog": "Робособака",
  iconic: "Иконический",
};
const categoryHref: Record<string, string> = {
  humanoid: "/catalog?category=humanoid",
  "robot-dog": "/catalog?category=robot-dog",
  iconic: "/catalog?category=iconic",
};

export default async function ProductPage({ params }: { params: Promise<{ slug: string }> }) {
  const { slug } = await params;
  const product = getProductBySlug(slug);
  if (!product) notFound();

  const related = products
    .filter((p) => p.category === product.category && p.id !== product.id)
    .slice(0, 3);

  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: product.name,
    description: product.description,
    image: product.image,
    brand: { "@type": "Brand", name: product.brand },
    offers: {
      "@type": "Offer",
      availability: "https://schema.org/InStock",
      priceRange: "Цена по запросу",
      priceCurrency: "RUB",
      url: `https://robots63.com/catalog/${product.slug}`,
      seller: { "@type": "Organization", name: "ROBOTS63", url: "https://robots63.com" },
    },
  };

  const breadcrumbJsonLd = {
    "@context": "https://schema.org",
    "@type": "BreadcrumbList",
    itemListElement: [
      { "@type": "ListItem", position: 1, name: "Каталог", item: "https://robots63.com/catalog" },
      { "@type": "ListItem", position: 2, name: categoryLabel[product.category], item: `https://robots63.com${categoryHref[product.category]}` },
      { "@type": "ListItem", position: 3, name: product.name, item: `https://robots63.com/catalog/${product.slug}` },
    ],
  };

  return (
    <>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }} />
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(breadcrumbJsonLd) }} />
      <Header />

      {/* ── HERO ── */}
      <div style={{ background: "#fff", paddingTop: 96 }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 24px" }}>

          {/* Breadcrumb */}
          <nav style={{ display: "flex", gap: 8, marginBottom: 40, alignItems: "center", flexWrap: "wrap" as const }} aria-label="Навигация">
            {[
              { href: "/catalog", label: "Каталог" },
              { href: categoryHref[product.category], label: categoryLabel[product.category] },
            ].map((item, i) => (
              <span key={item.href} style={{ display: "flex", alignItems: "center", gap: 8 }}>
                {i > 0 && <span style={{ color: "var(--fg-muted)", fontSize: 14 }}>/</span>}
                <Link href={item.href} className="breadcrumb-link">{item.label}</Link>
              </span>
            ))}
            <span style={{ color: "var(--fg-muted)", fontSize: 14 }}>/</span>
            <span style={{ fontFamily: "var(--font-body), sans-serif", fontSize: 14, color: "var(--fg)" }}>{product.name}</span>
          </nav>

          <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 64, alignItems: "center", paddingBottom: 80 }} className="product-hero-grid">

            {/* Image */}
            <div style={{
              borderRadius: 20, overflow: "hidden", background: "var(--bg-soft)",
              border: "1px solid var(--border)", aspectRatio: "1/1",
              position: "relative",
            }}>
              <ProductImage
                src={product.image}
                alt={product.name}
              />
            </div>

            {/* Info */}
            <div>
              <div style={{
                fontFamily: "var(--font-body), sans-serif", fontSize: 13, fontWeight: 500,
                color: "var(--fg-muted)", letterSpacing: "0.02em",
                textTransform: "uppercase" as const, marginBottom: 8,
              }}>
                {product.brand}
              </div>

              <h1 style={{
                fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                fontSize: "clamp(32px, 4vw, 52px)", color: "var(--fg)",
                lineHeight: 1.1, marginBottom: 16, letterSpacing: "-0.03em",
              }}>
                {product.name}
              </h1>

              <p style={{
                fontFamily: "var(--font-body), sans-serif", fontSize: 17,
                color: "var(--fg-secondary)", marginBottom: 24, lineHeight: 1.6, maxWidth: 440,
              }}>
                {product.tagline}
              </p>

              {/* Tags */}
              <div style={{ display: "flex", gap: 6, flexWrap: "wrap" as const, marginBottom: 32 }}>
                <span className="tag-chip" style={{ background: "var(--fg)", color: "#fff", borderColor: "var(--fg)" }}>
                  {categoryLabel[product.category]}
                </span>
                {product.hasAI && (
                  <span className="tag-chip" style={{ fontFamily: "var(--font-mono), monospace", fontSize: 12 }}>AI</span>
                )}
                {product.tags.slice(0, 3).map((tag) => (
                  <span key={tag} className="tag-chip">{tag}</span>
                ))}
              </div>

              <Link href="/contact" className="btn-primary">
                Оставить заявку
                <svg width="16" height="16" viewBox="0 0 16 16" fill="none"><path d="M3 8h10M9 4l4 4-4 4" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* ── HIGHLIGHTS ── */}
      <section style={{ background: "var(--bg-soft)", padding: "72px 24px", borderTop: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <div style={{ display: "grid", gridTemplateColumns: "repeat(3, 1fr)", gap: 16 }} className="highlights-grid">
            {product.highlights.map((h) => (
              <div key={h.title} className="highlight-card" style={{ background: "#fff" }}>
                <div style={{ fontSize: 28, marginBottom: 14, lineHeight: 1 }}>{h.icon}</div>
                <div style={{
                  fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                  fontSize: 16, color: "var(--fg)", marginBottom: 8,
                  letterSpacing: "-0.01em",
                }}>{h.title}</div>
                <div style={{
                  fontFamily: "var(--font-body), sans-serif", fontSize: 14,
                  color: "var(--fg-secondary)", lineHeight: 1.6,
                }}>{h.desc}</div>
              </div>
            ))}
          </div>
        </div>
      </section>


      {/* ── DESCRIPTION ── */}
      <section style={{ padding: "72px 24px", background: "var(--bg-soft)", borderTop: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <div style={{ display: "grid", gridTemplateColumns: "240px 1fr", gap: 64 }} className="desc-grid">
            <div>
              <div className="section-label">О модели</div>
              <h2 style={{
                fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                fontSize: "clamp(22px, 2.5vw, 28px)", color: "var(--fg)",
                letterSpacing: "-0.02em",
              }}>
                Описание
              </h2>
            </div>
            <p style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 17,
              color: "var(--fg-secondary)", lineHeight: 1.8,
            }}>
              {product.description}
            </p>
          </div>
        </div>
      </section>

      {/* ── SPECS ── */}
      <section style={{ padding: "72px 24px", background: "#fff", borderTop: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <div style={{ display: "grid", gridTemplateColumns: "240px 1fr", gap: 64, alignItems: "flex-start" }} className="desc-grid">
            <div className="specs-sticky" style={{ position: "sticky", top: 88 }}>
              <div className="section-label">Технические данные</div>
              <h2 style={{
                fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                fontSize: "clamp(22px, 2.5vw, 28px)", color: "var(--fg)",
                letterSpacing: "-0.02em", marginBottom: 16,
              }}>
                Характеристики
              </h2>
              <p style={{
                fontFamily: "var(--font-body), sans-serif", fontSize: 13,
                color: "var(--fg-muted)", lineHeight: 1.7,
              }}>
                Уточняйте детали у менеджера. Возможна кастомизация.
              </p>
            </div>

            <div style={{ border: "1px solid var(--border)", borderRadius: 16, overflow: "hidden" }}>
              {product.specs.map((spec, i) => (
                <div
                  key={spec.label}
                  className="spec-row"
                  style={{
                    display: "grid",
                    gridTemplateColumns: "1fr 1fr",
                    gap: 24,
                    padding: "16px 24px",
                    background: i % 2 === 0 ? "#fff" : "var(--bg-soft)",
                    borderBottom: i < product.specs.length - 1 ? "1px solid var(--border-light)" : "none",
                    alignItems: "flex-start",
                  }}
                >
                  <div style={{
                    fontFamily: "var(--font-body), sans-serif", fontSize: 14,
                    color: "var(--fg-muted)", fontWeight: 450,
                    wordBreak: "break-word",
                  }}>
                    {spec.label}
                  </div>
                  <div style={{
                    fontFamily: "var(--font-mono), monospace", fontSize: 14,
                    color: "var(--fg)", fontWeight: 500,
                    wordBreak: "break-word",
                  }}>
                    {spec.value}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── USE CASES ── */}
      <section style={{ padding: "72px 24px", background: "var(--bg-soft)", borderTop: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <div style={{ display: "grid", gridTemplateColumns: "240px 1fr", gap: 64, alignItems: "flex-start" }} className="desc-grid">
            <div>
              <div className="section-label">Применение</div>
              <h2 style={{
                fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                fontSize: "clamp(22px, 2.5vw, 28px)", color: "var(--fg)",
                letterSpacing: "-0.02em",
              }}>
                Где работает
              </h2>
            </div>
            <div style={{ display: "flex", flexWrap: "wrap" as const, gap: 8 }}>
              {product.useCases.map((uc) => (
                <div key={uc} className="tag-chip" style={{ fontSize: 14, padding: "10px 18px" }}>{uc}</div>
              ))}
            </div>
          </div>
        </div>
      </section>

      {/* ── RELATED ── */}
      {related.length > 0 && (
        <section style={{ padding: "72px 24px 100px", background: "#fff", borderTop: "1px solid var(--border)" }}>
          <div style={{ maxWidth: 1200, margin: "0 auto" }}>
            <div style={{ display: "flex", justifyContent: "space-between", alignItems: "flex-end", marginBottom: 36, flexWrap: "wrap" as const, gap: 12 }}>
              <h2 style={{
                fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                fontSize: "clamp(22px, 3vw, 32px)", color: "var(--fg)",
                letterSpacing: "-0.02em",
              }}>
                Похожие модели
              </h2>
              <Link href={categoryHref[product.category]} className="btn-secondary" style={{ padding: "8px 18px", fontSize: 13 }}>
                Все {categoryLabel[product.category].toLowerCase()}ы
              </Link>
            </div>
            <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(260px, 1fr))", gap: 20 }}>
              {related.map((p) => <ProductCard key={p.id} product={p} />)}
            </div>
          </div>
        </section>
      )}

      {/* ── CTA ── */}
      <section style={{
        background: "var(--fg)", padding: "80px 24px",
        textAlign: "center" as const,
      }}>
        <div style={{ maxWidth: 480, margin: "0 auto" }}>
          <h2 style={{
            fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
            fontSize: "clamp(24px, 3vw, 36px)", color: "#fff",
            lineHeight: 1.15, marginBottom: 14, letterSpacing: "-0.02em",
          }}>
            Интересует {product.name}?
          </h2>
          <p style={{
            fontFamily: "var(--font-body), sans-serif", fontSize: 16,
            color: "rgba(255,255,255,0.5)", marginBottom: 32, lineHeight: 1.6,
          }}>
            Оставьте заявку — менеджер ответит на вопросы и подберёт конфигурацию
          </p>
          <Link href="/contact" style={{
            fontFamily: "var(--font-body)", fontWeight: 500,
            fontSize: 15, color: "var(--fg)", background: "#fff",
            textDecoration: "none", padding: "14px 36px",
            borderRadius: 100, display: "inline-flex", alignItems: "center", gap: 8,
            transition: "all 0.25s var(--ease-out)",
          }}>
            Оставить заявку
          </Link>
        </div>
      </section>

      <style>{`
        @media (max-width: 900px) {
          .product-hero-grid { grid-template-columns: 1fr !important; gap: 32px !important; }
          .desc-grid { grid-template-columns: 1fr !important; gap: 24px !important; }
          .highlights-grid { grid-template-columns: 1fr !important; }
        }
      `}</style>

      <Footer />
    </>
  );
}
