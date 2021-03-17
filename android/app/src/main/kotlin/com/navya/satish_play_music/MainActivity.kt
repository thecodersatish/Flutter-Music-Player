package com.navya.satish_play_music
import android.content.Intent
import android.media.RingtoneManager
import android.net.Uri
import android.widget.Toast
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "ringtone"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "setringtone") {
                gettingperm((call.argument("arg")))
            } else {
                result.notImplemented()
            }
        }
    }

    fun gettingperm(argFromFlutter : String?){

        if(android.provider.Settings.System.canWrite(context)){
            println("its true")
            setRintone(argFromFlutter)
            return }
        else{
            openAndroidPermissionsMenu();
            if(android.provider.Settings.System.canWrite(context)){
                setRintone(argFromFlutter)
            }
            return }
    }

    fun openAndroidPermissionsMenu(){
        var intent:Intent = Intent(android.provider.Settings.ACTION_MANAGE_WRITE_SETTINGS);
        intent.setData(Uri.parse("package:" + context.getPackageName()));
        context.startActivity(intent);
    }

    private fun setRintone(argFromFlutter : String?){
        RingtoneManager.setActualDefaultRingtoneUri(this,
                RingtoneManager.TYPE_RINGTONE,Uri.parse(argFromFlutter));
        Toast.makeText(this, "Ringtone Changed SuccessFully", Toast.LENGTH_SHORT).show()
    }
}