import 'package:qatrak/services/supabase_service.dart';

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

  Future<void> signOutUser() async {
    await supabase.auth.signOut();
  }
}
