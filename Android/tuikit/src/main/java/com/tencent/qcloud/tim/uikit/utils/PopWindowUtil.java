package com.tencent.qcloud.tim.uikit.utils;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Build;
import android.support.v7.view.ContextThemeWrapper;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;


public class PopWindowUtil {

    public static AlertDialog buildCustomDialog(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            if (activity.isDestroyed())
                return null;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(activity, R.style.Theme_Transparent));
        builder.setTitle("");
        builder.setCancelable(true);
        AlertDialog dialog = builder.create();
        //dialog.getWindow().setDimAmount(0);
        dialog.setCanceledOnTouchOutside(true);
        return dialog;
    }


    public static AlertDialog buildFullScreenDialog(Activity activity) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            if (activity.isDestroyed())
                return null;
        }
        AlertDialog.Builder builder = new AlertDialog.Builder(activity);
        builder.setTitle("");
        builder.setCancelable(true);
        AlertDialog dialog = builder.create();
        dialog.getWindow().setDimAmount(0);
        dialog.setCanceledOnTouchOutside(true);
        dialog.show();
        dialog.getWindow().setLayout(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT);
        dialog.getWindow().setBackgroundDrawable(null);
        return dialog;
    }

    public static final AlertDialog buildEditorDialog(Context context, String title, String cancel, String sure, final boolean autoDismiss, final EnsureListener listener) {
        if (context instanceof Activity) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
                if (((Activity) context).isDestroyed())
                    return null;
            }
        }

        final AlertDialog dialog;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(title);
        builder.setCancelable(false);
        dialog = builder.create();

        dialog.show();
        View baseView = LayoutInflater.from(context).inflate(R.layout.layout_dialog, null);
        ((TextView) baseView.findViewById(R.id.dialog_title)).setText(title);
        ((TextView) baseView.findViewById(R.id.dialog_cancel_btn)).setText(cancel);
        ((TextView) baseView.findViewById(R.id.dialog_sure_btn)).setText(sure);
        final EditText editText = baseView.findViewById(R.id.dialog_editor);

        baseView.findViewById(R.id.dialog_sure_btn).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                SoftKeyBoardUtil.hideKeyBoard(editText);
                if (listener != null)
                    listener.sure(editText.getText().toString());
                dialog.dismiss();
                if (autoDismiss)
                    dialog.dismiss();
            }
        });

        baseView.findViewById(R.id.dialog_cancel_btn).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                SoftKeyBoardUtil.hideKeyBoard(editText);
                if (listener != null)
                    listener.cancel();
                dialog.dismiss();
            }
        });
        WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
        lp.width = ScreenUtil.getPxByDp(320);//定义宽度
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;//定义高度
        dialog.getWindow().setAttributes(lp);
        dialog.setContentView(baseView);
        dialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        return dialog;
    }

    public static final AlertDialog buildEnsureDialog(Context context, String title, String content, String cancel, String sure, final EnsureListener listener) {
        if (context instanceof Activity) {
            if (((Activity) context).isDestroyed())
                return null;
        }

        final AlertDialog dialog;
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        builder.setTitle(title);
        builder.setCancelable(false);
        dialog = builder.create();

        dialog.show();
        View baseView = LayoutInflater.from(context).inflate(R.layout.layout_ensure_dialog, null);
        ((TextView) baseView.findViewById(R.id.dialog_title)).setText(title);
        ((TextView) baseView.findViewById(R.id.dialog_cancel_btn)).setText(cancel);
        ((TextView) baseView.findViewById(R.id.dialog_sure_btn)).setText(sure);
        if (!TextUtils.isEmpty(content))
            ((TextView) baseView.findViewById(R.id.dialog_content)).setText(content);
        else
            baseView.findViewById(R.id.dialog_content).setVisibility(View.GONE);
        baseView.findViewById(R.id.dialog_sure_btn).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                if (listener != null)
                    listener.sure(null);
                dialog.dismiss();
            }
        });

        baseView.findViewById(R.id.dialog_cancel_btn).setOnClickListener(new OnClickListener() {

            @Override
            public void onClick(View v) {
                if (listener != null)
                    listener.cancel();
                dialog.dismiss();
            }
        });
        WindowManager.LayoutParams lp = dialog.getWindow().getAttributes();
        lp.width = ScreenUtil.getPxByDp(320);//定义宽度
        lp.height = WindowManager.LayoutParams.WRAP_CONTENT;//定义高度
        dialog.getWindow().setAttributes(lp);
        dialog.setContentView(baseView);
        dialog.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_ALT_FOCUSABLE_IM);
        return dialog;
    }


    public static PopupWindow popupWindow(View windowView, View parent, int x, int y) {
        PopupWindow popup = new PopupWindow(windowView, WindowManager.LayoutParams.WRAP_CONTENT, WindowManager.LayoutParams.WRAP_CONTENT);
//        int[] position = calculatePopWindowPos(windowView, parent, x, y);
        popup.setOutsideTouchable(true);
        popup.setFocusable(true);
        popup.setBackgroundDrawable(new ColorDrawable(0xAEEEEE00));
        popup.showAtLocation(windowView, Gravity.CENTER | Gravity.TOP, x, y);
        return popup;
    }

    private static int[] calculatePopWindowPos(View windowView, View parentView, float x, float y) {
        int windowPos[] = new int[2];
        int anchorLoc[] = new int[2];
        anchorLoc[0] = parentView.getWidth();
        anchorLoc[1] = parentView.getHeight();
        int addHeight = 0; // ScreenUtil.getPxByDp(60) + ScreenUtil.getStatusBarHeight();
        windowView.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
        // 计算contentView的高宽
        int windowHeight = ScreenUtil.getPxByDp(150);
        int windowWidth = windowView.getMeasuredWidth();
        // 判断需要向上弹出还是向下弹出显示
        if (anchorLoc[1] - y < windowHeight) {
            windowPos[1] = (int) y + addHeight - windowHeight;
        } else {
            windowPos[1] = (int) y + addHeight;
        }
        if (anchorLoc[0] - x < windowWidth) {
            windowPos[0] = (int) x - windowWidth;
        } else {
            windowPos[0] = (int) x;

        }
        return windowPos;
    }

    public interface EnsureListener {
        void sure(Object obj);

        void cancel();
    }
}
