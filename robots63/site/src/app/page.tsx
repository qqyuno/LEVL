import type { Metadata } from "next";
import { humanoids, robotDogs } from "@/lib/products";
import HomeClient from "@/components/HomeClient";

export const metadata: Metadata = {
  title: "Гуманоидные роботы и робособаки — купить в России и СНГ",
  description: "Официальный дистрибьютор роботов с ИИ в СНГ. AgiBot, Unitree, Boston Dynamics, Deep Robotics. 15+ моделей, доставка по России и Казахстану, таможня, техподдержка.",
  alternates: { canonical: "https://robots63.com" },
  openGraph: {
    title: "ROBOTS63 — Гуманоидные роботы и робособаки в СНГ",
    description: "Официальный дистрибьютор роботов с ИИ. AgiBot, Unitree, Deep Robotics. Доставка по всему СНГ.",
    locale: "ru_RU",
    type: "website",
    images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: "ROBOTS63 — Роботы с ИИ" }],
  },
};

// Server Component — SEO-ready, passes data to the interactive client shell
export default function HomePage() {
  return <HomeClient humanoids={humanoids} robotDogs={robotDogs} />;
}
