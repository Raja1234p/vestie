package app.vestie

import android.app.Activity
import android.app.Application
import android.os.Build
import android.os.Bundle
import android.view.View
import io.flutter.embedding.android.FlutterFragmentActivity

/**
 * Stripe PaymentSheet / card entry can trigger an Android autofill + fonts race
 * that reboots some devices (flutter-stripe#2367). Autofill is disabled only for
 * activities whose component name contains "stripe" — Flutter screens keep
 * normal autofill (login, profile, etc.).
 */
class MainActivity : FlutterFragmentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        registerStripeAutofillGuard()
    }

    private fun registerStripeAutofillGuard() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return

        application.registerActivityLifecycleCallbacks(
            object : Application.ActivityLifecycleCallbacks {
                override fun onActivityCreated(
                    activity: Activity,
                    savedInstanceState: Bundle?,
                ) {
                    val className = activity.componentName.className.lowercase()
                    if (!className.contains("stripe")) return
                    activity.window.decorView.importantForAutofill =
                        View.IMPORTANT_FOR_AUTOFILL_NO_EXCLUDE_DESCENDANTS
                }

                override fun onActivityStarted(activity: Activity) {}

                override fun onActivityResumed(activity: Activity) {}

                override fun onActivityPaused(activity: Activity) {}

                override fun onActivityStopped(activity: Activity) {}

                override fun onActivitySaveInstanceState(
                    activity: Activity,
                    outState: Bundle,
                ) {}

                override fun onActivityDestroyed(activity: Activity) {}
            },
        )
    }
}
