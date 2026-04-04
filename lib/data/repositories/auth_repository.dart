import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/utils/encryption_helper.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Lưu mật khẩu (mã hóa) khi đăng ký
  Future<void> saveEncryptedPassword(String userId, String password) async {
    try {
      final encryptedPassword = EncryptionHelper.encrypt(password);
      await _supabase.from('users').update({
        'u_password': encryptedPassword,
      }).eq('auth_uid', userId);
    } catch (e) {
      throw 'Failed to save encrypted password: $e';
    }
  }

  /// Xác thực mật khẩu (giải mã và so sánh)
  Future<bool> verifyPassword(String userId, String inputPassword) async {
    try {
      final userData = await _supabase
          .from('users')
          .select('u_password')
          .eq('auth_uid', userId)
          .maybeSingle();

      if (userData == null || userData['u_password'] == null) {
        return false;
      }

      final encryptedPassword = userData['u_password'] as String;
      final decryptedPassword = EncryptionHelper.decrypt(encryptedPassword);
      
      return decryptedPassword == inputPassword;
    } catch (e) {
      throw 'Failed to verify password: $e';
    }
  }

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    // 1. Trigger the native Google Sign-In flow
    // Read Client IDs from .env file
    final webClientId = dotenv.get('GOOGLE_WEB_CLIENT_ID', fallback: '');
    final iosClientId = dotenv.get('GOOGLE_IOS_CLIENT_ID', fallback: '');

    if (webClientId.isEmpty) {
      throw 'Missing GOOGLE_WEB_CLIENT_ID in .env';
    }

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId.isEmpty ? null : iosClientId,
      serverClientId: webClientId,
    );

    // Force sign-out to show account picker if user wants to switch
    try {
      await googleSignIn.signOut();
    } catch (_) {}

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw 'Google Sign-In canceled by user';
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || idToken == null) {
      throw 'No Access Token/ID Token found from Google';
    }

    // 2. Sign in to Supabase with the ID Token
    final AuthResponse response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );

    // 3. Handle auto-creation of profile if it's a new user
    await _handleSocialLoginProfile(response.user);

    return response;
  }

  /// Sign in with Facebook
  Future<AuthResponse> signInWithFacebook() async {
    // 1. Trigger the native Facebook Login flow
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status != LoginStatus.success) {
      throw 'Facebook Login failed: ${result.message}';
    }

    // 2. Sign in to Supabase with the Access Token
    final accessToken = result.accessToken?.token;
    if (accessToken == null) {
      throw 'No Access Token found from Facebook';
    }

    final AuthResponse response = await _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.facebook,
      idToken: accessToken,
    );

    // 3. Handle auto-creation of profile if it's a new user
    await _handleSocialLoginProfile(response.user);

    return response;
  }

  /// Helper to create a default profile for social login users if they don't exist
  Future<void> _handleSocialLoginProfile(User? user) async {
    if (user == null) return;

    final userId = user.id;
    final email = user.email;
    final name = user.userMetadata?['full_name'] ?? 'Social User';

    // Check if user already exists in public.users table
    final existingUser = await _supabase
        .from('users')
        .select()
        .eq('auth_uid', userId)
        .maybeSingle();

    if (existingUser == null) {
      // Create new profile with default role (candidate)
      final insertedUser = await _supabase
          .from('users')
          .insert({
            'auth_uid': userId,
            'u_email': email,
            'u_name': name,
            'u_role': 'candidate', // Default role for social logins
          })
          .select('u_id')
          .single();

      final uId = insertedUser['u_id'] as int;

      // Also create record in candidates table
      await _supabase.from('candidates').insert({
        'u_id': uId,
        'c_full_name': name,
      });
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
