package com.tencent.qcloud.tim.demo.helper;

import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.provider.Settings;
import android.view.WindowManager;

import com.tencent.qcloud.tim.uikit.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

public class TRTCDialog extends TUIKitDialog {

    private Context mContext;

    public TRTCDialog(Context context) {
        super(context);
        mContext = context;

        builder();
        WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            lp.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            lp.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT;
        }
        dialog.getWindow().setAttributes(lp);

        setCancelable(false);
        setCancelOutside(false);
        setDialogWidth(0.75f);
    }

    public boolean showSystemDialog() {

        if (Build.VERSION.SDK_INT >= 23) {
            if (!Settings.canDrawOverlays(mContext)) {
                ToastUtil.toastLongMessage("请打开设置“允许显示在其他应用的上层”选项");
                Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION);
                intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                mContext.startActivity(intent);
                return false;
            } else {
                // Android6.0以上
                if (!dialog.isShowing()) {
                    super.show();
                    return true;
                }
            }
        } else {
            // Android6.0以下，不用动态声明权限
            if (!dialog.isShowing()) {
                super.show();
                return true;
            }
        }
        return false;
    }
}
