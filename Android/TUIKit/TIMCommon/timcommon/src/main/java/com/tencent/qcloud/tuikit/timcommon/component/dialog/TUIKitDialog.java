package com.tencent.qcloud.tuikit.timcommon.component.dialog;

import static com.tencent.qcloud.tuicore.TUIConfig.TUICORE_SETTINGS_SP_NAME;

import android.app.Dialog;
import android.content.Context;
import android.text.method.MovementMethod;
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

import androidx.annotation.NonNull;

import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.util.SPUtils;
import com.tencent.qcloud.tuikit.timcommon.BuildConfig;
import com.tencent.qcloud.tuikit.timcommon.R;

import java.lang.ref.WeakReference;

public class TUIKitDialog {
    private Context mContext;
    protected Dialog dialog;
    private LinearLayout mBackgroundLayout;
    private LinearLayout mMainLayout;
    protected TextView mTitleTv;
    private Button mCancelButton;
    private Button mSureButton;
    private ImageView mLineImg;
    private Display mDisplay;

    private boolean showTitle = false;
    private boolean showPosBtn = false;
    private boolean showNegBtn = false;

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

        dialog = new Dialog(mContext, R.style.TUIKit_AlertDialogStyle);
        dialog.setContentView(view);

        mBackgroundLayout.setLayoutParams(new FrameLayout.LayoutParams((int) (mDisplay.getWidth() * dialogWidth), LayoutParams.WRAP_CONTENT));
        return this;
    }

    public TUIKitDialog setTitle(@NonNull CharSequence title) {
        showTitle = true;
        mTitleTv.setText(title);
        return this;
    }

    /***
     * Whether to click back to cancel
     * @param cancel
     * @return
     */
    public TUIKitDialog setCancelable(boolean cancel) {
        dialog.setCancelable(cancel);
        return this;
    }

    /**
     * Whether the setting can be canceled
     *
     * @param isCancelOutside
     * @return
     */
    public TUIKitDialog setCancelOutside(boolean isCancelOutside) {
        dialog.setCanceledOnTouchOutside(isCancelOutside);
        return this;
    }

    public TUIKitDialog setPositiveButton(final OnClickListener listener) {
        setPositiveButton(TUIConfig.getAppContext().getString(com.tencent.qcloud.tuicore.R.string.sure), listener);
        return this;
    }

    public TUIKitDialog setPositiveButton(CharSequence text, final OnClickListener listener) {
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

    public void setTitleGravity(int gravity) {
        mTitleTv.setGravity(gravity);
    }

    public TUIKitDialog setNegativeButton(CharSequence text, final OnClickListener listener) {
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

    public TUIKitDialog setNegativeButton(final OnClickListener listener) {
        setNegativeButton(TUIConfig.getAppContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), listener);
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
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }

    public boolean isShowing() {
        return dialog != null && dialog.isShowing();
    }

    /**
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

    public static class TUIIMUpdateDialog {
        private static final class TUIIMUpdateDialogHolder {
            private static final TUIIMUpdateDialog instance = new TUIIMUpdateDialog();
        }

        public static final String KEY_NEVER_SHOW = "neverShow";

        private boolean isNeverShow;
        private boolean isShowOnlyDebug = false;
        private String dialogFeatureName;

        private WeakReference<TUIKitDialog> tuiKitDialog;

        public static TUIIMUpdateDialog getInstance() {
            return TUIIMUpdateDialogHolder.instance;
        }

        private TUIIMUpdateDialog() {
            isNeverShow = SPUtils.getInstance(TUICORE_SETTINGS_SP_NAME).getBoolean(getDialogFeatureName(), false);
        }

        public TUIIMUpdateDialog createDialog(Context context) {
            tuiKitDialog = new WeakReference<>(new TUIKitDialog(context));
            tuiKitDialog.get().builder();
            return this;
        }

        public void setNeverShow(boolean neverShowAlert) {
            this.isNeverShow = neverShowAlert;
            SPUtils.getInstance(TUICORE_SETTINGS_SP_NAME).put(getDialogFeatureName(), neverShowAlert);
        }

        public TUIIMUpdateDialog setShowOnlyDebug(boolean isShowOnlyDebug) {
            this.isShowOnlyDebug = isShowOnlyDebug;
            return this;
        }

        public TUIIMUpdateDialog setMovementMethod(MovementMethod movementMethod) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().mTitleTv.setMovementMethod(movementMethod);
            }
            return this;
        }

        public TUIIMUpdateDialog setHighlightColor(int color) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().mTitleTv.setHighlightColor(color);
            }
            return this;
        }

        public TUIIMUpdateDialog setCancelable(boolean cancelable) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().setCancelable(cancelable);
            }
            return this;
        }

        public TUIIMUpdateDialog setCancelOutside(boolean cancelOutside) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().setCancelOutside(cancelOutside);
            }
            return this;
        }

        public TUIIMUpdateDialog setTitle(CharSequence charSequence) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().setTitle(charSequence);
            }
            return this;
        }

        public TUIIMUpdateDialog setDialogWidth(float dialogWidth) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().setDialogWidth(dialogWidth);
            }
            return this;
        }

        public TUIIMUpdateDialog setPositiveButton(CharSequence text, OnClickListener clickListener) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().setPositiveButton(text, clickListener);
            }
            return this;
        }

        public TUIIMUpdateDialog setNegativeButton(CharSequence text, OnClickListener clickListener) {
            if (tuiKitDialog != null && tuiKitDialog.get() != null) {
                tuiKitDialog.get().setNegativeButton(text, clickListener);
            }
            return this;
        }

        public TUIIMUpdateDialog setDialogFeatureName(String featureName) {
            this.dialogFeatureName = featureName;
            return this;
        }

        private String getDialogFeatureName() {
            return dialogFeatureName;
        }

        public void show() {
            if (tuiKitDialog == null || tuiKitDialog.get() == null) {
                return;
            }
            isNeverShow = SPUtils.getInstance(TUICORE_SETTINGS_SP_NAME).getBoolean(getDialogFeatureName(), false);
            Dialog dialog = tuiKitDialog.get().dialog;
            if (dialog == null || dialog.isShowing()) {
                return;
            }
            if (isNeverShow) {
                return;
            }
            if (isShowOnlyDebug && !BuildConfig.DEBUG) {
                return;
            }
            tuiKitDialog.get().show();
        }

        public void dismiss() {
            if (tuiKitDialog == null || tuiKitDialog.get() == null) {
                return;
            }
            tuiKitDialog.get().dismiss();
        }
    }
}
