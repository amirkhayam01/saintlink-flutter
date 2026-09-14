package uk.co.saintslink.saints_link

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.pm.PackageManager

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "uk.co.saintslink/maps")
            .setMethodCallHandler { call, result ->
                if (call.method == "browserKey") {
                    val info = packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                    result.success(info.metaData?.getString("uk.co.saintslink.MAPS_BROWSER_KEY") ?: "")
                } else {
                    result.notImplemented()
                }
            }
    }
}
