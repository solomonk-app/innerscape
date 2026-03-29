# flutter_local_notifications - keep all classes and generic type info
-keep class com.dexterous.** { *; }
-keepclassmembers class com.dexterous.** { *; }

# Gson - keep generic type info for TypeToken
-keep class com.google.gson.** { *; }
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Meta Audience Network (Facebook) mediation - suppress missing annotation warnings
-dontwarn com.facebook.infer.annotation.Nullsafe$Mode
-dontwarn com.facebook.infer.annotation.Nullsafe

# Keep generic signatures for all classes used by notifications
-keepclassmembers,allowobfuscation class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
