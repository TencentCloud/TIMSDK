package com.tencent.qcloud.uikit.common;

import android.os.Environment;

import com.tencent.qcloud.uikit.TUIKit;


public class UIKitConstants {

    public static String SD_CARD_PATH = Environment.getExternalStorageDirectory().getAbsolutePath();
    public static String APP_DIR = TUIKit.getBaseConfigs().getAppCacheDir() != null ? TUIKit.getBaseConfigs().getAppCacheDir() : SD_CARD_PATH + "/" + TUIKit.getAppContext().getPackageName();
    public static String RECORD_DIR = APP_DIR + "/record/";
    public static String RECORD_DOWNLOAD_DIR = APP_DIR + "/record/download/";
    public static String VIDEO_DOWNLOAD_DIR = APP_DIR + "/video/download/";
    public static String IMAGE_BASE_DIR = APP_DIR + "/image/";
    public static String IMAGE_DOWNLOAD_DIR = IMAGE_BASE_DIR + "download/";
    public static String MEDIA_DIR = APP_DIR + "/media";
    public static String FILE_DOWNLOAD_DIR = APP_DIR + "/file/download/";
    public static String CRASH_LOG_DIR = APP_DIR + "/crash/";

    public static final String CAMERA_IMAGE_PATH = "camera_image_path";
    public static final String IMAGE_WIDTH = "image_width";
    public static final String IMAGE_HEIGHT = "image_height";
    public static final String VIDEO_TIME = "video_time";
    public static final String CAMERA_VIDEO_PATH = "camera_video_path";
    public static String UI_PARAMS = "ilive_ui_params";
    public static String SOFT_KEY_BOARD_HEIGHT = "soft_key_board_height";
    public static String NAVIGATION_BAR_HEIGHT = "navigation_bar_height";


    public static final String IMAGE_DATA = "image_data";
    public static final String SELF_MESSAGE = "self_message";
    public static final String ITENT_DATA = "intent_data";
    public static final String GROUP_ID = "group_id";
    public static final String CAMERA_TYPE = "camera_type";
}
