package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster;

import static com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils.execute;
import static com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils.postOnUiThread;
import static com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils.postOnUiThreadDelayed;
import static com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils.runOnUiThread;

import android.graphics.Bitmap;
import android.net.Uri;
import com.google.gson.Gson;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaCommonThreadPool;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo.ItemPosition;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterItem;
import java.io.File;
import java.io.IOException;
import java.util.Random;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import java.util.function.Consumer;

public class PicturePasterManager {

    public interface BitmapCallback {
        void onResult(Bitmap bitmap);
    }

    private static final int USER_PASTER_ICON_MAX_SIZE = 360;
    private final String TAG = PicturePasterManager.class + "_" + hashCode();

    private PicturePasterInfo mPicturePasterSet;
    private PicturePasterInfo mUserPicturePasterSet;
    private String mPasterJsonFilePath = "paster_info_data.json";

    private Future<PicturePasterInfo> mCratePicturePasterSetFuture;

    public PicturePasterManager(String pasterJsonFilePath) {
        LiteavLog.i(TAG, "pasterJsonFilePath =" + pasterJsonFilePath);
        if (pasterJsonFilePath == null || pasterJsonFilePath.isEmpty() || !pasterJsonFilePath.endsWith(".json")) {
            LiteavLog.e(TAG, "pasterJsonFilePath =" + pasterJsonFilePath + " is invalid paster json file");
        } else {
            mPasterJsonFilePath = pasterJsonFilePath;
        }
    }

    static public String getUserPasterJsonFilePath() {
        File file = new File(TUIConfig.getDefaultAppDir(), "user_picture_paster.json");
        if (file.exists()) {
            return file.getPath();
        }
        try {
            if (!file.createNewFile()) {
                return null;
            }
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
        return file.getPath();
    }

    public void init() {
        mCratePicturePasterSetFuture = TUIMultimediaCommonThreadPool.getThreadExecutor().submit(this::cratePicturePasterSet);
    }

    public PicturePasterInfo getPicturePasterSetInfo() {
        try {
            return mCratePicturePasterSetFuture.get(500, TimeUnit.MILLISECONDS);
        } catch (Exception e) {
            LiteavLog.e(TAG, "create picture paster set info error " + e);
            return null;
        }
    }

    public PicturePasterItem getPasterItem(ItemPosition itemPosition) {
        return mPicturePasterSet.getPasterItem(itemPosition);
    }

    protected void getPaster(ItemPosition position, BitmapCallback callback) {
        LiteavLog.i(TAG, "select paster position TypeIndex = " +
                position.pasterTypeIndex + " ItemIndex = " + position.pasterItemIndex);
        execute(() -> {
            PicturePasterItem pasterItem = mPicturePasterSet.getPasterItem(position);
            Bitmap bitmap = pasterItem != null ? pasterItem.getPasterImage() : null;
            postOnUiThread(() -> callback.onResult(bitmap));
        });
    }

    public boolean addUserPasterFromUri(Uri uri, ItemPosition itemPosition) {
        Bitmap bitmap = TUIMultimediaFileUtil.readBitmapFromUrl(uri);
        if (bitmap == null || bitmap.getWidth() == 0 || bitmap.getHeight() == 0) {
            LiteavLog.w(TAG, "select image is error");
            return false;
        }

        Bitmap iconBitmap = createIcon(bitmap);
        ItemPosition newPasterPosition = new ItemPosition(itemPosition.pasterTypeIndex,
                itemPosition.pasterItemIndex + 1);
        if (mPicturePasterSet != null) {
            mPicturePasterSet.addPasterItem(newPasterPosition, new PicturePasterItem(bitmap, iconBitmap));
        }
        saveUserPicturePaster(itemPosition.pasterTypeIndex, uri, iconBitmap);
        return true;
    }

    public void uninit() {
        TUIMultimediaCommonThreadPool.getThreadExecutor().execute(() -> {
            if (mUserPicturePasterSet != null) {
                mUserPicturePasterSet.saveToJsonFile(getUserPasterJsonFilePath());
            }
            releaseSource();
        });
    }

    public void releaseSource() {
        if (mPicturePasterSet != null) {
            mPicturePasterSet.release();
            mPicturePasterSet = null;
        }

        if (mUserPicturePasterSet != null) {
            mUserPicturePasterSet.release();
            mUserPicturePasterSet = null;
        }
    }

    private PicturePasterInfo cratePicturePasterSet() {
        LiteavLog.i(TAG, "crate picture paster set");
        mPicturePasterSet = getDefaultPicturePaster();
        mUserPicturePasterSet = getUserPicturePaster();
        if (mPicturePasterSet == null) {
            mPicturePasterSet = new PicturePasterInfo();
        }
        mPicturePasterSet.append(mUserPicturePasterSet);
        return mPicturePasterSet;
    }

    private PicturePasterInfo getDefaultPicturePaster() {
        String json = TUIMultimediaFileUtil.readTextFromFile(mPasterJsonFilePath);
        Gson gson = new Gson();
        return gson.fromJson(json, PicturePasterInfo.class);
    }

    public PicturePasterInfo getUserPicturePaster() {
        String json = TUIMultimediaFileUtil.readTextFromFile(getUserPasterJsonFilePath());
        Gson gson = new Gson();
        return gson.fromJson(json, PicturePasterInfo.class);
    }

    private void saveUserPicturePaster(int pasterTypeIndex, Uri imageUrl, Bitmap iconBitmap) {
        TUIMultimediaCommonThreadPool.getThreadExecutor().execute(() -> {
            String imagePath = savePasterImage(imageUrl);
            String iconPath = savePasterIcon(iconBitmap);
            if (imagePath != null && iconPath != null) {
                addUserPicturePasterInfo(pasterTypeIndex, imagePath, iconPath);
            }
        });
    }

    private void addUserPicturePasterInfo(int pasterTypeIndex, String imageFilePath, String iconFilePath) {
        if (mUserPicturePasterSet == null) {
            mUserPicturePasterSet = getUserPicturePaster();
            if (mUserPicturePasterSet == null) {
                mUserPicturePasterSet = new PicturePasterInfo();
            }
        }
        mUserPicturePasterSet.addPasterItem(new ItemPosition(pasterTypeIndex, 0),
                new PicturePasterItem(imageFilePath, iconFilePath));
    }

    private String savePasterImage(Uri uri) {
        String time = System.nanoTime() + "_" + Math.abs(new Random().nextInt());
        String fileName = "paster_image_" + time;
        File pasterFile = TUIMultimediaFileUtil.generateFileName(fileName, new File(TUIConfig.getImageBaseDir()));
        if (pasterFile == null) {
            return null;
        }
        TUIMultimediaFileUtil.saveFileFromUri(TUIMultimediaPlugin.getAppContext(), uri, pasterFile.getPath());
        return pasterFile.getPath();
    }

    private String savePasterIcon(Bitmap bitmap) {
        String time = System.nanoTime() + "_" + Math.abs(new Random().nextInt());
        String fileName = "paster_icon_" + time;
        File pasterFile = TUIMultimediaFileUtil.generateFileName(fileName, new File(TUIConfig.getImageBaseDir()));
        if (pasterFile == null) {
            return null;
        }
        TUIMultimediaFileUtil.saveBitmap(pasterFile.getPath(), bitmap);
        return pasterFile.getPath();
    }

    private Bitmap createIcon(Bitmap image) {
        int side = Math.max(image.getWidth(), image.getHeight());
        float scale = USER_PASTER_ICON_MAX_SIZE * 1.0f / side;

        if (scale >= 1.0f) {
            return null;
        }

        return Bitmap.createScaledBitmap(image, (int) (image.getWidth() * scale),
                (int) (image.getHeight() * scale), true);
    }
}
