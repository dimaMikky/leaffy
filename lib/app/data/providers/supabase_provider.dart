import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProvider {
  final SupabaseClient client = Supabase.instance.client;

  // Cache the current user to prevent auth state issues
  User? _cachedUser;
  bool _isInitialized = false;

  // Initialize auth state and set up listeners
  void initAuthState() {
    if (_isInitialized) return;

    print("🔐 Initializing auth state");
    _cachedUser = client.auth.currentUser;
    print("🔑 Initial auth state: ${_cachedUser?.id ?? 'Not logged in'}");

    // Listen for auth changes
    client.auth.onAuthStateChange.listen((data) {
      print("🔄 Auth state changed: ${data.event}");
      _cachedUser = data.session?.user;
      print("👤 Updated cached user: ${_cachedUser?.id ?? 'null'}");
    });

    _isInitialized = true;
  }

  // Auth methods with improved error handling and logging
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    try {
      print("Attempting signup with Supabase for email: $email");
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      print("Signup successful: ${response.user?.id}");

      // Update cached user
      _cachedUser = response.user;

      return response;
    } catch (e) {
      print("Supabase signup error: $e");
      if (e is AuthException) {
        print("Auth error message: ${e.message}");
      }
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      print("🔑 Attempting sign in with email: $email");
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Update cached user
      _cachedUser = response.user;
      print("✅ Sign in successful, user ID: ${response.user?.id ?? 'null'}");

      return response;
    } catch (e) {
      print("❌ Sign in error: $e");
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      print("🚪 Signing out user: ${_cachedUser?.id ?? 'unknown'}");
      await client.auth.signOut();
      _cachedUser = null;
      print("👋 User signed out successfully");
    } catch (e) {
      print("❌ Sign out error: $e");
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      print("🔄 Requesting password reset for: $email");
      await client.auth.resetPasswordForEmail(email);
      print("📧 Password reset email sent");
    } catch (e) {
      print("❌ Password reset error: $e");
      rethrow;
    }
  }

  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      print("🔒 Updating password for user: ${_cachedUser?.id ?? 'unknown'}");
      final response = await client.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
      print("✅ Password updated successfully");
      return response;
    } catch (e) {
      print("❌ Password update error: $e");
      rethrow;
    }
  }

  // Google sign in
  Future<User?> signInWithGoogle() async {
    try {
      print("🔑 Initiating Google sign in");
      // Initiate OAuth flow
      final bool success = await client.auth.signInWithOAuth(
        Provider.google,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      // If the flow was initiated successfully
      if (success) {
        print("✅ Google auth redirect successful, waiting for callback");
        // The user will be redirected and eventually come back to the app
        // Instead of waiting, we should rely on the auth state change listener
        // but for fallback purposes, we'll check after a delay
        await Future.delayed(const Duration(seconds: 3));
        _cachedUser = client.auth.currentUser;
        print("👤 Google auth complete, user: ${_cachedUser?.id ?? 'null'}");
        return _cachedUser;
      }

      print("❌ Google auth redirect failed");
      return null;
    } catch (e) {
      print('❌ Error signing in with Google: $e');
      return null;
    }
  }

  // Apple sign in
  Future<User?> signInWithApple() async {
    try {
      print("🔑 Initiating Apple sign in");
      // Initiate OAuth flow
      final bool success = await client.auth.signInWithOAuth(
        Provider.apple,
        redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      // If the flow was initiated successfully
      if (success) {
        print("✅ Apple auth redirect successful, waiting for callback");
        // The user will be redirected and eventually come back to the app
        await Future.delayed(const Duration(seconds: 3));
        _cachedUser = client.auth.currentUser;
        print("👤 Apple auth complete, user: ${_cachedUser?.id ?? 'null'}");
        return _cachedUser;
      }

      print("❌ Apple auth redirect failed");
      return null;
    } catch (e) {
      print('❌ Error signing in with Apple: $e');
      return null;
    }
  }

  // Check if user is authenticated with refresh
  bool isAuthenticated() {
    // Refresh the cache to be certain
    _cachedUser = client.auth.currentUser;
    final isAuth = _cachedUser != null;
    print("🔒 isAuthenticated check: $isAuth");
    return isAuth;
  }

  // Get current user with improved caching
  User? getCurrentUser() {
    // If we haven't initialized yet, do it now
    if (!_isInitialized) {
      initAuthState();
    }

    // Refresh cache if needed (belt and suspenders approach)
    if (_cachedUser == null) {
      _cachedUser = client.auth.currentUser;
    }

    print("🔍 getCurrentUser called, result: ${_cachedUser?.id ?? 'null'}");
    return _cachedUser;
  }

  // Get current session with logging
  Session? getCurrentSession() {
    final session = client.auth.currentSession;
    print("📝 getCurrentSession called, has session: ${session != null}");
    return session;
  }

  // Force refresh the auth state
  Future<User?> refreshAuthState() async {
    try {
      print("🔄 Forcing auth state refresh");
      // This will either refresh the session or get the current session
      final session = await client.auth.refreshSession();
      _cachedUser = session.user;
      print("✅ Auth state refreshed, user: ${_cachedUser?.id ?? 'null'}");
      return _cachedUser;
    } catch (e) {
      print("❌ Auth refresh error: $e");
      // If refresh fails, fall back to current user
      _cachedUser = client.auth.currentUser;
      return _cachedUser;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get onAuthStateChange => client.auth.onAuthStateChange;

  // Check if the email exists (useful for signup/signin UX)
  Future<bool> checkIfEmailExists(String email) async {
    try {
      final result = await client.auth.resetPasswordForEmail(email);
      // If no exception, the email exists
      return true;
    } catch (e) {
      if (e is AuthException && e.message.contains('does not exist')) {
        return false;
      }
      // For any other error, assume it exists to be safe
      return true;
    }
  }
}
