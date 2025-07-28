package com.tencent.qcloud.tuikit.timcommon.component.dialog;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.GradientDrawable;
import android.os.Handler;
import android.os.Looper;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

public class MinimalistToast {
    
    public static final int TYPE_SUCCESS = 1;
    public static final int TYPE_ERROR = 2;
    public static final int TYPE_WARNING = 3;
    public static final int TYPE_INFO = 4;
    
    private static final int DURATION_SHORT = 2000;
    private static final int DURATION_LONG = 3500;
    
    private Context mContext;
    private Dialog mDialog;
    private Handler mHandler;
    
    private MinimalistToast(Context context) {
        mContext = context;
        mHandler = new Handler(Looper.getMainLooper());
    }
    
    public static void show(Context context, String message) {
        show(context, message, TYPE_INFO, DURATION_SHORT);
    }
    
    public static void show(Context context, String message, int type) {
        show(context, message, type, DURATION_SHORT);
    }
    
    public static void show(Context context, String message, int type, int duration) {
        new MinimalistToast(context).showToast(message, type, duration);
    }
    
    public static void showSuccess(Context context, String message) {
        show(context, message, TYPE_SUCCESS);
    }
    
    public static void showError(Context context, String message) {
        show(context, message, TYPE_ERROR);
    }
    
    public static void showWarning(Context context, String message) {
        show(context, message, TYPE_WARNING);
    }
    
    public static void showInfo(Context context, String message) {
        show(context, message, TYPE_INFO);
    }
    
    private void showToast(String message, int type, int duration) {
        if (mDialog != null && mDialog.isShowing()) {
            mDialog.dismiss();
        }
        
        View toastView = createToastView(message, type);
        
        mDialog = new Dialog(mContext);
        mDialog.requestWindowFeature(Window.FEATURE_NO_TITLE);
        mDialog.setContentView(toastView);
        mDialog.setCancelable(true);
        mDialog.setCanceledOnTouchOutside(true);
        
        Window window = mDialog.getWindow();
        if (window != null) {
            window.setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
            window.setGravity(Gravity.CENTER);
            window.setDimAmount(0f);
            window.setFlags(WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL, 
                           WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL);
            WindowManager.LayoutParams params = window.getAttributes();
            params.width = WindowManager.LayoutParams.WRAP_CONTENT;
            params.height = WindowManager.LayoutParams.WRAP_CONTENT;
            window.setAttributes(params);
        }
        
        mDialog.show();
        
        mHandler.postDelayed(() -> {
            if (mDialog != null && mDialog.isShowing()) {
                mDialog.dismiss();
            }
        }, duration);
    }
    
    private View createToastView(String message, int type) {
        FrameLayout container = new FrameLayout(mContext);
        FrameLayout.LayoutParams containerParams = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        container.setLayoutParams(containerParams);
        
        // Create multiple shadow layers for better effect
        for (int i = 4; i >= 1; i--) {
            FrameLayout shadowLayer = new FrameLayout(mContext);
            FrameLayout.LayoutParams shadowParams = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.WRAP_CONTENT,
                ViewGroup.LayoutParams.WRAP_CONTENT
            );
            shadowParams.setMargins(dp2px(i), dp2px(i), 0, 0);
            shadowLayer.setLayoutParams(shadowParams);
            
            GradientDrawable shadowBg = new GradientDrawable();
            shadowBg.setShape(GradientDrawable.RECTANGLE);
            shadowBg.setCornerRadius(dp2px(6));
            int alpha = (int) (255 * 0.3f / i); // Increased opacity for more visible shadow
            shadowBg.setColor(Color.argb(alpha, 0, 0, 0));
            shadowLayer.setBackground(shadowBg);
            
            container.addView(shadowLayer);
        }
        
        FrameLayout contentLayout = new FrameLayout(mContext);
        FrameLayout.LayoutParams contentParams = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        contentLayout.setLayoutParams(contentParams);
        
        GradientDrawable background = new GradientDrawable();
        background.setShape(GradientDrawable.RECTANGLE);
        background.setCornerRadius(dp2px(6));
        background.setColor(Color.parseColor("#EBF3FF"));
        contentLayout.setBackground(background);
        
        if (hasIcon(type)) {
            ImageView iconView = new ImageView(mContext);
            FrameLayout.LayoutParams iconParams = new FrameLayout.LayoutParams(
                dp2px(16), dp2px(16)
            );
            iconParams.gravity = Gravity.CENTER_VERTICAL | Gravity.START;
            iconParams.setMargins(dp2px(16), 0, 0, 0);
            iconView.setLayoutParams(iconParams);
            iconView.setImageResource(getIconResource(type));
            contentLayout.addView(iconView);
        }
        
        TextView textView = new TextView(mContext);
        FrameLayout.LayoutParams textParams = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT,
            ViewGroup.LayoutParams.WRAP_CONTENT
        );
        textParams.gravity = Gravity.CENTER;
        if (hasIcon(type)) {
            textParams.setMargins(dp2px(48), dp2px(8), dp2px(16), dp2px(8));
        } else {
            textParams.setMargins(dp2px(16), dp2px(8), dp2px(16), dp2px(8));
        }
        textView.setLayoutParams(textParams);
        textView.setText(message);
        textView.setTextColor(Color.BLACK);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, 14);
        textView.setMaxLines(2);
        textView.setGravity(Gravity.CENTER);
        contentLayout.addView(textView);
        
        container.addView(contentLayout);
        return container;
    }
    
    private boolean hasIcon(int type) {
        return type != TYPE_INFO;
    }
    
    private int getIconResource(int type) {
        switch (type) {
            case TYPE_SUCCESS:
                return android.R.drawable.ic_menu_info_details;
            case TYPE_ERROR:
                return android.R.drawable.ic_dialog_alert;
            case TYPE_WARNING:
                return android.R.drawable.ic_dialog_info;
            default:
                return 0;
        }
    }
    
    private int dp2px(float dp) {
        float density = mContext.getResources().getDisplayMetrics().density;
        return (int) (dp * density + 0.5f);
    }
}
