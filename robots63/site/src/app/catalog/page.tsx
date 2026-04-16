"use client";

import { useState, useEffect, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import ProductCard from "@/components/ProductCard";
import { products } from "@/lib/products";

type FilterCategory = "all" | "humanoid" | "robot-dog";

function CatalogContent() {
  const searchParams = useSearchParams();
  const [category, setCategory] = useState<FilterCategory>((searchParams.get("category") ?? "all") as FilterCategory);
  const [brand, setBrand] = useState(searchParams.get("brand") ?? "all");

  useEffect(() => {
    setCategory((searchParams.get("category") ?? "all") as FilterCategory);
    setBrand(searchParams.get("brand") ?? "all");
  }, [searchParams]);

  const brands = ["all", ...Array.from(new Set(products.map((p) => p.brand)))];

  const filtered = products.filter((p) => {
    const catMatch = category === "all" || p.category === category;
    const brandMatch = brand === "all" || p.brand === brand;
    return catMatch && brandMatch;
  });

  const categoryTabs: { value: FilterCategory; label: string }[] = [
    { value: "all", label: "Все модели" },
    { value: "humanoid", label: "Гуманоиды" },
    { value: "robot-dog", label: "Робособаки" },
  ];

  return (
    <>
      <Header />

      {/* Page header */}
      <div style={{ background: "#fff", padding: "112px 24px 48px" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          <div className="section-label">Каталог</div>
          <h1 style={{
            fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
            fontSize: "clamp(32px, 4vw, 48px)", color: "var(--fg)",
            lineHeight: 1.1, marginBottom: 12, letterSpacing: "-0.03em",
          }}>
            Каталог роботов
          </h1>
          <p style={{
            fontFamily: "var(--font-body), sans-serif", fontSize: 17,
            color: "var(--fg-secondary)", maxWidth: 440,
          }}>
            {products.length} моделей от ведущих мировых производителей
          </p>
        </div>
      </div>

      {/* Filters */}
      <div style={{
        background: "#fff", borderBottom: "1px solid var(--border)",
        position: "sticky", top: 64, zIndex: 50,
      }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", padding: "0 24px" }}>
          <div style={{ display: "flex", gap: 0, overflowX: "auto" as const, scrollbarWidth: "none" as const }}>
            {categoryTabs.map((tab) => (
              <button
                key={tab.value}
                onClick={() => setCategory(tab.value)}
                style={{
                  fontFamily: "var(--font-body), sans-serif",
                  fontWeight: 500, fontSize: 14,
                  color: category === tab.value ? "var(--fg)" : "var(--fg-muted)",
                  background: "none", border: "none",
                  borderBottom: category === tab.value ? "2px solid var(--fg)" : "2px solid transparent",
                  padding: "16px 18px", cursor: "pointer",
                  whiteSpace: "nowrap" as const, transition: "color 0.2s",
                }}
              >
                {tab.label}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Brand filter */}
      <div style={{ background: "var(--bg-soft)", padding: "16px 24px", borderBottom: "1px solid var(--border)" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto", display: "flex", gap: 8, flexWrap: "wrap" as const, alignItems: "center" }}>
          <span style={{ fontFamily: "var(--font-body), sans-serif", fontSize: 13, color: "var(--fg-muted)", marginRight: 4 }}>Бренд:</span>
          {brands.map((b) => (
            <button
              key={b}
              onClick={() => setBrand(b)}
              style={{
                fontFamily: "var(--font-body), sans-serif", fontWeight: 450,
                fontSize: 13,
                color: brand === b ? "#fff" : "var(--fg-secondary)",
                background: brand === b ? "var(--fg)" : "transparent",
                border: "1px solid",
                borderColor: brand === b ? "var(--fg)" : "var(--border)",
                borderRadius: 100, padding: "6px 16px", cursor: "pointer",
                transition: "all 0.15s",
              }}
            >
              {b === "all" ? "Все" : b}
            </button>
          ))}
        </div>
      </div>

      {/* Grid */}
      <div style={{ padding: "48px 24px 100px", background: "var(--bg-soft)", minHeight: "60vh" }}>
        <div style={{ maxWidth: 1200, margin: "0 auto" }}>
          {filtered.length === 0 ? (
            <div style={{ textAlign: "center" as const, padding: "80px 0" }}>
              <p style={{ fontFamily: "var(--font-body), sans-serif", fontSize: 17, color: "var(--fg-muted)" }}>Модели не найдены</p>
            </div>
          ) : (
            <>
              <div style={{
                fontFamily: "var(--font-body), sans-serif", fontSize: 14,
                color: "var(--fg-muted)", marginBottom: 24,
              }}>
                {filtered.length} {filtered.length === 1 ? "модель" : filtered.length < 5 ? "модели" : "моделей"}
              </div>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fill, minmax(280px, 1fr))", gap: 20 }}>
                {filtered.map((p) => <ProductCard key={p.id} product={p} />)}
              </div>
            </>
          )}
        </div>
      </div>

      <Footer />
    </>
  );
}

export default function CatalogPage() {
  return (
    <Suspense fallback={<div style={{ minHeight: "100vh", display: "flex", alignItems: "center", justifyContent: "center" }}><div style={{ fontFamily: "var(--font-body), sans-serif", color: "var(--fg-muted)" }}>Загрузка...</div></div>}>
      <CatalogContent />
    </Suspense>
  );
}
