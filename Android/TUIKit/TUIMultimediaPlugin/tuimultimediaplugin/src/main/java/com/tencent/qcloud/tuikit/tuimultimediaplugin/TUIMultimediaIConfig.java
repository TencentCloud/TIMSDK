package com.tencent.qcloud.tuikit.tuimultimediaplugin;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.annotations.SerializedName;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants.VideoQuality;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;

public class TUIMultimediaIConfig {

    static final String TAG = TUIMultimediaIConfig.class.getSimpleName();
    static final String DEFAULT_JSON_PATH = "file:///asset/config/default_config.json";
    static final String DEFAULT_BGM_JSON_PATH = "file:///asset/config/bgm_data.json";
    static final String DEFAULT_PASTER_JSON_PATH = "file:///asset/config/picture_paster_data.json";
    static final int DEFAULT_MAX_RECORD_DURATION_MS = 15000;
    static final int DEFAULT_MIN_RECORD_DURATION_MS = 2000;

    @SerializedName("max_record_duration_ms")
    private int mMaxRecordDurationMs = DEFAULT_MAX_RECORD_DURATION_MS;

    @SerializedName("min_record_duration_ms")
    private int mMinRecordDurationMs = DEFAULT_MIN_RECORD_DURATION_MS;

    @SerializedName("video_quality")
    private int mVideoQuality = VideoQuality.MEDIUM.getValue();

    @SerializedName("picture_paster_config_file_path")
    private String mPicturePasterConfigFilePath = DEFAULT_PASTER_JSON_PATH;

    @SerializedName("bgm_config_file_path")
    private String mBGMConfigFilePath = DEFAULT_BGM_JSON_PATH;

    @SerializedName("support_record_torch")
    private boolean mIsSupportRecordTorch = true;

    @SerializedName("support_record_beauty")
    private boolean mIsSupportRecordBeauty = true;

    @SerializedName("support_record_aspect")
    private boolean mIsSupportRecordAspect = true;

    @SerializedName("support_record_scroll_filter")
    private boolean mIsSupportRecordScrollFilter = true;

    @SerializedName("support_video_edit_graffiti")
    private boolean mIsSupportVideoEditGraffiti = true;

    @SerializedName("support_video_edit_paster")
    private boolean mIsSupportVideoEditPaster = true;

    @SerializedName("support_video_edit_subtitle")
    private boolean mIsSupportVideoEditSubtitle = true;

    @SerializedName("support_video_edit_bgm")
    private boolean mIsSupportVideoEditBGM = true;

    @SerializedName("support_picture_edit_graffiti")
    private boolean mIsSupportPictureEditGraffiti = true;

    @SerializedName("support_picture_edit_mosaic")
    private boolean mIsSupportPictureEditMosaic = true;

    @SerializedName("support_picture_edit_paster")
    private boolean mIsSupportPictureEditPaster = true;

    @SerializedName("support_picture_edit_subtitle")
    private boolean mIsSupportPictureEditSubtitle = true;

    @SerializedName("support_picture_edit_crop")
    private boolean mIsSupportPictureEditCrop = true;

    @SerializedName("support_album_picker_edit")
    private boolean mIsSupportAlbumPickerEdit = true;

    @SerializedName("support_album_picker_transcode_select")
    private boolean mIsSupportAlbumPickerTranscodeSelect = true;

    private JsonObject mJsonObject;

    private static TUIMultimediaIConfig sInstance;

    public static TUIMultimediaIConfig getInstance() {
        if (sInstance == null) {
            synchronized (TUIMultimediaIConfig.class) {
                if (sInstance == null) {
                    String json = TUIMultimediaFileUtil.readTextFromFile(DEFAULT_JSON_PATH);
                    Gson gson = new Gson();
                    sInstance = gson.fromJson(json, TUIMultimediaIConfig.class);
                }
            }
        }
        return sInstance;
    }

    public void setConfig(String configJsonString) {
        if (configJsonString == null || configJsonString.isEmpty()) {
            return;
        }

        Gson gson = new Gson();
        mJsonObject = gson.fromJson(configJsonString, JsonObject.class);
    }

    public boolean isSupportRecordBeauty() {
        return getBoolFromJsonObject("support_record_beauty", mIsSupportRecordBeauty);
    }

    public boolean isSupportRecordAspect() {
        return getBoolFromJsonObject("support_record_aspect", mIsSupportRecordAspect);
    }

    public boolean isSupportRecordTorch() {
        return getBoolFromJsonObject("support_record_torch", mIsSupportRecordTorch);
    }

    public boolean isSupportRecordScrollFilter() {
        return getBoolFromJsonObject("support_record_scroll_filter", mIsSupportRecordScrollFilter);

    }

    public boolean isSupportVideoEditGraffiti() {
        return getBoolFromJsonObject("support_video_edit_graffiti", mIsSupportVideoEditGraffiti);
    }

    public boolean isSupportVideoEditPaster() {
        return getBoolFromJsonObject("support_video_edit_paster", mIsSupportVideoEditPaster);
    }

    public boolean isSupportVideoEditSubtitle() {
        return getBoolFromJsonObject("support_video_edit_subtitle", mIsSupportVideoEditSubtitle);

    }

    public boolean isSupportVideoEditBGM() {
        return getBoolFromJsonObject("support_video_edit_bgm", mIsSupportVideoEditBGM);
    }

    public boolean isSupportPictureEditGraffiti() {
        return getBoolFromJsonObject("support_picture_edit_graffiti", mIsSupportPictureEditGraffiti);
    }

    public boolean isSupportPictureEditMosaic() {
        return getBoolFromJsonObject("support_picture_edit_mosaic", mIsSupportPictureEditMosaic);
    }

    public boolean isSupportPictureEditPaster() {
        return getBoolFromJsonObject("support_picture_edit_paster", mIsSupportPictureEditPaster);
    }

    public boolean isSupportPictureEditSubtitle() {
        return getBoolFromJsonObject("support_picture_edit_subtitle", mIsSupportPictureEditSubtitle);
    }

    public boolean isSupportPictureEditCrop() {
        return getBoolFromJsonObject("support_picture_edit_crop", mIsSupportPictureEditCrop);
    }

    public int getThemeColor() {
        return TUIMultimediaResourceUtils.getResources()
                .getColor(TUIThemeManager.getAttrResId(TUIMultimediaPlugin.getAppContext(),
                        com.tencent.qcloud.tuicore.R.attr.core_primary_color));
    }

    public int getMaxRecordDurationMs() {
        return getIntFromJsonObject("max_record_duration_ms", mMaxRecordDurationMs);
    }

    public int getMinRecordDurationMs() {
        return getIntFromJsonObject("min_record_duration_ms", sInstance.mMinRecordDurationMs);
    }

    public VideoQuality getVideoQuality() {
        return VideoQuality.fromInteger(sInstance.getIntFromJsonObject("video_quality", sInstance.mVideoQuality));
    }

    public String getPicturePasterConfigFilePath() {
        return getStringFromJsonObject("picture_paster_config_file_path", mPicturePasterConfigFilePath);
    }

    public String getBGMConfigFilePath() {
        return getStringFromJsonObject("bgm_config_file_path", mBGMConfigFilePath);
    }

    public boolean isSupportAlbumPickerEdit() {
        return getBoolFromJsonObject("support_album_picker_edit", mIsSupportAlbumPickerEdit);
    }

    public boolean isSupportAlbumPickerTranscodeSelect() {
        return getBoolFromJsonObject("support_album_picker_transcode_select", mIsSupportAlbumPickerTranscodeSelect);
    }

    private int getIntFromJsonObject(String key, int defaultValue) {
        if (mJsonObject == null || !mJsonObject.has(key)) {
            return defaultValue;
        }

        return mJsonObject.get(key).getAsInt();
    }

    private boolean getBoolFromJsonObject(String key, boolean defaultValue) {
        if (mJsonObject == null || !mJsonObject.has(key)) {
            return defaultValue;
        }

        return mJsonObject.get(key).getAsBoolean();
    }

    private String getStringFromJsonObject(String key, String defaultValue) {
        if (mJsonObject == null || !mJsonObject.has(key)) {
            return defaultValue;
        }

        return mJsonObject.get(key).getAsString();
    }
}
