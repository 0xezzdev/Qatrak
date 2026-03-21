import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:qatrak/core/strings/app_strings.dart';
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

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId:
            '266261413340-6mln700mee8me59kt442o7j00e414jfc.apps.googleusercontent.com',
      );

      await googleSignIn.signOut();

      final googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              title: AppStrings.googleCancelledMessageTitle.tr(),
              message: AppStrings.googleCancelledMessage.tr(),
              icon: Icons.cancel,
              color: Colors.orange,
            ),
          );
        }
        return null;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar(
              title: AppStrings.googleFaildTokenMessageTitle.tr(),
              message: AppStrings.googleFaildTokenMessage.tr(),
              icon: Icons.error_outline,
              color: Colors.red,
            ),
          );
        }
        return null;
      }

      final AuthResponse res = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: AppStrings.googleSeccessMessageTitle.tr(),
            message: AppStrings.googleSeccessMessage.tr(),
            icon: Icons.check,
            color: Colors.green,
          ),
        );
      }
      return res.user; 

    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar(
            title: AppStrings.authErrorTitle.tr(),
            message: e.toString().contains("provider_disabled")
                ? AppStrings.googleDisabledMessage.tr()
                : AppStrings.googleSignInError.tr(),
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
