"use client";

import Header from "@/components/Header";
import Footer from "@/components/Footer";
import Link from "next/link";

export default function ContactClient() {
  return (
    <>
      <Header />

      <div style={{ background: "#0A0A0A", padding: "140px 24px 80px", minHeight: "60vh", display: "flex", alignItems: "center", position: "relative", overflow: "hidden" }}>
        <div style={{ position: "absolute", inset: 0, background: "radial-gradient(ellipse at 50% 60%, rgba(161,98,7,0.1) 0%, transparent 60%)", pointerEvents: "none" }} />

        <div style={{ maxWidth: 640, margin: "0 auto", textAlign: "center" as const, position: "relative", zIndex: 2 }}>
          <div style={{ fontFamily: "var(--font-body)", fontSize: 12, fontWeight: 600, letterSpacing: "0.14em", textTransform: "uppercase" as const, color: "#A16207", marginBottom: 24 }}>
            Связаться с нами
          </div>
          <h1 style={{ fontFamily: "var(--font-heading)", fontWeight: 700, fontSize: "clamp(40px, 6vw, 72px)", lineHeight: 1.05, marginBottom: 24 }}>
            <span style={{ color: "#fff" }}>Оставить </span>
            <span style={{ background: "linear-gradient(135deg, #A16207, #EAB308)", WebkitBackgroundClip: "text", WebkitTextFillColor: "transparent" }}>заявку</span>
          </h1>
          <p style={{ fontFamily: "var(--font-body)", fontSize: 18, color: "rgba(255,255,255,0.5)", lineHeight: 1.65, maxWidth: 500, margin: "0 auto" }}>
            Подберём робота под ваши задачи. Менеджер свяжется с вами в течение рабочего дня.
          </p>
        </div>
      </div>

      <section style={{ padding: "80px 24px 120px", background: "#FAFAF9" }}>
        <div style={{ maxWidth: 560, margin: "0 auto" }}>
          <div style={{ background: "#fff", borderRadius: 20, border: "1px solid #E5E5E5", padding: "56px 48px", boxShadow: "0 8px 40px rgba(0,0,0,0.06)" }}>
            <p style={{ fontFamily: "var(--font-body)", fontSize: 16, color: "#404040", textAlign: "center" as const, lineHeight: 1.7, marginBottom: 40 }}>
              Форма заявки появится в ближайшее время. Мы уже работаем над этим.
            </p>

            <div style={{ display: "flex", flexDirection: "column" as const, gap: 12, alignItems: "center" }}>
              <div style={{ width: 48, height: 1, background: "#E5E5E5", margin: "8px 0 24px" }} />
              <p style={{ fontFamily: "var(--font-body)", fontSize: 14, color: "#888", lineHeight: 1.6, textAlign: "center" as const }}>
                Работаем по всему СНГ
              </p>
              <p style={{ fontFamily: "var(--font-body)", fontSize: 13, color: "#AAA" }}>
                Россия · Казахстан · Беларусь · Узбекистан
              </p>
            </div>
          </div>

          <div style={{ textAlign: "center" as const, marginTop: 32 }}>
            <Link href="/catalog" style={{ fontFamily: "var(--font-body)", fontSize: 14, color: "#A16207", textDecoration: "none", fontWeight: 600, letterSpacing: "0.04em" }}>
              ← Вернуться в каталог
            </Link>
          </div>
        </div>
      </section>

      <Footer />
    </>
  );
}
