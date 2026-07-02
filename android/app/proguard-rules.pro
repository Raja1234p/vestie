# =============================================================================
# Vestie Android release — R8 / ProGuard rules
# Used when minifyEnabled=true in android/app/build.gradle.kts
#
# stripe_android also ships consumerProguardFiles (merged automatically).
# =============================================================================

# -----------------------------------------------------------------------------
# Flutter embedding & generated plugin registrant
# -----------------------------------------------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class dev.flutter.pigeon.** { *; }
-dontwarn io.flutter.embedding.**

# -----------------------------------------------------------------------------
# Stack traces & reflection metadata
# -----------------------------------------------------------------------------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
-keepattributes Signature
-keepattributes InnerClasses,EnclosingMethod
-keepattributes *Annotation*
-keepattributes Exceptions

# JNI, Parcelable, enums
-keepclasseswithmembernames class * {
    native <methods>;
}
-keepclassmembers class * implements android.os.Parcelable {
    public static final ** CREATOR;
}
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# -----------------------------------------------------------------------------
# Vestie app entry (deep links, Stripe redirect, invite intents)
# -----------------------------------------------------------------------------
-keep class app.vestie.MainActivity { *; }

# -----------------------------------------------------------------------------
# AndroidX Lifecycle (flutter_plugin_android_lifecycle / Stripe)
# https://issuetracker.google.com/issues/142778206
# -----------------------------------------------------------------------------
-keep class androidx.lifecycle.DefaultLifecycleObserver { *; }

# -----------------------------------------------------------------------------
# Gson (Stripe SDK + JSON reflection)
# -----------------------------------------------------------------------------
-dontwarn sun.misc.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}
-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken

# -----------------------------------------------------------------------------
# OkHttp / Okio (Stripe networking)
# -----------------------------------------------------------------------------
-dontwarn okhttp3.**
-dontwarn okio.**
-keepnames class okhttp3.internal.publicsuffix.PublicSuffixDatabase
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# -----------------------------------------------------------------------------
# Kotlin / coroutines / parcelize (Stripe SDK)
# -----------------------------------------------------------------------------
-dontwarn kotlin.**
-keep class kotlin.Metadata { *; }
-dontwarn kotlinx.parcelize.Parceler$DefaultImpls
-dontwarn kotlinx.parcelize.Parceler
-dontwarn kotlinx.parcelize.Parcelize
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembers class kotlinx.** {
    volatile <fields>;
}
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers class kotlinx.serialization.json.** {
    *** Companion;
}
-keepclasseswithmembers class kotlinx.serialization.json.** {
    kotlinx.serialization.KSerializer serializer(...);
}

# -----------------------------------------------------------------------------
# Firebase & Google Play services (FCM, auth, messaging)
# -----------------------------------------------------------------------------
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
-keep class io.flutter.plugins.firebase.** { *; }
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.iid.** { *; }

# FlutterFire messaging — background isolate + JobIntentService path
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingService { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingReceiver { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundExecutor { *; }
-keep class io.flutter.plugins.firebase.messaging.JobIntentService { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingInitProvider { *; }
-keep class io.flutter.plugins.firebase.messaging.FlutterFirebaseAppRegistrar { *; }

# -----------------------------------------------------------------------------
# Push notifications — flutter_local_notifications
# -----------------------------------------------------------------------------
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.NotificationCompat** { *; }
-keep class com.dexterous.flutterlocalnotifications.ForegroundService { *; }

# -----------------------------------------------------------------------------
# Stripe (flutter_stripe / stripe_android — mirrors official consumer rules)
# Fixes 3DS / PaymentSheet crashes when R8 strips payment flow classes.
# -----------------------------------------------------------------------------
-keep class com.stripe.** { *; }
-keepclassmembers class com.google.android.gms.tapandpay.** {
    public *;
}
-keepclassmembers class com.stripe.android.pushProvisioning.** {
    public *;
}
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider
-dontwarn com.stripe.hcaptcha.**
-dontwarn dagger.**
-keep class dagger.** { *; }
-keep class javax.inject.** { *; }

# Fresco (Stripe image pipeline)
-keep class com.facebook.fresco.** { *; }
-keep class com.facebook.imagepipeline.** { *; }
-dontwarn com.facebook.**

# Stripe UI dependencies
-keep class com.google.android.material.** { *; }
-keep class androidx.appcompat.** { *; }
-keep class androidx.fragment.app.** { *; }

# -----------------------------------------------------------------------------
# Google Sign-In
# -----------------------------------------------------------------------------
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-keep class io.flutter.plugins.googlesignin.** { *; }

# Google Pay / Wallet (PaymentSheet)
-keep class com.google.android.gms.wallet.** { *; }

# -----------------------------------------------------------------------------
# Deep linking & OAuth callbacks
# app_links, flutter_web_auth_2, url_launcher
# -----------------------------------------------------------------------------
-keep class com.llfbandit.app_links.** { *; }
-keep class com.linusu.flutter_web_auth_2.** { *; }
-keep class androidx.browser.** { *; }
-keep class io.flutter.plugins.urllauncher.** { *; }

# -----------------------------------------------------------------------------
# Secure storage & preferences (auth tokens, FCM token cache)
# -----------------------------------------------------------------------------
-keep class com.it_nomads.fluttersecurestorage.** { *; }
-keep class androidx.security.crypto.** { *; }
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# -----------------------------------------------------------------------------
# Device info, connectivity, permissions
# -----------------------------------------------------------------------------
-keep class dev.fluttercommunity.plus.device_info.** { *; }
-keep class dev.fluttercommunity.plus.connectivity.** { *; }
-keep class com.baseflow.permissionhandler.** { *; }

# -----------------------------------------------------------------------------
# Media & sharing
# -----------------------------------------------------------------------------
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class dev.fluttercommunity.plus.share.** { *; }
-keep class io.flutter.plugins.flutter_plugin_android_lifecycle.** { *; }

# -----------------------------------------------------------------------------
# SSL / crypto (networking)
# -----------------------------------------------------------------------------
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**

# -----------------------------------------------------------------------------
# Flutter deferred components — optional Play Core references
# -----------------------------------------------------------------------------
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task
