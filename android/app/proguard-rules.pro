# 1. قواعد Supabase و Postgrest (عشان الـ Serialization والـ JSON)
-keep class io.supabase.** { *; }
-keep class org.postgresql.** { *; }

# 2. قواعد Firebase Cloud Messaging (عشان الإشعارات اللي لسه رابطينها)
-keep class com.google.firebase.** { *; }
-keepattributes *Annotation*

# 3. قواعد In-App Update (عشان التحديث اللي ضيفناه)
-keep class com.google.android.play.core.** { *; }

# 4. قواعد Flutter و الـ Plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }