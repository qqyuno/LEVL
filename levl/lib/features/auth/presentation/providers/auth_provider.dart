import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_service.dart';

part 'auth_provider.g.dart';

const _localGuestModeKey = 'levl.local_guest_mode';

/// Local-only guest fallback for demo/offline use.
///
/// Supabase anonymous auth should be the primary guest path, but this keeps the
/// onboarding available when anonymous sign-in is disabled or unavailable.
final localGuestModeProvider = StateProvider<bool>((ref) => false);

/// Auth state — streamed from Supabase auth changes.
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  StreamSubscription<AuthState>? _sub;

  @override
  AsyncValue<Session?> build() {
    final client = ref.watch(supabaseClientProvider);
    final currentSession = client.auth.currentSession;

    _restoreLocalGuestMode();

    _sub?.cancel();
    _sub = client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        _setLocalGuestMode(false);
      }
      state = AsyncData(data.session);
    });

    ref.onDispose(() => _sub?.cancel());

    return AsyncData(currentSession);
  }

  /// Sign in with Google OAuth (opens external browser, returns via deep link).
  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.levl://login-callback/',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Sign in with Apple.
  /// iOS: native Sign in with Apple (required by App Store).
  /// Android/other: web OAuth flow.
  Future<void> signInWithApple() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);

      if (Platform.isIOS || Platform.isMacOS) {
        // --- Native flow ---
        final rawNonce = _generateNonce();
        final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: const [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
          nonce: hashedNonce,
        );

        final idToken = credential.identityToken;
        if (idToken == null) {
          throw const AuthException('Apple не вернул identityToken');
        }

        final response = await client.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        );

        state = AsyncData(response.session);
      } else {
        // --- Web OAuth fallback (Android, Windows, Linux) ---
        await client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: 'io.supabase.levl://login-callback/',
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      }
    } on SignInWithAppleAuthorizationException catch (e, st) {
      // User cancelled → return to idle, don't show as error
      if (e.code == AuthorizationErrorCode.canceled) {
        state = AsyncData(ref.read(supabaseClientProvider).auth.currentSession);
        return;
      }
      state = AsyncError(e, st);
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
      await _setLocalGuestMode(false);
      state = AsyncData(response.session);
    } catch (_) {
      await _setLocalGuestMode(true);
      state = const AsyncData(null);
    }
  }

  /// Sign out and clear session.
  Future<void> signOut() async {
    try {
      final client = ref.read(supabaseClientProvider);
      await _setLocalGuestMode(false);
      await client.auth.signOut();
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Delete the current account through a Supabase Edge Function.
  ///
  /// The mobile app must never hold a service-role key. The Edge Function
  /// validates the user's JWT, deletes app rows, then removes the auth user.
  Future<void> deleteAccount() async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supabaseClientProvider);
      if (client.auth.currentSession == null &&
          ref.read(localGuestModeProvider)) {
        await _setLocalGuestMode(false);
        state = const AsyncData(null);
        return;
      }

      final response = await client.functions.invoke(
        'delete-account',
        method: HttpMethod.post,
      );

      final data = response.data;
      if (data is Map && data['error'] != null) {
        throw AuthException(data['error'].toString());
      }

      try {
        await client.auth.signOut();
      } catch (_) {
        // The server may already have invalidated the auth user.
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _restoreLocalGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_localGuestModeKey) ?? false;
      ref.read(localGuestModeProvider.notifier).state = enabled;
    } catch (_) {}
  }

  Future<void> _setLocalGuestMode(bool enabled) async {
    ref.read(localGuestModeProvider.notifier).state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_localGuestModeKey, enabled);
  }

  /// Cryptographically secure random nonce for Apple Sign-In.
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}

/// Convenience provider: true if user is logged in.
@Riverpod(keepAlive: true)
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  final isLocalGuest = ref.watch(localGuestModeProvider);
  final hasSession =
      authState.whenOrNull(data: (session) => session != null) ?? false;
  return hasSession || isLocalGuest;
}
