import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    // 1. Trigger the native Google Sign-In flow
    const webClientId =
        'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com'; // User needs to replace this
    const iosClientId =
        'YOUR_IOS_CLIENT_ID.apps.googleusercontent.com'; // User needs to replace this

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );

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
    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
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

    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.facebook,
      idToken: accessToken, // For Facebook, we use the access token string
    );
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await GoogleSignIn().signOut();
    await FacebookAuth.instance.logOut();
  }
}
