import type { Metadata, Viewport } from "next";
import { Space_Grotesk, Inter, JetBrains_Mono } from "next/font/google";
import "./globals.css";

const spaceGrotesk = Space_Grotesk({
  variable: "--font-heading",
  subsets: ["latin"],
  weight: ["400", "500", "600", "700"],
});

const inter = Inter({
  variable: "--font-body",
  subsets: ["latin", "cyrillic"],
  weight: ["300", "400", "500", "600"],
});

const jetbrainsMono = JetBrains_Mono({
  variable: "--font-mono",
  subsets: ["latin"],
  weight: ["400", "500"],
});

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
};

const BASE_URL = "https://robots63.ru";

export const metadata: Metadata = {
  metadataBase: new URL(BASE_URL),
  title: {
    default: "ROBOTS63 — Гуманоидные роботы и робособаки в СНГ",
    template: "%s | ROBOTS63",
  },
  description:
    "Официальный дистрибьютор гуманоидных роботов и робособак в СНГ. AGIBOT, Unitree, Deep Robotics. Доставка по России и Казахстану.",
  keywords:
    "робот гуманоид купить, робособака купить, AGIBOT A2 Ultra, AgiBot X2, Unitree G1, роботы с ИИ, гуманоидный робот цена Россия, Deep Robotics",
  // canonical is set per-page, not globally, to avoid all pages pointing to /
  openGraph: {
    type: "website",
    locale: "ru_RU",
    url: BASE_URL,
    siteName: "ROBOTS63",
    title: "ROBOTS63 — Гуманоидные роботы и робособаки в СНГ",
    description:
      "Официальный дистрибьютор роботов с ИИ. AGIBOT, UBTECH, Unitree, Deep Robotics. Доставка по всему СНГ.",
    images: [
      {
        url: "/og-image.jpg",
        width: 1200,
        height: 630,
        alt: "ROBOTS63 — Роботы с искусственным интеллектом",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "ROBOTS63 — Гуманоидные роботы и робособаки в СНГ",
    description: "Официальный дистрибьютор гуманоидных роботов и робособак. AGIBOT, Unitree, Deep Robotics. Доставка по России, Казахстану и всему СНГ.",
    images: ["/og-image.jpg"],
  },
  robots: {
    index: true,
    follow: true,
    googleBot: { index: true, follow: true },
  },
};

const orgJsonLd = {
  "@context": "https://schema.org",
  "@type": "Organization",
  name: "ROBOTS63",
  url: "https://robots63.ru",
  logo: {
    "@type": "ImageObject",
    url: "https://robots63.ru/logo/logo-white.svg",
    width: 1302,
    height: 870,
  },
  description: "Официальный дистрибьютор гуманоидных роботов и робособак в СНГ",
  areaServed: ["RU", "KZ", "BY", "UZ"],
  knowsAbout: ["Гуманоидные роботы", "Робособаки", "Искусственный интеллект", "Unitree", "AGIBOT", "UBTECH", "Deep Robotics"],
  sameAs: ["https://t.me/robots63"],
};

const websiteJsonLd = {
  "@context": "https://schema.org",
  "@type": "WebSite",
  name: "ROBOTS63",
  url: "https://robots63.ru",
  description: "Официальный дистрибьютор гуманоидных роботов и робособак в СНГ",
  potentialAction: {
    "@type": "SearchAction",
    target: {
      "@type": "EntryPoint",
      urlTemplate: "https://robots63.ru/catalog?q={search_term_string}",
    },
    "query-input": "required name=search_term_string",
  },
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="ru"
      className={`${spaceGrotesk.variable} ${inter.variable} ${jetbrainsMono.variable}`}
      style={{ fontFamily: "var(--font-body), sans-serif" }}
    >
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(orgJsonLd) }}
        />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(websiteJsonLd) }}
        />
      </head>
      <body className="min-h-screen flex flex-col">{children}</body>
    </html>
  );
}
