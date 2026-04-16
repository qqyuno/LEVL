import { MetadataRoute } from "next";

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      { userAgent: "*", allow: "/", disallow: ["/catalog?"] },
    ],
    sitemap: "https://robots63.com/sitemap.xml",
  };
}
