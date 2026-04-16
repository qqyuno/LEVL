import ContactClient from "./ContactClient";

export const metadata = {
  title: "Оставить заявку — ROBOTS63",
  description: "Оставьте заявку на приобретение гуманоидного робота или робособаки. Работаем по России, Казахстану и всему СНГ. Доставка, таможня, техподдержка.",
  alternates: { canonical: "https://robots63.com/contact" },
};

export default function ContactPage() {
  return <ContactClient />;
}
