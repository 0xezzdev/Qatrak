import 'package:flutter/material.dart';
import 'package:qatrak/core/widget/custom_snackbar.dart';
import 'package:qatrak/services/supabase_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthServices {
  final supabase = SupabaseService.client;

  Future<void> signUpNewUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = res.user;
    if (user == null) {
      throw Exception("Signup failed");
    }
  }

  Future<void> signInUser({
    required String email,
    required String password,
  }) async {
    final res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = res.user;
    if (user == null) {
      throw Exception("Login failed");
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '266261413340-6mln700mee8me59kt442o7j00e414jfc.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Cancelled',
            message: 'Google sign-in was cancelled.',
            icon: Icons.cancel,
            color: Colors.orange,
          ),
        );
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: 'Failed to retrieve Google ID token.',
            icon: Icons.error_outline,
            color: Colors.red,
          ),
        );
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Failed to retrieve Google ID token."),
            ),
          );
        }
        return;
      }

      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          title: 'Success',
          message: 'Successfully signed in with Google!',
          icon: Icons.check,
          color: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(
          title: "Authentication Error",
          message: e.toString().contains("provider_disabled")
              ? "Google Sign-In is currently disabled. Please try again later."
              : "Failed to sign in with Google.",
          icon: Icons.error,
          color: Colors.red,
        ),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: 'Error',
            message: 'Failed to sign in with Google.',
            icon: Icons.error,
            color: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> sendPasswordResetOTP(String email) async {
    try {
      print("Loli: Attempting to send OTP to $email...");
      await supabase.auth.resetPasswordForEmail(email);
      print("Loli: OTP sent successfully!");
    } catch (e) {
      print("Loli Error: ${e.toString()}");
      rethrow;
    }
  }

  Future<void> verifyOTP({required String email, required String token}) async {
    await Supabase.instance.client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.recovery,
    );
  }

  Future<void> signOutUser() async {
    await supabase.auth.signOut();
  }
}
