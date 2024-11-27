package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

import com.google.gson.Gson;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaCommonThreadPool;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

public class BGMManager {

    private final String TAG = BGMManager.class.getSimpleName() + "_" + hashCode();
    private final String mBGMJsonFilePath;
    private Future<BGMInfo> mCreateBGMInfoFuture;

    public BGMManager(String bgmJsonFilePath) {
        mBGMJsonFilePath = bgmJsonFilePath;
    }

    public void init() {
        mCreateBGMInfoFuture = TUIMultimediaCommonThreadPool.getThreadExecutor().submit(this::createBGMInfoFromJsonFile);
    }

    protected BGMInfo getBGMInfo() {
        try {
            return mCreateBGMInfoFuture.get(500, TimeUnit.MILLISECONDS);
        } catch (Exception e) {
            LiteavLog.e(TAG, "create picture paster set info error " + e);
            return null;
        }
    }

    private BGMInfo createBGMInfoFromJsonFile() {
        LiteavLog.i(TAG, "bgm json file path =" + mBGMJsonFilePath);
        if (mBGMJsonFilePath == null || mBGMJsonFilePath.isEmpty() || !mBGMJsonFilePath.endsWith(".json")) {
            LiteavLog.e(TAG, "pasterJsonFilePath =" + mBGMJsonFilePath + " is invalid paster json file");
            return null;
        }
        String json = TUIMultimediaFileUtil.readTextFromFile(mBGMJsonFilePath);
        Gson gson = new Gson();
        return gson.fromJson(json, BGMInfo.class);
    }
}
