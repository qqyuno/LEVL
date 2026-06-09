import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';

enum LegalDocument { privacy, terms }

class LegalPage extends StatelessWidget {
  final LegalDocument document;

  const LegalPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final content = document == LegalDocument.privacy
        ? _LegalContent.privacy
        : _LegalContent.terms;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(content.title),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Text(
            content.kicker,
            style: GoogleFonts.dmSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
              letterSpacing: 2.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content.headline,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 30,
              height: 1.08,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            content.summary,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              height: 1.55,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          ...content.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _LegalSection(section: section),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalSection extends StatelessWidget {
  final _LegalSectionData section;

  const _LegalSection({required this.section});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            section.body,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalDocumentData {
  final String title;
  final String kicker;
  final String headline;
  final String summary;
  final List<_LegalSectionData> sections;

  const _LegalDocumentData({
    required this.title,
    required this.kicker,
    required this.headline,
    required this.summary,
    required this.sections,
  });
}

class _LegalSectionData {
  final String title;
  final String body;

  const _LegalSectionData({required this.title, required this.body});
}

abstract class _LegalContent {
  static const privacy = _LegalDocumentData(
    title: 'Приватность',
    kicker: 'ДАННЫЕ И СИСТЕМА',
    headline: 'Твои данные нужны только для персонального пути.',
    summary:
        'LEVL собирает минимум данных, чтобы собрать профиль, задачи дня, прогресс и работу AI-наставника. Мы не продаём данные и не используем их для рекламного трекинга.',
    sections: [
      _LegalSectionData(
        title: 'Что собираем',
        body:
            'Имя или псевдоним, идентификатор аккаунта, цели, сферы жизни, жизненный контекст, стиль работы, задачи, прогресс, streak, настройки уведомлений и сообщения AI-наставнику.',
      ),
      _LegalSectionData(
        title: 'Зачем это нужно',
        body:
            'Чтобы персонализировать онбординг, генерировать 3 действия на день, сохранять прогресс, синхронизировать данные между устройствами и улучшать качество рекомендаций.',
      ),
      _LegalSectionData(
        title: 'Где храним и кому передаём',
        body:
            'Локальная копия хранится на устройстве. Облачная копия хранится в Supabase. Для AI-функций часть контекста может отправляться AI-провайдеру через Supabase Edge Functions.',
      ),
      _LegalSectionData(
        title: 'Что не стоит вводить',
        body:
            'Не вводи медицинские диагнозы, финансовые реквизиты, паспортные данные, пароли, seed-фразы и другую сверхчувствительную информацию.',
      ),
      _LegalSectionData(
        title: 'Удаление данных',
        body:
            'В настройках можно запросить удаление аккаунта. LEVL удалит профиль, задачи, кеш задач, ежедневные отметки и аккаунт авторизации.',
      ),
    ],
  );

  static const terms = _LegalDocumentData(
    title: 'Условия',
    kicker: 'ОГРАНИЧЕНИЯ',
    headline: 'LEVL помогает действовать, но не заменяет специалиста.',
    summary:
        'Приложение даёт персональные подсказки и задачи для самоорганизации. Решения остаются за пользователем.',
    sections: [
      _LegalSectionData(
        title: 'Не медицинский сервис',
        body:
            'LEVL не является медицинским, психологическим, юридическим или финансовым сервисом. Рекомендации носят информационный характер.',
      ),
      _LegalSectionData(
        title: 'AI может ошибаться',
        body:
            'AI-наставник может дать неточный или неподходящий совет. Проверяй важные решения самостоятельно и обращайся к профильным специалистам, когда это нужно.',
      ),
      _LegalSectionData(
        title: 'Ответственность пользователя',
        body:
            'Ты сам выбираешь, какие задачи выполнять, сколько информации вводить и как применять рекомендации приложения в реальной жизни.',
      ),
      _LegalSectionData(
        title: 'Бесплатная версия',
        body:
            'Текущая версия может меняться: мы улучшаем сценарии, интерфейс, AI-логику и систему прогресса перед публичным релизом.',
      ),
    ],
  );
}
