package io.trtc.tuikit.atomicx.common.util

import android.os.Build
import android.text.TextUtils
import android.util.Log

object TUIBuild {
    private const val TAG = "TUIBuild"

    @Volatile
    private var MODEL = "" // Build.MODEL

    @Volatile
    private var BRAND = "" // Build.BRAND

    @Volatile
    private var DEVICE = "" // Build.DEVICE

    @Volatile
    private var MANUFACTURER = "" // Build.MANUFACTURER

    @Volatile
    private var HARDWARE = "" // Build.HARDWARE

    @Volatile
    private var VERSION = "" // Build.VERSION.RELEASE

    @Volatile
    private var BOARD = "" // Build.BOARD

    @Volatile
    private var VERSION_INCREMENTAL = "" // Build.VERSION.INCREMENTAL

    @Volatile
    private var VERSION_INT = 0 // Build.VERSION.SDK_INT

    @JvmStatic
    fun setModel(model: String) {
        synchronized(TUIBuild::class.java) {
            MODEL = model
        }
    }

    @JvmStatic
    fun getModel(): String {
        if (MODEL.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (MODEL.isEmpty()) {
                    MODEL = Build.MODEL
                    Log.i(TAG, "get MODEL by Build.MODEL :$MODEL")
                }
            }
        }
        return MODEL
    }

    @JvmStatic
    fun setBrand(brand: String) {
        synchronized(TUIBuild::class.java) {
            BRAND = brand
        }
    }

    @JvmStatic
    fun getBrand(): String {
        if (BRAND.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (BRAND.isEmpty()) {
                    BRAND = Build.BRAND
                    Log.i(TAG, "get BRAND by Build.BRAND :$BRAND")
                }
            }
        }
        return BRAND
    }

    @JvmStatic
    fun setDevice(device: String) {
        synchronized(TUIBuild::class.java) {
            DEVICE = device
        }
    }

    @JvmStatic
    fun getDevice(): String {
        if (DEVICE.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (DEVICE.isEmpty()) {
                    DEVICE = Build.DEVICE
                    Log.i(TAG, "get DEVICE by Build.DEVICE :$DEVICE")
                }
            }
        }
        return DEVICE
    }

    @JvmStatic
    fun setManufacturer(manufacturer: String) {
        synchronized(TUIBuild::class.java) {
            MANUFACTURER = manufacturer
        }
    }

    @JvmStatic
    fun getManufacturer(): String {
        if (MANUFACTURER.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (MANUFACTURER.isEmpty()) {
                    MANUFACTURER = Build.MANUFACTURER
                    Log.i(TAG, "get MANUFACTURER by Build.MANUFACTURER :$MANUFACTURER")
                }
            }
        }
        return MANUFACTURER
    }

    @JvmStatic
    fun setHardware(hardware: String) {
        synchronized(TUIBuild::class.java) {
            HARDWARE = hardware
        }
    }

    @JvmStatic
    fun getHardware(): String {
        if (HARDWARE.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (HARDWARE.isEmpty()) {
                    HARDWARE = Build.HARDWARE
                    Log.i(TAG, "get HARDWARE by Build.HARDWARE :$HARDWARE")
                }
            }
        }
        return HARDWARE
    }

    @JvmStatic
    fun setVersion(version: String) {
        synchronized(TUIBuild::class.java) {
            VERSION = version
        }
    }

    @JvmStatic
    fun getVersion(): String {
        if (VERSION.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (VERSION.isEmpty()) {
                    VERSION = Build.VERSION.RELEASE
                    Log.i(TAG, "get VERSION by Build.VERSION.RELEASE :$VERSION")
                }
            }
        }
        return VERSION
    }

    @JvmStatic
    fun setVersionInt(versionInt: Int) {
        synchronized(TUIBuild::class.java) {
            VERSION_INT = versionInt
        }
    }

    @JvmStatic
    fun getVersionInt(): Int {
        if (VERSION_INT == 0) {
            synchronized(TUIBuild::class.java) {
                if (VERSION_INT == 0) {
                    VERSION_INT = Build.VERSION.SDK_INT
                    Log.i(TAG, "get VERSION_INT by Build.VERSION.SDK_INT :$VERSION_INT")
                }
            }
        }
        return VERSION_INT
    }

    @JvmStatic
    fun setVersionIncremental(versionIncremental: String) {
        synchronized(TUIBuild::class.java) {
            VERSION_INCREMENTAL = versionIncremental
        }
    }

    @JvmStatic
    fun getVersionIncremental(): String {
        if (VERSION_INCREMENTAL.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (VERSION_INCREMENTAL.isEmpty()) {
                    VERSION_INCREMENTAL = Build.VERSION.INCREMENTAL
                    Log.i(TAG, "get VERSION_INCREMENTAL by Build.VERSION.INCREMENTAL :$VERSION_INCREMENTAL")
                }
            }
        }
        return VERSION_INCREMENTAL
    }

    @JvmStatic
    fun setBoard(board: String) {
        synchronized(TUIBuild::class.java) {
            BOARD = board
        }
    }

    @JvmStatic
    fun getBoard(): String {
        if (BOARD.isEmpty()) {
            synchronized(TUIBuild::class.java) {
                if (BOARD.isEmpty()) {
                    BOARD = Build.BOARD
                    Log.i(TAG, "get BOARD by Build.BOARD :$BOARD")
                }
            }
        }
        return BOARD
    }

    @JvmStatic
    fun isBrandXiaoMi(): Boolean {
        return "xiaomi".equals(getBrand(), ignoreCase = true) ||
                "xiaomi".equals(getManufacturer(), ignoreCase = true)
    }

    @JvmStatic
    fun isBrandHuawei(): Boolean {
        return "huawei".equals(getBrand(), ignoreCase = true) ||
                "huawei".equals(getManufacturer(), ignoreCase = true) ||
                "honor".equals(getBrand(), ignoreCase = true)
    }

    @JvmStatic
    fun isBrandMeizu(): Boolean {
        return "meizu".equals(getBrand(), ignoreCase = true) ||
                "meizu".equals(getManufacturer(), ignoreCase = true) ||
                "22c4185e".equals(getBrand(), ignoreCase = true)
    }

    @JvmStatic
    fun isBrandOppo(): Boolean {
        return "oppo".equals(getBrand(), ignoreCase = true) ||
                "realme".equals(getBrand(), ignoreCase = true) ||
                "oneplus".equals(getBrand(), ignoreCase = true) ||
                "oppo".equals(getManufacturer(), ignoreCase = true) ||
                "realme".equals(getManufacturer(), ignoreCase = true) ||
                "oneplus".equals(getManufacturer(), ignoreCase = true)
    }

    @JvmStatic
    fun isBrandVivo(): Boolean {
        return "vivo".equals(getBrand(), ignoreCase = true) ||
                "vivo".equals(getManufacturer(), ignoreCase = true)
    }

    @JvmStatic
    fun isBrandHonor(): Boolean {
        return "honor".equals(getBrand(), ignoreCase = true) &&
                "honor".equals(getManufacturer(), ignoreCase = true)
    }

    @JvmStatic
    fun isHarmonyOS(): Boolean {
        return try {
            val clz = Class.forName("com.huawei.system.BuildEx")
            val method = clz.getMethod("getOsBrand")
            "harmony" == method.invoke(clz)
        } catch (e: Exception) {
            Log.e(TAG, "the phone not support the harmonyOS")
            false
        }
    }

    @JvmStatic
    fun isMiuiOptimization(): Boolean {
        return try {
            val systemProperties = Class.forName("android.os.systemProperties")
            val get = systemProperties.getDeclaredMethod("get", String::class.java, String::class.java)
            val miuiOptimization = get.invoke(systemProperties, "persist.sys.miuiOptimization", "") as String
            // The user has not adjusted the MIUI-optimization switch (default) | user open MIUI-optimization
            TextUtils.isEmpty(miuiOptimization) || "true" == miuiOptimization
        } catch (e: Exception) {
            Log.e(TAG, "the phone not support the miui optimization")
            false
        }
    }
}
