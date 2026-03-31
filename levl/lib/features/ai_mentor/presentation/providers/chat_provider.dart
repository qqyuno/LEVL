import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/isar_service.dart';
import '../../../../core/supabase/supabase_service.dart';
import '../../../../shared/models/user_model.dart';

part 'chat_provider.g.dart';

/// A single chat message.
@immutable
class ChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toApi() => {
    'role': isUser ? 'user' : 'assistant',
    'content': content,
  };
}

/// Chat state — messages list + loading flag.
@immutable
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

@Riverpod(keepAlive: true)
class ChatNotifier extends _$ChatNotifier {
  @override
  ChatState build() {
    // Start with default, personalize immediately from local profile
    Future.microtask(_initGreeting);
    return const ChatState();
  }

  /// Load profile from Isar and set a personalized greeting.
  Future<void> _initGreeting() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final profiles = await isar.userProfileLocals.where().findAll();
      final profile = profiles.firstOrNull;
      final greeting = _personalizedGreeting(profile);
      state = state.copyWith(
        messages: [ChatMessage(content: greeting, isUser: false)],
      );
    } catch (_) {
      state = state.copyWith(
        messages: [ChatMessage(content: 'Система на связи. О чём думаешь?', isUser: false)],
      );
    }
  }

  /// Build a greeting based on streak, level, and context.
  String _personalizedGreeting(UserProfileLocal? profile) {
    if (profile == null) return 'Система на связи. О чём думаешь?';

    final streak = profile.currentStreak;
    final level = profile.level;
    final name = profile.name;

    if (streak >= 100) return 'Сто дней. Система фиксирует: ты изменился.';
    if (streak >= 30) return 'Тридцать дней подряд. Это уже не случайность.';
    if (streak >= 7) return '$streak дней подряд. Ты уже не тот, что был неделю назад.';
    if (streak >= 3) return 'Три дня подряд — это уже ритм, $name. О чём думаешь?';
    if (level >= 10) return 'Уровень $level. Немногие доходят сюда. Что на уме?';
    if (level >= 5) return 'Уровень $level. Система наблюдает. О чём думаешь?';
    if (profile.mainGoal.isNotEmpty) {
      return 'Система зафиксировала цель. Что мешает прямо сейчас?';
    }
    return 'Система на связи. О чём думаешь?';
  }

  /// Read profile from Isar and build context map for the Edge Function.
  Future<Map<String, dynamic>> _buildUserContext() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final profiles = await isar.userProfileLocals.where().findAll();
      final profile = profiles.firstOrNull;
      if (profile == null) return {};

      List<dynamic> goals = [];
      try {
        if (profile.goalsJson.isNotEmpty) {
          goals = jsonDecode(profile.goalsJson) as List;
        }
      } catch (_) {}

      return {
        'name': profile.name,
        'level': profile.level,
        'xp': profile.xp,
        'streak': profile.currentStreak,
        'mainGoal': profile.mainGoal,
        'lifeContext': profile.lifeContext,
        'workStyle': profile.workStyle,
        'dailyMinutes': profile.dailyMinutes,
        'spheres': profile.spheresJson,
        'goals': goals,
      };
    } catch (_) {
      return {};
    }
  }

  /// Send a user message and get System's response.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isLoading) return;

    final userMsg = ChatMessage(
      content: text.trim(),
      isUser: true,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      final client = ref.read(supabaseClientProvider);
      final userContext = await _buildUserContext();

      final apiMessages = state.messages
          .map((m) => m.toApi())
          .toList();

      final response = await client.functions.invoke(
        'ai-mentor',
        method: HttpMethod.post,
        body: {
          'messages': apiMessages,
          'userContext': userContext,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final reply = data['reply'] as String? ?? '';

      if (reply.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Система молчит. Попробуй позже.',
        );
        return;
      }

      final assistantMsg = ChatMessage(
        content: reply,
        isUser: false,
      );

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Нет связи с Системой.',
      );
    }
  }

  /// Clear chat history and re-generate personalized greeting.
  void clearChat() {
    state = const ChatState();
    Future.microtask(_initGreeting);
  }
}
