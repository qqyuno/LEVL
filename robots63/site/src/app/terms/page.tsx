import Header from "@/components/Header";
import Footer from "@/components/Footer";
import Link from "next/link";

export const metadata = {
  title: "Пользовательское соглашение — ROBOTS63",
  description: "Пользовательское соглашение сайта ROBOTS63. Правила использования сайта и условия взаимодействия.",
  alternates: { canonical: "https://robots63.com/terms" },
  robots: { index: false },
};

const LAST_UPDATED = "10 апреля 2025 г.";
const SITE = "robots63.com";

const sections = [
  {
    id: "acceptance",
    title: "1. Принятие условий",
    content: `Используя сайт ${SITE} (далее — «Сайт»), вы подтверждаете, что прочитали, поняли и согласились с настоящим Пользовательским соглашением (далее — «Соглашение»).

Если вы не согласны с условиями Соглашения — пожалуйста, не используйте Сайт.`,
  },
  {
    id: "service",
    title: "2. Описание сервиса",
    content: `Сайт является информационным ресурсом, представляющим каталог роботов (гуманоиды, робособаки) и предоставляющим контактную информацию для связи с менеджерами ROBOTS63.

Сайт не является интернет-магазином. Оформление и оплата заказов происходит вне Сайта — в мессенджерах и по отдельным договорённостям с менеджером.`,
  },
  {
    id: "content",
    title: "3. Интеллектуальная собственность",
    content: `Все материалы Сайта — тексты, изображения, логотипы, дизайн — являются собственностью ROBOTS63 или используются на законных основаниях.

Запрещено без письменного разрешения:
— Копировать и распространять материалы Сайта в коммерческих целях
— Воспроизводить дизайн или структуру Сайта
— Использовать логотип и фирменный стиль ROBOTS63

Изображения роботов принадлежат соответствующим производителям (Unitree, AGIBOT, Deep Robotics и др.) и используются исключительно в информационных целях.`,
  },
  {
    id: "user-conduct",
    title: "4. Правила использования",
    content: `При использовании Сайта запрещено:

— Предпринимать действия, которые могут нарушить работу Сайта
— Использовать автоматические системы для сбора данных (парсинг, скрейпинг)
— Размещать или распространять через Сайт незаконный контент
— Пытаться получить несанкционированный доступ к системам Сайта
— Выдавать себя за ROBOTS63 или вводить других пользователей в заблуждение`,
  },
  {
    id: "links",
    title: "5. Внешние ссылки",
    content: `Сайт содержит ссылки на внешние ресурсы: Telegram, ВКонтакте, MAX и сайты производителей роботов.

ROBOTS63 не несёт ответственности за содержание, политику конфиденциальности или деятельность внешних сайтов. Переходя по ссылке, вы покидаете Сайт и соглашаетесь с правилами соответствующей платформы.`,
  },
  {
    id: "disclaimer",
    title: "6. Ограничение ответственности",
    content: `Информация на Сайте предоставляется «как есть». ROBOTS63 не гарантирует:

— Абсолютную точность технических характеристик (уточняйте у менеджера)
— Непрерывную доступность Сайта
— Отсутствие ошибок в текстах и описаниях

Цены, наличие и сроки поставки уточняются индивидуально у менеджера и могут отличаться от ожиданий.

ROBOTS63 не несёт ответственности за любые убытки, возникшие в результате использования или невозможности использования Сайта.`,
  },
  {
    id: "privacy",
    title: "7. Конфиденциальность",
    content: `Обработка данных пользователей регулируется отдельным документом — Политикой конфиденциальности, доступной по адресу ${SITE}/privacy.

Политика конфиденциальности является неотъемлемой частью настоящего Соглашения.`,
  },
  {
    id: "law",
    title: "8. Применимое право",
    content: `Настоящее Соглашение регулируется законодательством Российской Федерации. Все споры разрешаются в соответствии с действующим законодательством РФ.`,
  },
  {
    id: "changes",
    title: "9. Изменения соглашения",
    content: `ROBOTS63 вправе вносить изменения в Соглашение без предварительного уведомления. Продолжение использования Сайта после внесения изменений означает ваше согласие с обновлённой версией.

Дата последнего обновления указана в начале документа.`,
  },
  {
    id: "contacts",
    title: "10. Контакты",
    content: `По вопросам, связанным с Соглашением:

Telegram: @BalePa_96
Сайт: ${SITE}`,
  },
];

export default function TermsPage() {
  return (
    <>
      <Header />

      {/* Hero */}
      <div style={{ background: "#fff", padding: "112px 24px 64px", borderBottom: "1px solid #E8E8E6" }}>
        <div style={{ maxWidth: 760, margin: "0 auto" }}>
          <div style={{
            fontFamily: "var(--font-body), sans-serif", fontSize: 12, fontWeight: 600,
            letterSpacing: "0.12em", textTransform: "uppercase" as const,
            color: "#999", marginBottom: 20,
          }}>
            Правовые документы
          </div>
          <h1 style={{
            fontFamily: "var(--font-heading), sans-serif", fontWeight: 700,
            fontSize: "clamp(32px, 5vw, 56px)", color: "#0A0A0A",
            lineHeight: 1.05, letterSpacing: "-0.03em", marginBottom: 20,
          }}>
            Пользовательское соглашение
          </h1>
          <div style={{
            display: "flex", gap: 24, alignItems: "center", flexWrap: "wrap" as const,
          }}>
            <span style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 14, color: "#888",
            }}>
              Обновлено: {LAST_UPDATED}
            </span>
            <Link href="/privacy" style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 14,
              color: "#0A0A0A", textDecoration: "none", fontWeight: 500,
              borderBottom: "1px solid #E8E8E6", paddingBottom: 1,
            }}>
              Политика конфиденциальности →
            </Link>
          </div>
        </div>
      </div>

      {/* Content */}
      <div style={{ padding: "64px 24px 120px", background: "#FAFAF9" }}>
        <div style={{ maxWidth: 1100, margin: "0 auto", display: "grid", gridTemplateColumns: "220px 1fr", gap: 64, alignItems: "flex-start" }} className="legal-grid">

          {/* Sticky nav */}
          <nav style={{ position: "sticky", top: 88 }} className="legal-nav">
            <div style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 11, fontWeight: 600,
              letterSpacing: "0.10em", textTransform: "uppercase" as const,
              color: "#AAA", marginBottom: 16,
            }}>
              Разделы
            </div>
            {sections.map((s) => (
              <a key={s.id} href={`#${s.id}`} className="legal-nav-link">
                {s.title}
              </a>
            ))}
          </nav>

          {/* Sections */}
          <div style={{ minWidth: 0 }}>
            {sections.map((s, i) => (
              <div
                key={s.id}
                id={s.id}
                style={{
                  background: "#fff", borderRadius: 16,
                  border: "1px solid #E8E8E6",
                  padding: "32px 36px",
                  marginBottom: i < sections.length - 1 ? 16 : 0,
                }}
              >
                <h2 style={{
                  fontFamily: "var(--font-heading), sans-serif", fontWeight: 600,
                  fontSize: 18, color: "#0A0A0A", marginBottom: 16,
                  letterSpacing: "-0.01em",
                }}>
                  {s.title}
                </h2>
                <div style={{
                  fontFamily: "var(--font-body), sans-serif",
                  fontSize: 15, color: "#555", lineHeight: 1.8,
                  whiteSpace: "pre-line" as const,
                }}>
                  {s.content}
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <style>{`
        .legal-nav-link {
          display: block;
          font-family: var(--font-body), sans-serif;
          font-size: 13px; color: #666; text-decoration: none;
          padding: 6px 0 6px 12px; margin-left: -12px;
          line-height: 1.4;
          border-left: 2px solid transparent;
          transition: color 0.15s, border-color 0.15s;
        }
        .legal-nav-link:hover { color: #0A0A0A; border-left-color: #0A0A0A; }
        @media (max-width: 860px) {
          .legal-grid { grid-template-columns: 1fr !important; gap: 32px !important; }
          .legal-nav { display: none !important; }
        }
      `}</style>

      <Footer />
    </>
  );
}
