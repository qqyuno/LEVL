import { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      { userAgent: "*", allow: "/", disallow: ["/catalog?"] },
      { userAgent: ["GPTBot", "CCBot", "anthropic-ai", "Claude-Web", "PerplexityBot"], disallow: "/" },
    ],
    sitemap: "https://robots63.ru/sitemap.xml",
  };
}
