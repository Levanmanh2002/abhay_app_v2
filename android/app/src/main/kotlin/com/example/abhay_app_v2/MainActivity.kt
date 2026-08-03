package com.app.chaitany.abhay

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.AudioManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val AUDIO_MUTE_CHANNEL = "com.chaitany.abhay/audio_mute"
    private val VOSK_SOS_CHANNEL = "com.chaitany.abhay/vosk_sos"
    private val VOSK_EVENT_CHANNEL = "com.chaitany.abhay/vosk_sos_events"
    private var savedMusicVolume = -1

    private var eventSink: EventChannel.EventSink? = null
    private val keywordReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val keyword = intent?.getStringExtra("keyword") ?: return
            val text = intent.getStringExtra("text") ?: ""
            eventSink?.success(mapOf("keyword" to keyword, "text" to text))
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Mute/unmute STREAM_MUSIC quanh SpeechRecognizer start/stop (fix beep) ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUDIO_MUTE_CHANNEL).setMethodCallHandler { call, result ->
            val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
            when (call.method) {
                "mute" -> {
                    if (savedMusicVolume < 0) {
                        savedMusicVolume = audioManager.getStreamVolume(AudioManager.STREAM_MUSIC)
                    }
                    audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
                    result.success(null)
                }
                "unmute" -> {
                    if (savedMusicVolume >= 0) {
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, savedMusicVolume, 0)
                        savedMusicVolume = -1
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── Start/stop VoskSosService — service nghe SOS chạy vĩnh viễn, độc lập Flutter ──
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VOSK_SOS_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    val intent = Intent(this, VoskSosService::class.java).setAction(VoskSosService.ACTION_START)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) startForegroundService(intent) else startService(intent)
                    result.success(null)
                }
                "stop" -> {
                    val intent = Intent(this, VoskSosService::class.java).setAction(VoskSosService.ACTION_STOP)
                    startService(intent)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        // ── Forward sự kiện "phát hiện từ khoá" từ VoskSosService (native) vào Flutter (chỉ để cập nhật UI) ──
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, VOSK_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                    val filter = IntentFilter(VoskSosService.BROADCAST_KEYWORD_DETECTED)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                        registerReceiver(keywordReceiver, filter, Context.RECEIVER_NOT_EXPORTED)
                    } else {
                        registerReceiver(keywordReceiver, filter)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    try {
                        unregisterReceiver(keywordReceiver)
                    } catch (_: Exception) {}
                }
            }
        )
    }
}
