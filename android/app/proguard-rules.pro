# 1. قواعد Supabase و Postgrest
-keep class io.supabase.** { *; }
-keep class org.postgresql.** { *; }

# 2. قواعد Firebase Cloud Messaging
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*

# 3. قواعد In-App Update
-keep class com.google.android.play.core.** { *; }

# 4. قواعد Flutter و الـ Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# حل مشكلة الـ Missing classes لـ Play Store Split Install
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }

# قواعد إضافية لضمان إن فلاتر والـ R8 يتفاهموا
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }