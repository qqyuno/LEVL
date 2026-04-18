import { MetadataRoute } from "next";
import { products } from "@/lib/products";

const BASE_URL = "https://robots63.com";

// Static dates — update manually when pages change content
const SITE_UPDATED = "2026-04-18";
const CATALOG_UPDATED = "2026-04-18";

export default function sitemap(): MetadataRoute.Sitemap {
  const productUrls = products.map((p) => ({
    url: `${BASE_URL}/catalog/${p.slug}`,
    lastModified: p.updatedAt ?? CATALOG_UPDATED,
    changeFrequency: "monthly" as const,
    priority: 0.8,
  }));

  return [
    { url: BASE_URL, lastModified: SITE_UPDATED, changeFrequency: "weekly" as const, priority: 1.0 },
    { url: `${BASE_URL}/catalog`, lastModified: CATALOG_UPDATED, changeFrequency: "weekly" as const, priority: 0.9 },
    { url: `${BASE_URL}/about`, lastModified: SITE_UPDATED, changeFrequency: "monthly" as const, priority: 0.7 },
    { url: `${BASE_URL}/contact`, lastModified: SITE_UPDATED, changeFrequency: "monthly" as const, priority: 0.8 },
    ...productUrls,
  ];
}
