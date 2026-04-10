import type { Metadata } from "next";

export const metadata: Metadata = {
  title: "Каталог роботов — Гуманоиды и робособаки в СНГ",
  description:
    "15+ моделей роботов от Unitree, AGIBOT, UBTECH, Deep Robotics, Xiaomi, Tesla, Dobot, Petoi. Официальный дистрибьютор в России, Казахстане, Беларуси.",
  alternates: { canonical: "https://robots63.ru/catalog" },
  openGraph: {
    title: "Каталог роботов | ROBOTS63",
    description: "Гуманоиды и робособаки от мировых производителей. Поставки по СНГ.",
    locale: "ru_RU",
    type: "website",
  },
};

export default function CatalogLayout({ children }: { children: React.ReactNode }) {
  return children;
}
