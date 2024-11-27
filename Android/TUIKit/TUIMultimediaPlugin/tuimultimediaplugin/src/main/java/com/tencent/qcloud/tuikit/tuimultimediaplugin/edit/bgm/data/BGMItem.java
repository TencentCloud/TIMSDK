package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data;

import android.media.MediaMetadataRetriever;
import android.os.Looper;
import com.google.gson.annotations.SerializedName;
import com.tencent.liteav.base.util.CustomHandler;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaCommonThreadPool;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import java.io.File;
import java.io.IOException;

public class BGMItem {

    private static final String BGM_CACHE_FILE_DIR = "/multimediaBGM/";

    @SerializedName("item_bgm_path")
    public String bgmFilePath;

    @SerializedName("item_bgm_name")
    public String bgmName;
    @SerializedName("item_start_time")
    public long startTime;
    @SerializedName("item_end_time")
    public long endTime;
    public Long duration;
    @SerializedName("item_bgm_author")
    private String bgmAuthorName;

    public String getBGMAuthorName() {
        return bgmAuthorName;
    }

    public String getBgmName() {
        return bgmName;
    }

    public void getBGMFilePath(TUIMultimediaData<String> tuiDataBGMFilePath) {
        if (bgmFilePath.isEmpty()) {
            tuiDataBGMFilePath.set(null);
            return;
        }

        if (isSupportDirectReadFile(bgmFilePath)) {
            tuiDataBGMFilePath.set(bgmFilePath);
            return;
        }

        String bgmCacheFilePath = getBGMCacheFilePath(bgmFilePath);
        if (TUIMultimediaFileUtil.isFileExists(bgmCacheFilePath)) {
            tuiDataBGMFilePath.set(bgmCacheFilePath);
            return;
        }

        CustomHandler handler = new CustomHandler(Looper.myLooper());
        TUIMultimediaCommonThreadPool.getThreadExecutor().submit(() -> {
            String filePath = copyFileToBGMCache(bgmFilePath);
            handler.post(() -> {
                tuiDataBGMFilePath.set(filePath);
                bgmFilePath = filePath;
            });
        });
    }

    public void getBGMDuration(TUIMultimediaData<Long> tuiDataBGMDuration) {
        if (duration != null) {
            tuiDataBGMDuration.set(duration);
            return;
        }

        CustomHandler handler = new CustomHandler(Looper.myLooper());

        TUIMultimediaData<String> tuiDataBGMFilePath = new TUIMultimediaData<>("");
        tuiDataBGMFilePath.observe(bgmFilePath -> {
            TUIMultimediaCommonThreadPool.getThreadExecutor().submit(() -> {
                duration = getAudioDuration(bgmFilePath);
                handler.post(() -> tuiDataBGMDuration.set(duration));
            });
        });
        getBGMFilePath(tuiDataBGMFilePath);
    }

    public boolean isSameBGM(BGMItem bgmItem) {
        return bgmItem.bgmAuthorName.equals(bgmAuthorName)
                && bgmItem.bgmName.equals(bgmName)
                && bgmItem.bgmFilePath.equals(bgmAuthorName);
    }

    private boolean isSupportDirectReadFile(String path) {
        if (path.startsWith(TUIMultimediaFileUtil.ASSET_FILE_PREFIX)) {
            return false;
        }
        return true;
    }

    private String copyFileToBGMCache(String path) {
        File f = new File(getBGMCacheFileDir());
        boolean isSuccess = true;
        if (!f.exists()) {
            isSuccess = f.mkdirs();
        }
        if (!isSuccess) {
            return path;
        }

        String cacheFilePath = getBGMCacheFilePath(path);
        if (path.startsWith(TUIMultimediaFileUtil.ASSET_FILE_PREFIX)) {
            isSuccess = TUIMultimediaFileUtil
                    .copyAssetsFile(path.substring(TUIMultimediaFileUtil.ASSET_FILE_PREFIX.length()), cacheFilePath);
            return isSuccess ? cacheFilePath : path;
        }

        return path;
    }

    private String getBGMCacheFilePath(String srcBGMFilePath) {
        return getBGMCacheFileDir() + Integer.toHexString(srcBGMFilePath.hashCode());
    }

    private String getBGMCacheFileDir() {
        return TUIConfig.getDefaultAppDir() + BGM_CACHE_FILE_DIR;
    }

    private long getAudioDuration(String audioFilePath) {
        MediaMetadataRetriever metadataRetriever = new MediaMetadataRetriever();
        try {
            metadataRetriever.setDataSource(audioFilePath);
            String durationStr = metadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION);
            return Long.parseLong(durationStr);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                metadataRetriever.release();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return 0;
    }
}