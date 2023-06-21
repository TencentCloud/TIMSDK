package com.tencent.qcloud.tuicore;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;

import com.tencent.imsdk.v2.V2TIMUserFullInfo;

import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

/**
 * TUI configuration, such as file path configuration, user information
 */
public class TUIConfig {
    private static Context appContext;

    private static String appDir = "";
    private static String selfFaceUrl = "";
    private static String selfNickName = "";
    private static int selfAllowType = 0;
    private static long selfBirthDay = 0L;
    private static String selfSignature = "";
    private static int gender;

    public static final String TUICORE_SETTINGS_SP_NAME = "TUICoreSettings";

    private static final String RECORD_DIR_SUFFIX = "/record/";
    private static final String RECORD_DOWNLOAD_DIR_SUFFIX = "/record/download/";
    public static final String VIDEO_BASE_DIR_SUFFIX = "/video/";
    private static final String VIDEO_DOWNLOAD_DIR_SUFFIX = "/video/download/";
    public static final String IMAGE_BASE_DIR_SUFFIX = "/image/";
    private static final String IMAGE_DOWNLOAD_DIR_SUFFIX = "/image/download/";
    private static final String MEDIA_DIR_SUFFIX = "/media/";
    private static final String FILE_DOWNLOAD_DIR_SUFFIX = "/file/download/";
    private static final String CRASH_LOG_DIR_SUFFIX = "/crash/";

    private static boolean initialized = false;
    private static boolean enableGroupGridAvatar = true;
    private static int defaultAvatarImage;
    private static int defaultGroupAvatarImage;

    public static final int TUI_HOST_TYPE_IMAPP = 0;
    public static final int TUI_HOST_TYPE_RTCUBE = 1;
    // 0,im app; 1,rtcube app
    private static int tuiHostType = TUI_HOST_TYPE_IMAPP;

    public static void init(Context context) {
        if (initialized) {
            return;
        }
        TUIConfig.appContext = context;
        initPath();
        initialized = true;
    }

    public static String getDefaultAppDir() {
        if (TextUtils.isEmpty(appDir)) {
            Context context = null;
            if (appContext != null) {
                context = appContext;
            } else if (TUIRouter.getContext() != null) {
                context = TUIRouter.getContext();
            } else if (TUILogin.getAppContext() != null) {
                context = TUILogin.getAppContext();
            }
            if (context != null) {
                appDir = context.getFilesDir().getAbsolutePath();
            }
        }
        return appDir;
    }

    public static void setDefaultAppDir(String appDir) {
        TUIConfig.appDir = appDir;
    }

    public static String getRecordDir() {
        return getDefaultAppDir() + RECORD_DIR_SUFFIX;
    }

    public static String getRecordDownloadDir() {
        return getDefaultAppDir() + RECORD_DOWNLOAD_DIR_SUFFIX;
    }

    public static String getVideoBaseDir() {
        return getDefaultAppDir() + VIDEO_BASE_DIR_SUFFIX;
    }

    public static String getVideoDownloadDir() {
        return getDefaultAppDir() + VIDEO_DOWNLOAD_DIR_SUFFIX;
    }

    public static String getImageBaseDir() {
        return getDefaultAppDir() + IMAGE_BASE_DIR_SUFFIX;
    }

    public static String getImageDownloadDir() {
        return getDefaultAppDir() + IMAGE_DOWNLOAD_DIR_SUFFIX;
    }

    public static String getMediaDir() {
        return getDefaultAppDir() + MEDIA_DIR_SUFFIX;
    }

    public static String getFileDownloadDir() {
        return getDefaultAppDir() + FILE_DOWNLOAD_DIR_SUFFIX;
    }

    public static String getCrashLogDir() {
        return getDefaultAppDir() + CRASH_LOG_DIR_SUFFIX;
    }

    public static String getSelfFaceUrl() {
        return selfFaceUrl;
    }

    public static void setSelfFaceUrl(String selfFaceUrl) {
        TUIConfig.selfFaceUrl = selfFaceUrl;
    }

    public static String getSelfNickName() {
        return selfNickName;
    }

    public static void setSelfNickName(String selfNickName) {
        TUIConfig.selfNickName = selfNickName;
    }

    public static int getSelfAllowType() {
        return selfAllowType;
    }

    public static void setSelfAllowType(int selfAllowType) {
        TUIConfig.selfAllowType = selfAllowType;
    }

    public static long getSelfBirthDay() {
        return selfBirthDay;
    }

    public static void setSelfBirthDay(long selfBirthDay) {
        TUIConfig.selfBirthDay = selfBirthDay;
    }

    public static String getSelfSignature() {
        return selfSignature;
    }

    public static void setSelfSignature(String selfSignature) {
        TUIConfig.selfSignature = selfSignature;
    }

    public static void setGender(int gender) {
        TUIConfig.gender = gender;
    }

    public static int getGender() {
        return gender;
    }

    public static void setTUIHostType(int type) {
        TUIConfig.tuiHostType = type;
    }

    public static int getTUIHostType() {
        return tuiHostType;
    }

    /**
     * 获取群组会话否展示九宫格样式的头像，默认为 true
     * Gets whether to display the avatar in the nine-square grid style in the group conversation, the default is true
     */
    public static boolean isEnableGroupGridAvatar() {
        return enableGroupGridAvatar;
    }

    /**
     * 设置群组会话是否展示九宫格样式的头像
     * Set whether to display the avatar in the nine-square grid style in group conversations
     */
    public static void setEnableGroupGridAvatar(boolean enableGroupGridAvatar) {
        TUIConfig.enableGroupGridAvatar = enableGroupGridAvatar;
    }

    /**
     * 获取 c2c 会话的默认头像
     *
     * Get the default avatar for c2c conversation
     *
     * @return
     */
    public static int getDefaultAvatarImage() {
        return defaultAvatarImage;
    }

    /**
     * 设置 c2c 会话的默认头像
     *
     *Set the default avatar for c2c conversation
     *
     * @return
     */
    public static void setDefaultAvatarImage(int defaultAvatarImage) {
        TUIConfig.defaultAvatarImage = defaultAvatarImage;
    }

    /**
     * 获取 group 会话的默认头像
     *
     * Get the default avatar for group conversation
     *
     * @return
     */
    public static int getDefaultGroupAvatarImage() {
        return defaultGroupAvatarImage;
    }

    /**
     * 设置 group 会话的默认头像
     *
     *Set the default avatar for group conversation
     *
     * @return
     */
    public static void setDefaultGroupAvatarImage(int defaultGroupAvatarImage) {
        TUIConfig.defaultGroupAvatarImage = defaultGroupAvatarImage;
    }

    /**
     * Set login user information
     */
    public static void setSelfInfo(V2TIMUserFullInfo userFullInfo) {
        TUIConfig.selfFaceUrl = userFullInfo.getFaceUrl();
        TUIConfig.selfNickName = userFullInfo.getNickName();
        TUIConfig.selfAllowType = userFullInfo.getAllowType();
        TUIConfig.selfBirthDay = userFullInfo.getBirthday();
        TUIConfig.selfSignature = userFullInfo.getSelfSignature();
        TUIConfig.gender = userFullInfo.getGender();
    }

    /**
     * Clear login user information
     */
    public static void clearSelfInfo() {
        TUIConfig.selfFaceUrl = "";
        TUIConfig.selfNickName = "";
        TUIConfig.selfAllowType = 0;
        TUIConfig.selfBirthDay = 0L;
        TUIConfig.selfSignature = "";
    }

    /**
     * init file path
     */
    public static void initPath() {
        File f = new File(getMediaDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getRecordDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getRecordDownloadDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getVideoDownloadDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getImageDownloadDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getImageBaseDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getVideoBaseDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getFileDownloadDir());
        if (!f.exists()) {
            f.mkdirs();
        }

        f = new File(getCrashLogDir());
        if (!f.exists()) {
            f.mkdirs();
        }
    }

    public static Context getAppContext() {
        return appContext;
    }

    public static void setSceneOptimizParams(final String scene) {
        new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    String packageName = "";
                    if (getAppContext() != null) {
                        packageName = getAppContext().getPackageName();
                    }

                    URL url = new URL("https://demos.trtc.tencent-cloud.com/prod/base/v1/events/stat");
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setConnectTimeout(5000);
                    conn.setReadTimeout(5000);
                    conn.setDoOutput(true);
                    conn.setDoInput(true);
                    conn.setUseCaches(false);
                    conn.setRequestMethod("POST");
                    conn.setRequestProperty("Content-Type", "application/json");

                    String sdkAPPId = TUILogin.getSdkAppId() + "";
                    JSONObject msgObject = new JSONObject();
                    msgObject.put("sdkappid", sdkAPPId);
                    msgObject.put("bundleId", "");
                    msgObject.put("component", scene);
                    msgObject.put("package", packageName);

                    String userId = TUILogin.getUserId();
                    JSONObject bodyObject = new JSONObject();
                    bodyObject.put("userId", userId);
                    bodyObject.put("event", "useScenario");
                    bodyObject.put("msg", msgObject);
                    String paramStr = String.valueOf(bodyObject);

                    OutputStream out = conn.getOutputStream();
                    out.write(paramStr.getBytes());
                    out.flush();
                    out.close();
                    if (conn.getResponseCode() == HttpURLConnection.HTTP_OK) {
                        InputStream is = conn.getInputStream();
                        ByteArrayOutputStream message = new ByteArrayOutputStream();
                        int len = 0;
                        byte[] buffer = new byte[1024];
                        while ((len = is.read(buffer)) != -1) {
                            message.write(buffer, 0, len);
                        }
                        String msg = new String(message.toByteArray());
                        Log.d("setSceneOptimizParams", "msg:" + msg);
                        is.close();
                        message.close();
                        conn.disconnect();
                    } else {
                        Log.d("setSceneOptimizParams", "ResponseCode:" + conn.getResponseCode());
                    }
                } catch (Exception e) {
                    Log.d("TUICore", "setSceneOptimizParams exception");
                }
            }
        }).start();
    }
}
