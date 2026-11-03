package tn.fluttiris.mihrab_tv

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Opens MIHRAB when the TV / box finishes booting, unless the user turned the
 * option off in the settings (stored by Flutter's shared_preferences).
 */
class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val action = intent.action ?: return

        if (action != Intent.ACTION_BOOT_COMPLETED &&
            action != "android.intent.action.QUICKBOOT_POWERON"
        ) {
            return
        }

        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE
        )

        // Enabled by default (a mosque screen should start by itself).
        if (!prefs.getBoolean("flutter.auto_start_enabled", true)) return

        val launch = Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        }

        try {
            context.startActivity(launch)
        } catch (_: Exception) {
            // Background start not allowed on this device: nothing else to do.
        }
    }
}
