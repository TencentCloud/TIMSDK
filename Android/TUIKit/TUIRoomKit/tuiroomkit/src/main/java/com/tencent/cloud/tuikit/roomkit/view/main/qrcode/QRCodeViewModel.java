package com.tencent.cloud.tuikit.roomkit.view.main.qrcode;

import android.Manifest;
import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.graphics.Bitmap;
import android.os.Build;
import android.widget.Toast;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.common.utils.CommonUtils;
import com.tencent.cloud.tuikit.roomkit.common.utils.SaveBitMap;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuicore.permission.PermissionRequester;
import com.tencent.qcloud.tuicore.util.TUIBuild;

public class QRCodeViewModel {
    private Context    mContext;
    private SaveBitMap mSaveBitMap;

    public QRCodeViewModel(Context context) {
        mContext = context;
    }

    public void saveQRCodeToAlbum(final Bitmap bitmap) {
        if (TUIBuild.getVersionInt() >= Build.VERSION_CODES.Q) {
            saveBitmapToAlbum(bitmap);
            return;
        }
        PermissionCallback callback = new PermissionCallback() {
            @Override
            public void onGranted() {
                saveBitmapToAlbum(bitmap);
            }
        };

        PermissionRequester.newInstance(Manifest.permission.WRITE_EXTERNAL_STORAGE)
                .title(mContext.getString(R.string.tuiroomkit_permission_storage_reason_title,
                        CommonUtils.getAppName(mContext)))
                .description(mContext.getString(R.string.tuiroomkit_permission_storage_reason))
                .settingsTip(mContext.getString(R.string.tuiroomkit_tips_start_storage))
                .callback(callback)
                .request();
    }

    private void saveBitmapToAlbum(final Bitmap bitmap) {
        if (mSaveBitMap == null) {
            mSaveBitMap = new SaveBitMap();
        }
        mSaveBitMap.saveToAlbum(mContext, bitmap);
    }

    public void copyContentToClipboard(String content, String toast) {
        ClipboardManager cm = (ClipboardManager) mContext.getSystemService(Context.CLIPBOARD_SERVICE);
        ClipData mClipData = ClipData.newPlainText("Label", content);
        cm.setPrimaryClip(mClipData);
        Toast.makeText(mContext, toast, Toast.LENGTH_SHORT).show();
    }
}
