import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_service.dart';

part 'auth_provider.g.dart';

/// Auth state — streamed from Supabase auth changes.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<AuthState>? _sub;

  @override
  AsyncValue<Session?> build() {
    final client = ref.watch(supabaseClientProvider);
    final currentSession = client.auth.currentSession;

    // Listen to auth state changes
    _sub?.cancel();
    _sub = client.auth.onAuthStateChange.listen((data) {
      state = AsyncData(data.session);
    });

    ref.onDispose(() => _sub?.cancel());

    return AsyncData(currentSession);
  }

  /// Sign in with Google OAuth (opens browser/webview).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.levl://login-callback/',
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Sign in with Apple OAuth (opens browser/webview).
  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'io.supabase.levl://login-callback/',
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Sign in anonymously (guest mode).
  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      final response = await client.auth.signInAnonymously();
      state = AsyncData(response.session);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Sign out and clear session.
  Future<void> signOut() async {
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Convenience provider: true if user is logged in.
@Riverpod(keepAlive: true)
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (session) => session != null) ?? false;
}
