# Add project specific ProGuard rules here.
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Prevent obfuscation of Flutter entry point
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class com.example.freelance_hub.MainActivity { *; }