import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_service.dart';

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
    return ChatState(
      messages: [
        ChatMessage(
          content: 'Система на связи. О чём думаешь?',
          isUser: false,
        ),
      ],
    );
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

      final apiMessages = state.messages
          .map((m) => m.toApi())
          .toList();

      final response = await client.functions.invoke(
        'ai-mentor',
        method: HttpMethod.post,
        body: {'messages': apiMessages},
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

  /// Clear chat history.
  void clearChat() {
    state = ChatState(
      messages: [
        ChatMessage(
          content: 'Система на связи. О чём думаешь?',
          isUser: false,
        ),
      ],
    );
  }
}
