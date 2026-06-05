# Vestie release — keep Flutter, Firebase, Stripe, and Gson/SignalR types.
# R8 is enabled by default in modern Android Gradle Plugin builds.

-keep class io.flutter.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.stripe.** { *; }
-keepattributes *Annotation*
