package com.tencent.qcloud.tim.uikit.component.dialog;

import android.app.Dialog;
import android.content.Context;
import android.support.annotation.NonNull;
import android.view.Display;
import android.view.LayoutInflater;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;

public class TUIKitDialog {

    private Context mContext;
    private Dialog dialog;
    private LinearLayout mBackgroundLayout;
    private LinearLayout mMainLayout;
    private TextView mTitleTv;
    private Button mCancelButton;
    private Button mSureButton;
    private ImageView mLineImg;
    private Display mDisplay;

    /**
     * 是否显示title
     */
    private boolean showTitle = false;
    /***
     * 是否显示确定按钮
     */
    private boolean showPosBtn = false;

    /**
     * 是否显示取消按钮
     */
    private boolean showNegBtn = false;

    /**
     * dialog  宽度
     */
    private float dialogWidth = 0.7f;


    public TUIKitDialog(Context context) {
        this.mContext = context;
        WindowManager windowManager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        mDisplay = windowManager.getDefaultDisplay();
    }

    public TUIKitDialog builder() {
        View view = LayoutInflater.from(mContext).inflate(R.layout.view_dialog, null);
        mBackgroundLayout = (LinearLayout) view.findViewById(R.id.ll_background);
        mMainLayout = (LinearLayout) view.findViewById(R.id.ll_alert);
        mMainLayout.setVerticalGravity(View.GONE);
        mTitleTv = (TextView) view.findViewById(R.id.tv_title);
        mTitleTv.setVisibility(View.GONE);
        mCancelButton = (Button) view.findViewById(R.id.btn_neg);
        mCancelButton.setVisibility(View.GONE);
        mSureButton = (Button) view.findViewById(R.id.btn_pos);
        mSureButton.setVisibility(View.GONE);
        mLineImg = (ImageView) view.findViewById(R.id.img_line);
        mLineImg.setVisibility(View.GONE);

        dialog = new Dialog(mContext, R.style.AlertDialogStyle);
        dialog.setContentView(view);

        mBackgroundLayout.setLayoutParams(new FrameLayout.LayoutParams((int) (mDisplay.getWidth() * dialogWidth), LayoutParams.WRAP_CONTENT));
        return this;
    }


    public TUIKitDialog setTitle(@NonNull String title) {
        showTitle = true;
        mTitleTv.setText(title);
        return this;
    }

    /***
     * 是否点击返回能够取消
     * @param cancel
     * @return
     */
    public TUIKitDialog setCancelable(boolean cancel) {
        dialog.setCancelable(cancel);
        return this;
    }

    /**
     * 设置是否可以取消
     *
     * @param isCancelOutside
     * @return
     */
    public TUIKitDialog setCancelOutside(boolean isCancelOutside) {
        dialog.setCanceledOnTouchOutside(isCancelOutside);
        return this;
    }

    /**
     * 设置确定
     *
     * @param text
     * @param listener
     * @return
     */
    public TUIKitDialog setPositiveButton(String text,
                                          final OnClickListener listener) {
        showPosBtn = true;
        mSureButton.setText(text);
        mSureButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.onClick(v);
                dialog.dismiss();
            }
        });
        return this;
    }

    public TUIKitDialog setPositiveButton(final View.OnClickListener listener) {
        setPositiveButton("确定", listener);
        return this;
    }

    /***
     * 设置取消
     * @param text
     * @param listener
     * @return
     */
    public TUIKitDialog setNegativeButton(String text,
                                          final OnClickListener listener) {
        showNegBtn = true;
        mCancelButton.setText(text);
        mCancelButton.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                listener.onClick(v);
                dialog.dismiss();
            }
        });
        return this;
    }

    public TUIKitDialog setNegativeButton(
            final OnClickListener listener) {
        setNegativeButton("取消", listener);
        return this;
    }


    private void setLayout() {
        if (!showTitle) {
            mTitleTv.setVisibility(View.GONE);
        }

        if (showTitle) {
            mTitleTv.setVisibility(View.VISIBLE);
        }

        if (!showPosBtn && !showNegBtn) {
            mSureButton.setVisibility(View.GONE);
            mSureButton.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    dialog.dismiss();
                }
            });
        }

        if (showPosBtn && showNegBtn) {
            mSureButton.setVisibility(View.VISIBLE);
            mCancelButton.setVisibility(View.VISIBLE);
            mLineImg.setVisibility(View.VISIBLE);
        }

        if (showPosBtn && !showNegBtn) {
            mSureButton.setVisibility(View.VISIBLE);
        }

        if (!showPosBtn && showNegBtn) {
            mCancelButton.setVisibility(View.VISIBLE);
        }
    }

    public void show() {
        setLayout();
        dialog.show();
    }

    public void dismiss() {
        dialog.dismiss();
    }


    /**
     * 设置dialog  宽度
     *
     * @param dialogWidth
     * @return
     */
    public TUIKitDialog setDialogWidth(float dialogWidth) {
        if (mBackgroundLayout != null) {
            mBackgroundLayout.setLayoutParams(new FrameLayout.LayoutParams((int) (mDisplay.getWidth() * dialogWidth), LayoutParams.WRAP_CONTENT));
        }
        this.dialogWidth = dialogWidth;
        return this;
    }


    /***
     * 获取title
     * @return
     */
    public TextView getTxt_title() {
        return mTitleTv;
    }

    /**
     * 获取确定按钮
     *
     * @return
     */
    public Button getBtn_neg() {
        return mCancelButton;
    }

    /***
     * 获取用于添加自定义控件的ll
     * @return
     */
    public LinearLayout getlLayout_alert_ll() {
        return mMainLayout;
    }


    /***
     * 根据手机的分辨率从 dip 的单位 转成为 px(像素)
     * @param dpValue
     * @return
     */
    public int dp2px(float dpValue) {
        final float scale = mContext.getResources().getDisplayMetrics().density;
        return (int) (dpValue * scale + 0.5f);
    }

    /**
     * 根据手机的分辨率从 px(像素) 的单位 转成为 dp
     */
    public int px2dip(float pxValue) {
        final float scale = mContext.getResources().getDisplayMetrics().density;
        return (int) (pxValue / scale + 0.5f);
    }

    /**
     * 将px值转换为sp值，保证文字大小不变
     */
    public int px2sp(float pxValue) {
        final float fontScale = mContext.getResources().getDisplayMetrics().scaledDensity;
        return (int) (pxValue / fontScale + 0.5f);
    }

    /**
     * 将sp值转换为px值，保证文字大小不变
     */
    public int sp2px(float spValue) {
        final float fontScale = mContext.getResources().getDisplayMetrics().scaledDensity;
        return (int) (spValue * fontScale + 0.5f);
    }

    /**
     * 获取取消按钮
     *
     * @return
     */
    public Button getBtn_pos() {
        return mSureButton;
    }

}
