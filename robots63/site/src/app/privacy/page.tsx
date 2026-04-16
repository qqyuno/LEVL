import Header from "@/components/Header";
import Footer from "@/components/Footer";
import Link from "next/link";

export const metadata = {
  title: "Политика конфиденциальности — ROBOTS63",
  description: "Политика конфиденциальности сайта ROBOTS63. Как мы собираем, храним и используем данные пользователей.",
  alternates: { canonical: "https://robots63.com/privacy" },
  robots: { index: false },
};

const LAST_UPDATED = "10 апреля 2025 г.";
const COMPANY = "ROBOTS63";
const SITE = "robots63.com";

const sections = [
  {
    id: "general",
    title: "1. Общие положения",
    content: `Настоящая Политика конфиденциальности определяет порядок обработки и защиты информации о пользователях сайта ${SITE} (далее — «Сайт»), которую ${COMPANY} (далее — «Оператор») получает при использовании Сайта.

Использование Сайта означает безоговорочное согласие пользователя с настоящей Политикой и указанными в ней условиями обработки его персональных данных. В случае несогласия с этими условиями пользователь должен воздержаться от использования Сайта.`,
  },
  {
    id: "data",
    title: "2. Какие данные мы собираем",
    content: `Сайт собирает следующие виды данных:

— Технические данные: IP-адрес, тип браузера и операционной системы, страницы которые вы посещаете, время визита, реферальный URL.

— Cookie-файлы: небольшие текстовые файлы, хранящиеся в браузере. Используются для аналитики посещаемости (Яндекс.Метрика) и корректной работы Сайта.

— Данные аналитики: информация о поведении на Сайте (клики, скроллинг, время на страницах) — исключительно в обезличенном виде.

Сайт не собирает и не хранит имена, email, телефоны или платёжные данные. При переходе в мессенджеры (Telegram, ВКонтакте, MAX) применяется политика конфиденциальности соответствующей платформы.`,
  },
  {
    id: "purpose",
    title: "3. Цели обработки данных",
    content: `Данные используются исключительно для:

— Анализа посещаемости и улучшения Сайта
— Понимания того, какой контент полезен пользователям
— Обеспечения корректной работы технических функций Сайта
— Соблюдения требований законодательства Российской Федерации`,
  },
  {
    id: "cookies",
    title: "4. Использование Cookie",
    content: `Сайт использует следующие типы cookie:

Необходимые — обеспечивают базовую работу Сайта. Не требуют согласия.

Аналитические — используются сервисом Яндекс.Метрика для сбора обезличенной статистики посещений. Загружаются только после вашего согласия через баннер.

Вы можете управлять cookie в настройках браузера или отказаться от аналитических cookie через баннер на Сайте. Отказ от cookie не ограничивает доступ к контенту.`,
  },
  {
    id: "third-party",
    title: "5. Передача данных третьим лицам",
    content: `Оператор не продаёт и не передаёт персональные данные третьим лицам в коммерческих целях.

Данные могут быть переданы:

— Яндекс.Метрика (yandex.ru) — аналитический сервис, работающий согласно политике конфиденциальности Яндекс
— Государственным органам — исключительно на основании законных требований

Переход по ссылкам на Telegram, ВКонтакте или MAX означает переход на внешние платформы со своими правилами конфиденциальности, за которые ${COMPANY} ответственности не несёт.`,
  },
  {
    id: "rights",
    title: "6. Права пользователей",
    content: `В соответствии с Федеральным законом № 152-ФЗ «О персональных данных» вы имеете право:

— Запросить информацию об обработке ваших данных
— Потребовать исправления неточных данных
— Отозвать согласие на обработку данных
— Потребовать удаления данных

Для реализации прав обратитесь через любой из мессенджеров, указанных на странице контактов.`,
  },
  {
    id: "security",
    title: "7. Защита данных",
    content: `Оператор принимает технические и организационные меры для защиты данных от несанкционированного доступа, изменения или уничтожения. Сайт использует защищённый протокол HTTPS.`,
  },
  {
    id: "changes",
    title: "8. Изменения политики",
    content: `Оператор вправе вносить изменения в настоящую Политику. При существенных изменениях дата обновления в шапке документа будет изменена. Рекомендуем периодически проверять актуальность документа.`,
  },
  {
    id: "contacts",
    title: "9. Контакты",
    content: `По вопросам, связанным с обработкой персональных данных, обращайтесь:

Telegram: @BalePa_96
Сайт: ${SITE}`,
  },
];

export default function PrivacyPage() {
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
            Политика конфиденциальности
          </h1>
          <div style={{
            display: "flex", gap: 24, alignItems: "center", flexWrap: "wrap" as const,
          }}>
            <span style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 14, color: "#888",
            }}>
              Обновлено: {LAST_UPDATED}
            </span>
            <Link href="/terms" style={{
              fontFamily: "var(--font-body), sans-serif", fontSize: 14,
              color: "#0A0A0A", textDecoration: "none", fontWeight: 500,
              borderBottom: "1px solid #E8E8E6", paddingBottom: 1,
            }}>
              Пользовательское соглашение →
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
              <a
                key={s.id}
                href={`#${s.id}`}
                className="legal-nav-link"
              >
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
