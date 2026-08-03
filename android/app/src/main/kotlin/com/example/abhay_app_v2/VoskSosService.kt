package com.app.chaitany.abhay

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.SharedPreferences
import android.location.Location
import android.location.LocationManager
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import org.json.JSONObject
import org.vosk.Model
import org.vosk.Recognizer
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import org.vosk.android.StorageService
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.text.Normalizer
import java.util.regex.Pattern

/**
 * Service nghe từ khoá SOS CHẠY VĨNH VIỄN, không phụ thuộc Flutter isolate.
 *
 * Khác với android.speech.SpeechRecognizer (Google) — vốn chỉ hỗ trợ từng
 * "session" ngắn rồi tự đóng — Vosk's SpeechService quản lý 1 luồng
 * android.media.AudioRecord chạy liên tục nội bộ, KHÔNG có khái niệm session
 * timeout. Gọi start() 1 lần, nó nghe tới khi mình tự gọi stop() — đúng yêu
 * cầu "bật rồi bật vĩnh viễn, không ngắt/connect lại".
 *
 * Service này hoàn toàn độc lập với Dart/Flutter: kể cả khi Flutter engine
 * đã bị Android giết hẳn, nó vẫn tự:
 *  - Đọc token/setting từ SharedPreferences (chung file với gói
 *    shared_preferences bên Flutter — xem ghi chú PREFS_NAME/keyOf bên dưới)
 *  - Nhận diện từ khoá
 *  - Gọi thẳng HTTP POST gửi SOS
 *  - Bắn LocalBroadcast để MainActivity forward qua Flutter (nếu Flutter
 *    đang sống) để cập nhật UI — không bắt buộc, chỉ để hiển thị.
 */
class VoskSosService : Service(), RecognitionListener {

    companion object {
        const val ACTION_START = "com.chaitany.abhay.action.START_VOSK_SOS"
        const val ACTION_STOP = "com.chaitany.abhay.action.STOP_VOSK_SOS"
        const val BROADCAST_KEYWORD_DETECTED = "com.chaitany.abhay.VOSK_KEYWORD_DETECTED"

        private const val CHANNEL_ID = "vosk_sos_channel"
        private const val NOTIFICATION_ID = 1002

        // Đường dẫn assets chứa model đã unpack — XEM GHI CHÚ CUỐI FILE về
        // việc phải tự tải model Vosk và bỏ vào android/app/src/main/assets/
        private const val MODEL_ASSET_PATH = "model-vi"

        // shared_preferences (Flutter) lưu ở file "FlutterSharedPreferences",
        // mỗi key được prefix "flutter." — PHẢI đọc đúng format này thì mới
        // ra cùng dữ liệu Dart đã set (token, cached_recipient_count, ...).
        private const val PREFS_NAME = "FlutterSharedPreferences"
        private fun keyOf(dartKey: String) = "flutter.$dartKey"

        private val KEYWORDS = listOf(
            "help", "help me", "sos", "emergency", "save me", "danger",
            "accident", "call police", "call 911", "i need help", "ok",
            "cứu", "cứu với", "cứu tôi", "giúp tôi", "khẩn cấp", "nguy hiểm", "tai nạn", "hiem hoa"
        )

        private const val COOLDOWN_MS = 5000L
    }

    private var model: Model? = null
    private var speechService: SpeechService? = null
    private lateinit var prefs: SharedPreferences
    private var lastDetectedAt = 0L
    private var lastLocation: Location? = null

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences(PREFS_NAME, MODE_PRIVATE)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_STOP -> {
                stopListening()
                stopSelf()
                return START_NOT_STICKY
            }
            else -> startForegroundAndListen()
        }
        // START_STICKY: Android tự khởi động lại service nếu bị OS kill vì thiếu RAM
        return START_STICKY
    }

    // ─── Setup ──────────────────────────────────────────────────────────────

    private fun startForegroundAndListen() {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SOS voice monitoring")
            .setContentText("Đang lắng nghe từ khoá SOS liên tục")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()
        startForeground(NOTIFICATION_ID, notification)

        if (speechService != null) return // đã đang chạy rồi

        StorageService.unpack(
            this, MODEL_ASSET_PATH, "model",
            { loadedModel: Model ->
                model = loadedModel
                startListening()
            },
            { exception: Exception ->
                // In message thật của exception lên notification để debug không cần logcat
                exception.printStackTrace()
                val shortMsg = (exception.message ?: exception.toString()).take(120)
                updateNotification("Lỗi model: $shortMsg")
            }
        )
    }

    private fun startListening() {
        val m = model ?: return
        try {
            val recognizer = Recognizer(m, 16000.0f)
            speechService = SpeechService(recognizer, 16000.0f)
            speechService?.startListening(this)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun stopListening() {
        speechService?.stop()
        speechService?.shutdown()
        speechService = null
    }

    override fun onDestroy() {
        stopListening()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    // ─── RecognitionListener (Vosk) ───────────────────────────────────────────

    override fun onPartialResult(hypothesis: String?) = checkKeyword(hypothesis)

    override fun onResult(hypothesis: String?) = checkKeyword(hypothesis)

    override fun onFinalResult(hypothesis: String?) = checkKeyword(hypothesis)

    override fun onError(e: Exception?) {
        // Vosk hiếm khi lỗi kiểu "hết session" như SpeechRecognizer — nếu có lỗi
        // thật (mic bị app khác chiếm...) thì thử khởi động lại sau 1s.
        e?.printStackTrace()
        speechService = null
        android.os.Handler(mainLooper).postDelayed({ startListening() }, 1000)
    }

    override fun onTimeout() {
        // Không dùng timeout của Vosk (mặc định không giới hạn) — no-op
    }

    // ─── Keyword matching (đơn giản hoá từ VoiceKeywordService bên Dart) ─────

    private fun checkKeyword(hypothesisJson: String?) {
        if (hypothesisJson.isNullOrEmpty()) return
        val text = try {
            JSONObject(hypothesisJson).optString("text", "").ifEmpty {
                JSONObject(hypothesisJson).optString("partial", "")
            }
        } catch (e: Exception) {
            android.util.Log.e("VoskSosService", "JSON parse error: $hypothesisJson", e)
            ""
        }
        if (text.isBlank()) return

        // LOG QUAN TRỌNG ĐỂ DEBUG: xem Vosk đang nhận ra chữ gì trong logcat
        // filter theo tag "VoskSosService" — so sánh với danh sách KEYWORDS xem
        // model có nhận đúng tiếng Việt không, có dấu/không dấu, sai chính tả...
        android.util.Log.d("VoskSosService", "Heard: \"$text\"")

        val normalized = stripDiacritics(text.lowercase())
        val matched = KEYWORDS.firstOrNull { normalized.contains(stripDiacritics(it)) }
        if (matched == null) {
            android.util.Log.d("VoskSosService", "No keyword match in: \"$normalized\"")
            return
        }
        android.util.Log.d("VoskSosService", "MATCHED keyword: \"$matched\"")

        val now = System.currentTimeMillis()
        if (now - lastDetectedAt < COOLDOWN_MS) {
            android.util.Log.d("VoskSosService", "Matched but still in cooldown, skip")
            return
        }
        lastDetectedAt = now

        onKeywordDetected(matched, text)
    }

    private fun stripDiacritics(input: String): String {
        val normalized = Normalizer.normalize(input, Normalizer.Form.NFD)
        return Pattern.compile("\\p{InCombiningDiacriticalMarks}+").matcher(normalized).replaceAll("")
    }

    // ─── SOS trigger — tự gửi HTTP, KHÔNG phụ thuộc Flutter còn sống hay không ──

    private fun onKeywordDetected(keyword: String, fullText: String) {
        updateNotification("Phát hiện từ khoá: \"$keyword\" — đang gửi SOS...")

        // Gate: chỉ gửi nếu đã có recipient — đọc từ cache Flutter đã lưu (SharedKey.cachedRecipientCount)
        val count = prefs.getInt(keyOf("cached_recipient_count"), 0)
        if (count <= 0) {
            updateNotification("Đang lắng nghe từ khoá SOS liên tục")
            return
        }

        Thread {
            try {
                sendSos(keyword, fullText)
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                android.os.Handler(mainLooper).post {
                    updateNotification("Đang lắng nghe từ khoá SOS liên tục")
                }
            }
        }.start()

        // Bắn broadcast để MainActivity forward vào Flutter (nếu đang sống) cập nhật UI
        sendBroadcast(Intent(BROADCAST_KEYWORD_DETECTED).putExtra("keyword", keyword).putExtra("text", fullText))
    }

    private fun sendSos(keyword: String, fullText: String) {
        val token = prefs.getString(keyOf("token"), "") ?: ""
        val baseUrl = readNativeConfig("base_url")
        val apiKey = readNativeConfig("api_key")
        val sosUri = "/api/v1/sos/send"

        val (lat, lng) = getLastKnownLatLng()

        val url = URL("$baseUrl$sosUri")
        val conn = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "POST"
            doOutput = true
            setRequestProperty("Content-Type", "application/json; charset=UTF-8")
            setRequestProperty("Accept", "application/json")
            setRequestProperty("X-TOKEN-ACCESS", apiKey)
            setRequestProperty("Authorization", "Bearer $token")
            connectTimeout = 15000
            readTimeout = 15000
        }

        val body = JSONObject().apply {
            put("latitude", lat.toString())
            put("longitude", lng.toString())
            put("address", "$lat, $lng")
            put("content", "[VOICE-NATIVE] Detected: \"$keyword\" | Nghe được: \"$fullText\"")
        }

        OutputStreamWriter(conn.outputStream).use { it.write(body.toString()) }
        val code = conn.responseCode
        conn.disconnect()
        android.util.Log.d("VoskSosService", "SOS sent, HTTP $code")
    }

    /**
     * flutter_dotenv chỉ load .env vào bộ nhớ Dart lúc runtime — native Kotlin
     * KHÔNG đọc lại được. Cần khai báo song song BASE_URL/API_KEY vào
     * res/values/strings.xml (xem ghi chú cuối file) để service native này
     * tự gửi HTTP được, độc lập với Flutter.
     */
    private fun readNativeConfig(key: String): String {
        val resId = resources.getIdentifier(key, "string", packageName)
        return if (resId != 0) getString(resId) else ""
    }

    private fun getLastKnownLatLng(): Pair<Double, Double> {
        lastLocation?.let { return Pair(it.latitude, it.longitude) }
        return try {
            val lm = getSystemService(LOCATION_SERVICE) as LocationManager
            val providers = lm.getProviders(true)
            for (p in providers) {
                val loc = lm.getLastKnownLocation(p)
                if (loc != null) return Pair(loc.latitude, loc.longitude)
            }
            Pair(0.0, 0.0)
        } catch (e: SecurityException) {
            Pair(0.0, 0.0)
        }
    }

    // ─── Notification ─────────────────────────────────────────────────────────

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID, "SOS Voice Monitoring", NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun updateNotification(text: String) {
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("SOS voice monitoring")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setOngoing(true)
            .build()
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, notification)
    }
}

/*
 * ═══════════════════════════════════════════════════════════════════════
 * VIỆC BẠN CẦN TỰ LÀM TRƯỚC KHI BUILD ĐƯỢC (không tự động hoá được):
 * ═══════════════════════════════════════════════════════════════════════
 *
 * 1. TẢI MODEL VOSK
 *    - Vào https://alphacephei.com/vosk/models , tải model tiếng Việt
 *      (vd "vosk-model-small-vn-0.4", ~30-50MB) — hoặc tiếng Anh nếu chỉ
 *      cần bắt "help/sos".
 *    - Giải nén, đổi tên thư mục con model gốc thành "model", copy vào
 *      android/app/src/main/assets/model-vi/model
 *      (StorageService.unpack cần đúng cấu trúc assets/<MODEL_ASSET_PATH>/...).
 *    - Model KHÔNG bundle sẵn được trong code tôi gửi vì binary quá lớn,
 *      không tải được qua kênh này.
 *
 * 2. ĐỒNG BỘ BASE_URL / API_KEY CHO NATIVE SIDE
 *    Thêm vào android/app/src/main/res/values/strings.xml:
 *        <string name="base_url" translatable="false">https://your-api.com</string>
 *        <string name="api_key" translatable="false">your-api-key</string>
 *
 * 3. KẾT NỐI START/STOP TỪ FLUTTER
 *    Đã wire sẵn qua MethodChannel "com.chaitany.abhay/vosk_sos" trong
 *    MainActivity.kt + native_vosk_sos_service.dart — gọi start()/stop() từ
 *    TrackingService.start()/stop() bên Dart.
 *
 * 4. ĐĂNG KÝ SERVICE TRONG AndroidManifest.xml (đã thêm sẵn ở file manifest kèm theo).
 *
 * 5. TEST TRÊN THIẾT BỊ THẬT — Vosk cần microphone thật + đủ RAM để load
 *    model, không build/chạy thử được trong sandbox không có device.
 * ═══════════════════════════════════════════════════════════════════════
 */
