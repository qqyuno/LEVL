"use client";

import Link from "next/link";
import Image from "next/image";
import type { Product } from "@/lib/products";

const categoryLabel: Record<string, string> = {
  humanoid: "Гуманоид",
  "robot-dog": "Робособака",
};

export default function ProductCard({ product }: { product: Product }) {
  return (
    <Link href={`/catalog/${product.slug}`} style={{ textDecoration: "none" }}>
      <div className="product-card">
        {/* Image */}
        <div style={{
          aspectRatio: "4/3",
          overflow: "hidden",
          background: "#F0F0EE",
          position: "relative",
        }}>
          <Image
            className="product-card-img"
            src={product.image}
            alt={`${product.name} — ${product.tagline}`}
            fill
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 50vw, 280px"
            style={{ objectFit: "contain", objectPosition: "center", padding: "12px" }}
          />
          {/* Category */}
          <div style={{
            position: "absolute", top: 12, left: 12,
            background: "rgba(255,255,255,0.9)", backdropFilter: "blur(8px)",
            borderRadius: 100, padding: "4px 12px",
            fontFamily: "var(--font-body), sans-serif", fontSize: 12, fontWeight: 500,
            color: "var(--fg-secondary)",
          }}>
            {categoryLabel[product.category]}
          </div>
          {product.hasAI && (
            <div style={{
              position: "absolute", top: 12, right: 12,
              background: "var(--fg)", borderRadius: 100, padding: "4px 10px",
              fontFamily: "var(--font-mono), monospace", fontSize: 11, fontWeight: 600,
              color: "#fff", letterSpacing: "0.04em",
            }}>
              AI
            </div>
          )}
        </div>

        {/* Content */}
        <div style={{ padding: "20px 20px 24px" }}>
          <div style={{
            fontFamily: "var(--font-body), sans-serif", fontSize: 12, fontWeight: 500,
            color: "var(--fg-muted)", letterSpacing: "0.02em",
            textTransform: "uppercase" as const, marginBottom: 6,
          }}>
            {product.brand}
          </div>
          <div style={{
            fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
            fontSize: 20, color: "var(--fg)", lineHeight: 1.2, marginBottom: 8,
            letterSpacing: "-0.02em",
          }}>
            {product.name}
          </div>
          <div style={{
            fontFamily: "var(--font-body), sans-serif", fontSize: 14,
            color: "var(--fg-secondary)", lineHeight: 1.5, marginBottom: 16,
            display: "-webkit-box", WebkitLineClamp: 2, WebkitBoxOrient: "vertical" as const, overflow: "hidden",
          }}>
            {product.tagline}
          </div>

          {/* Key specs */}
          <div style={{ display: "flex", gap: 6, flexWrap: "wrap" as const }}>
            {product.specs.slice(0, 3).map((spec) => (
              <div key={spec.label} style={{
                background: "var(--bg-soft)", borderRadius: 6, padding: "4px 10px",
                fontFamily: "var(--font-mono), monospace", fontSize: 11, fontWeight: 500,
                color: "var(--fg-secondary)",
              }}>
                {spec.value}
              </div>
            ))}
          </div>
        </div>
      </div>
    </Link>
  );
}
