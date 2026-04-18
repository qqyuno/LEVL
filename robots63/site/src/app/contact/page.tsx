import ContactClient from "./ContactClient";

export const metadata = {
  title: "Оставить заявку — ROBOTS63",
  description: "Оставьте заявку на приобретение гуманоидного робота или робособаки. Работаем по России, Казахстану и всему СНГ. Доставка, таможня, техподдержка.",
  alternates: { canonical: "https://robots63.com/contact" },
  openGraph: {
    title: "Оставить заявку на робота — ROBOTS63",
    description: "Оставьте заявку на роботов Unitree, AgiBot, Deep Robotics. Отвечаем в рабочий день.",
    locale: "ru_RU",
    type: "website",
    images: [{ url: "/og-image.jpg", width: 1200, height: 630, alt: "Оставить заявку — ROBOTS63" }],
  },
};

export default function ContactPage() {
  return <ContactClient />;
}
