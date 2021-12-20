package com.tencent.qcloud.tuicore.util;

import android.os.Build;
import android.util.Log;

public final class TUIBuild {

    private static final String TAG = "TUIBuild";

    private static String MODEL = ""; //Build.MODEL;
    private static String BRAND = ""; //Build.BRAND;
    private static String DEVICE = ""; //Build.DEVICE;
    private static String MANUFACTURER = ""; //Build.MANUFACTURER;
    private static String HARDWARE = ""; //Build.HARDWARE;
    private static String VERSION = ""; //Build.VERSION.RELEASE;
    private static String BOARD  = ""; //Build.BOARD;
    private static String VERSION_INCREMENTAL = ""; //Build.VERSION.INCREMENTAL
    private static int VERSION_INT = 0;  //Build.VERSION.SDK_INT;

    public static void setModel(final String model) {
        synchronized (TUIBuild.class) {
            MODEL = model;
        }
    }

    public static String getModel() {
        if (MODEL == null || MODEL.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (MODEL == null || MODEL.isEmpty()) {
                    MODEL = Build.MODEL;
                    Log.i(TAG, "get MODEL by Build.MODEL :" + MODEL);
                }
            }
        }
        return MODEL;
    }

    public static void setBrand(final String brand) {
        synchronized (TUIBuild.class) {
            BRAND = brand;
        }
    }

    public static String getBrand() {
        if (BRAND == null || BRAND.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (BRAND == null || BRAND.isEmpty()) {
                    BRAND = Build.BRAND;
                    Log.i(TAG, "get BRAND by Build.BRAND :" + BRAND);
                }
            }
        }

        return BRAND;
    }

    public static void setDevice(final String device) {
        synchronized (TUIBuild.class) {
            DEVICE = device;
        }
    }

    public static String getDevice() {
        if (DEVICE == null || DEVICE.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (DEVICE == null || DEVICE.isEmpty()) {
                    DEVICE = Build.DEVICE;
                    Log.i(TAG, "get DEVICE by Build.DEVICE :" + DEVICE);
                }
            }
        }

        return DEVICE;
    }

    public static void setManufacturer(final String manufacturer) {
        synchronized (TUIBuild.class) {
            MANUFACTURER = manufacturer;
        }
    }

    public static String getManufacturer() {
        if (MANUFACTURER == null || MANUFACTURER.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (MANUFACTURER == null || MANUFACTURER.isEmpty()) {
                    MANUFACTURER = Build.MANUFACTURER;
                    Log.i(TAG, "get MANUFACTURER by Build.MANUFACTURER :" + MANUFACTURER);
                }
            }
        }

        return MANUFACTURER;
    }

    public static void setHardware(final String hardware) {
        synchronized (TUIBuild.class) {
            HARDWARE = hardware;
        }
    }

    public static String getHardware() {
        if (HARDWARE == null || HARDWARE.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (HARDWARE == null || HARDWARE.isEmpty()) {
                    HARDWARE = Build.HARDWARE;
                    Log.i(TAG, "get HARDWARE by Build.HARDWARE :" + HARDWARE);
                }
            }
        }

        return HARDWARE;
    }

    public static void setVersion(final String version) {
        synchronized (TUIBuild.class) {
            VERSION = version;
        }
    }

    public static String getVersion() {
        if (VERSION == null || VERSION.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (VERSION == null || VERSION.isEmpty()) {
                    VERSION = Build.VERSION.RELEASE;
                    Log.i(TAG, "get VERSION by Build.VERSION.RELEASE :" + VERSION);
                }
            }
        }

        return VERSION;
    }

    public static void setVersionInt(final int versionInt) {
        synchronized (TUIBuild.class) {
            VERSION_INT = versionInt;
        }
    }

    public static int getVersionInt() {
        if (VERSION_INT == 0) {
            synchronized (TUIBuild.class) {
                if (VERSION_INT == 0) {
                    VERSION_INT = Build.VERSION.SDK_INT;
                    Log.i(TAG, "get VERSION_INT by Build.VERSION.SDK_INT :" + VERSION_INT);
                }
            }
        }

        return VERSION_INT;
    }

    public static void setVersionIncremental(final String version_incremental) {
        synchronized (TUIBuild.class) {
            VERSION_INCREMENTAL = version_incremental;
        }
    }

    public static String getVersionIncremental() {
        if (VERSION_INCREMENTAL == null || VERSION_INCREMENTAL.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (VERSION_INCREMENTAL == null || VERSION_INCREMENTAL.isEmpty()) {
                    VERSION_INCREMENTAL = Build.VERSION.INCREMENTAL;
                    Log.i(TAG, "get VERSION_INCREMENTAL by Build.VERSION.INCREMENTAL :" + VERSION_INCREMENTAL);
                }
            }
        }
        return VERSION_INCREMENTAL;
    }

    public static void setBoard(final String board) {
        synchronized (TUIBuild.class) {
            BOARD = board;
        }
    }

    public static String getBoard() {
        if (BOARD == null || BOARD.isEmpty()) {
            synchronized (TUIBuild.class) {
                if (BOARD == null || BOARD.isEmpty()) {
                    BOARD = Build.BOARD;
                    Log.i(TAG, "get BOARD by Build.BOARD :" + BOARD);
                }
            }
        }

        return BOARD;
    }
}
