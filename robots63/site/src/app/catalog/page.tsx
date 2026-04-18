import type { Metadata } from "next";
import CatalogClient from "./CatalogClient";

export const metadata: Metadata = {
  title: "Каталог роботов — гуманоиды и робособаки",
  description: "Каталог гуманоидных роботов и робособак с ИИ от Unitree, AgiBot, Boston Dynamics, Deep Robotics, UBTECH, Xiaomi. Официальные поставки по России и СНГ.",
  alternates: { canonical: "https://robots63.com/catalog" },
  openGraph: {
    title: "Каталог роботов — гуманоиды и робособаки | ROBOTS63",
    description: "15+ моделей от ведущих мировых производителей. Официальные поставки по России и СНГ.",
    locale: "ru_RU",
    type: "website",
    images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: "Каталог роботов ROBOTS63" }],
  },
};

export default function CatalogPage() {
  return <CatalogClient />;
}
