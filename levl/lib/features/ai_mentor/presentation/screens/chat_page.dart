import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/models/quest_model.dart';
import '../../../../shared/models/user_model.dart';
import '../../../dashboard/presentation/providers/quest_provider.dart';
import '../providers/chat_provider.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.selectionClick();
    _controller.clear();
    _focusNode.unfocus();
    ref.read(chatNotifierProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _preparePrompt(String prompt) {
    HapticFeedback.selectionClick();
    _controller
      ..text = prompt
      ..selection = TextSelection.collapsed(offset: prompt.length);
    _focusNode.requestFocus();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted || !_scrollController.hasClients) return;
      final position = _scrollController.position.maxScrollExtent;
      if (MediaQuery.disableAnimationsOf(context)) {
        _scrollController.jumpTo(position);
      } else {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final user = ref.watch(userProfileNotifierProvider).valueOrNull;
    final quests =
        ref.watch(questNotifierProvider).valueOrNull ?? const <Quest>[];

    ref.listen(chatNotifierProvider, (prev, next) {
      final previousCount = prev?.messages.length ?? 0;
      if (previousCount > 0 && previousCount < next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _SystemHeader(
              canClear: chatState.messages.length > 1,
              onClear: () =>
                  ref.read(chatNotifierProvider.notifier).clearChat(),
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _SystemBriefing(user: user, quests: quests),
                  const SizedBox(height: 24),
                  Text(
                    'БЫСТРЫЙ РАЗБОР',
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _CommandRow(
                    icon: Icons.route_outlined,
                    title: 'Пересобрать день',
                    subtitle: 'Расставить действия по приоритету',
                    onTap: () => _preparePrompt(
                      'Помоги пересобрать мой день: что оставить, что убрать и с чего начать?',
                    ),
                  ),
                  _CommandRow(
                    icon: Icons.filter_center_focus_outlined,
                    title: 'Разобрать препятствие',
                    subtitle: 'Найти следующий конкретный шаг',
                    onTap: () => _preparePrompt(
                      'Я застрял на важной задаче. Помоги понять препятствие и выбрать следующий шаг.',
                    ),
                  ),
                  _CommandRow(
                    icon: Icons.fact_check_outlined,
                    title: 'Подвести итоги',
                    subtitle: 'Зафиксировать результат без самообмана',
                    onTap: () => _preparePrompt(
                      'Помоги коротко подвести итоги дня: что сработало и что изменить завтра?',
                    ),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Text(
                        'ДИАЛОГ',
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'контекст сохраняется',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.textDisabled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (chatState.messages.isEmpty && !chatState.isLoading)
                    const _ConnectingState(),
                  for (final message in chatState.messages)
                    _MessageBubble(message: message),
                  if (chatState.isLoading) const _TypingIndicator(),
                  if (chatState.error != null)
                    _ConnectionError(message: chatState.error!),
                ],
              ),
            ),
            _MessageComposer(
              controller: _controller,
              focusNode: _focusNode,
              isLoading: chatState.isLoading,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemHeader extends StatelessWidget {
  final bool canClear;
  final VoidCallback onClear;

  const _SystemHeader({required this.canClear, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Система',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 26,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                'КОМАНДНЫЙ ЦЕНТР',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDisabled,
                  letterSpacing: 1.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (canClear)
            IconButton(
              tooltip: 'Очистить диалог',
              onPressed: onClear,
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.textSecondary,
                size: 21,
              ),
            ),
        ],
      ),
    );
  }
}

class _SystemBriefing extends StatelessWidget {
  final UserProfile? user;
  final List<Quest> quests;

  const _SystemBriefing({required this.user, required this.quests});

  @override
  Widget build(BuildContext context) {
    final completed =
        quests.where((q) => q.status == QuestStatus.completed).length;
    final total = quests.length;
    final remaining = (total - completed).clamp(0, total);
    final progress = total == 0 ? 0.0 : completed / total;
    final allDone = total > 0 && remaining == 0;
    final goal = user?.mainGoal.trim() ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'СИСТЕМА АКТИВНА',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Text(
                'УР. ${user?.level ?? 1}',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            allDone
                ? 'День закрыт. Ритм сохранён.'
                : total == 0
                    ? 'Готов к первому решению.'
                    : 'Осталось действий: $remaining',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 24,
              color: AppColors.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            goal.isEmpty
                ? 'Назови, что сейчас требует ясности. Система поможет превратить мысль в действие.'
                : 'Текущий вектор: $goal',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.textPrimary),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            total == 0
                ? 'Задания ещё загружаются'
                : '$completed из $total выполнено',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: AppColors.textDisabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _CommandRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CommandRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSend;

  const _MessageComposer({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => isLoading ? null : onSend(),
              style: GoogleFonts.dmSans(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Что нужно разобрать?',
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 15,
                  color: AppColors.textDisabled,
                ),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.textPrimary),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Отправить Системе',
            onPressed: isLoading ? null : onSend,
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              backgroundColor: AppColors.textPrimary,
              disabledBackgroundColor: AppColors.divider,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.arrow_upward_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.textPrimary,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                'L',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.surface,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? AppColors.textPrimary : AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: isUser ? null : Border.all(color: AppColors.divider),
              ),
              child: Text(
                message.content,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  color: isUser ? AppColors.surface : AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 38),
        ],
      ),
    );
  }
}

class _ConnectingState extends StatelessWidget {
  const _ConnectingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'Система собирает контекст…',
        style: GoogleFonts.dmSans(
          fontSize: 13,
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}

class _ConnectionError extends StatelessWidget {
  final String message;

  const _ConnectionError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
        ),
        child: Text(
          '$message Сообщение осталось в диалоге.',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            color: AppColors.error,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !MediaQuery.disableAnimationsOf(context)) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Система готовит ответ',
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 38, bottom: 12),
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final count =
                  1 + (_controller.value * 3).floor().clamp(0, 2).toInt();
              return Text(
                'Система думает${List.filled(count, '.').join()}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.textDisabled,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
