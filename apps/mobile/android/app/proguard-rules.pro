# Flutter ProGuard Rules

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep standard library classes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-keepattributes SourceFile,LineNumberTable

# Drift/SQLite specific rules if needed
-keep class net.sqlcipher.** { *; }
-dontwarn net.sqlcipher.**

# Google Play Core rules to fix R8 missing classes
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Add specific rules for other plugins here
