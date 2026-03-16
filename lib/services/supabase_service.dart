import 'package:supabase_flutter/supabase_flutter.dart';
class SupabaseService {
  static Future<void> init() async {
    await Supabase.initialize(
      url: "https://dggdkaotdkiopirhxaiz.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRnZ2RrYW90ZGtpb3Bpcmh4YWl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM2NjkwNzgsImV4cCI6MjA4OTI0NTA3OH0.w_On3Q02A0Z7jkqjJUV-q2_PPRxwSqFsuK08Bl0W8RQ",
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => Supabase.instance.client.auth;
}