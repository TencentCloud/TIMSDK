package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.res.Configuration;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.CaptureListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ClickListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ReturnListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.TypeListener;

public class CaptureLayout extends FrameLayout {
    private CaptureListener captureListener; // 拍照按钮监听 Camera button Lisenter
    private TypeListener typeListener; // 拍照或录制后接结果按钮监听 Take a picture or record followed by the result button Lisenter
    private ReturnListener returnListener; // 退出按钮监听 Exit button listener
    private ClickListener leftClickListener; // 左边按钮监听 left button Lisenter
    private ClickListener rightClickListener; // 右边按钮监听 Right button Lisenter
    private CaptureButton btnCapture; // 拍照按钮 photo button
    private TypeButton btnConfirm; // 确认按钮 Confirm button
    private TypeButton btnCancel; // 取消按钮 cancel button
    private ReturnButton btnReturn; // 返回按钮 back button
    private ImageView customLeftIv; // 左边自定义按钮 left custom button
    private ImageView customRightIv; // 右边自定义按钮 right custom button
    private TextView txtTip; // 提示文本 prompt text
    private int layoutWidth;
    private int layoutHeight;
    private int buttonSize;
    private int iconLeft = 0;
    private int iconRight = 0;
    private boolean isFirst = true;

    public CaptureLayout(Context context) {
        this(context, null);
    }

    public CaptureLayout(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public CaptureLayout(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);

        WindowManager manager = (WindowManager) context.getSystemService(Context.WINDOW_SERVICE);
        DisplayMetrics outMetrics = new DisplayMetrics();
        manager.getDefaultDisplay().getMetrics(outMetrics);

        if (this.getResources().getConfiguration().orientation == Configuration.ORIENTATION_PORTRAIT) {
            layoutWidth = outMetrics.widthPixels;
        } else {
            layoutWidth = outMetrics.widthPixels / 2;
        }
        buttonSize = (int) (layoutWidth / 4.5f);
        layoutHeight = buttonSize + (buttonSize / 5) * 2 + 100;

        initView();
        initEvent();
    }

    public void setTypeListener(TypeListener typeListener) {
        this.typeListener = typeListener;
    }

    public void setCaptureListener(CaptureListener captureListener) {
        this.captureListener = captureListener;
    }

    public void setReturnLisenter(ReturnListener returnListener) {
        this.returnListener = returnListener;
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        setMeasuredDimension(layoutWidth, layoutHeight);
    }

    public void initEvent() {
        customRightIv.setVisibility(GONE);
        btnCancel.setVisibility(GONE);
        btnConfirm.setVisibility(GONE);
    }

    public void startTypeBtnAnimator() {
        if (this.iconLeft != 0) {
            customLeftIv.setVisibility(GONE);
        } else {
            btnReturn.setVisibility(GONE);
        }
        if (this.iconRight != 0) {
            customRightIv.setVisibility(GONE);
        }
        btnCapture.setVisibility(GONE);
        btnCancel.setVisibility(VISIBLE);
        btnConfirm.setVisibility(VISIBLE);
        btnCancel.setClickable(false);
        btnConfirm.setClickable(false);
        ObjectAnimator animatorCancel = ObjectAnimator.ofFloat(btnCancel, "translationX", layoutWidth / 4, 0);
        ObjectAnimator animatorConfirm = ObjectAnimator.ofFloat(btnConfirm, "translationX", -layoutWidth / 4, 0);

        AnimatorSet set = new AnimatorSet();
        set.playTogether(animatorCancel, animatorConfirm);
        set.addListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                super.onAnimationEnd(animation);
                btnCancel.setClickable(true);
                btnConfirm.setClickable(true);
            }
        });
        set.setDuration(200);
        set.start();
    }

    private void initView() {
        setWillNotDraw(false);
        // 拍照按钮
        btnCapture = new CaptureButton(getContext(), buttonSize);
        LayoutParams btnCaptureParam = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        btnCaptureParam.gravity = Gravity.CENTER;
        btnCapture.setLayoutParams(btnCaptureParam);
        btnCapture.setCaptureListener(new CaptureListener() {
            @Override
            public void takePictures() {
                if (captureListener != null) {
                    captureListener.takePictures();
                }
            }

            @Override
            public void recordShort(long time) {
                if (captureListener != null) {
                    captureListener.recordShort(time);
                }
                startAlphaAnimation();
            }

            @Override
            public void recordStart() {
                if (captureListener != null) {
                    captureListener.recordStart();
                }
                startAlphaAnimation();
            }

            @Override
            public void recordEnd(long time) {
                if (captureListener != null) {
                    captureListener.recordEnd(time);
                }
                startAlphaAnimation();
                startTypeBtnAnimator();
            }

            @Override
            public void recordZoom(float zoom) {
                if (captureListener != null) {
                    captureListener.recordZoom(zoom);
                }
            }

            @Override
            public void recordError() {
                if (captureListener != null) {
                    captureListener.recordError();
                }
            }
        });

        // 取消按钮
        btnCancel = new TypeButton(getContext(), TypeButton.TYPE_CANCEL, buttonSize);
        final LayoutParams btn_cancel_param = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        btn_cancel_param.gravity = Gravity.CENTER_VERTICAL;
        btn_cancel_param.setMargins((layoutWidth / 4) - buttonSize / 2, 0, 0, 0);
        btnCancel.setLayoutParams(btn_cancel_param);
        btnCancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (typeListener != null) {
                    typeListener.cancel();
                }
                startAlphaAnimation();
                //                resetCaptureLayout();
            }
        });

        btnConfirm = new TypeButton(getContext(), TypeButton.TYPE_CONFIRM, buttonSize);
        LayoutParams btnConfirmParam = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT);
        btnConfirmParam.gravity = Gravity.CENTER_VERTICAL | Gravity.RIGHT;
        btnConfirmParam.setMargins(0, 0, (layoutWidth / 4) - buttonSize / 2, 0);
        btnConfirm.setLayoutParams(btnConfirmParam);
        btnConfirm.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (typeListener != null) {
                    typeListener.confirm();
                }
                startAlphaAnimation();
                //                resetCaptureLayout();
            }
        });

        btnReturn = new ReturnButton(getContext(), (int) (buttonSize / 2.5f));
        LayoutParams btnReturnParam = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        btnReturnParam.gravity = Gravity.CENTER_VERTICAL;
        btnReturnParam.setMargins(layoutWidth / 6, 0, 0, 0);
        btnReturn.setLayoutParams(btnReturnParam);
        btnReturn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (leftClickListener != null) {
                    leftClickListener.onClick();
                }
            }
        });

        customLeftIv = new ImageView(getContext());
        LayoutParams ivCustomParamLeft = new LayoutParams((int) (buttonSize / 2.5f), (int) (buttonSize / 2.5f));
        ivCustomParamLeft.gravity = Gravity.CENTER_VERTICAL;
        ivCustomParamLeft.setMargins(layoutWidth / 6, 0, 0, 0);
        customLeftIv.setLayoutParams(ivCustomParamLeft);
        customLeftIv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (leftClickListener != null) {
                    leftClickListener.onClick();
                }
            }
        });

        customRightIv = new ImageView(getContext());
        LayoutParams ivCustomParamRight = new LayoutParams((int) (buttonSize / 2.5f), (int) (buttonSize / 2.5f));
        ivCustomParamRight.gravity = Gravity.CENTER_VERTICAL | Gravity.RIGHT;
        ivCustomParamRight.setMargins(0, 0, layoutWidth / 6, 0);
        customRightIv.setLayoutParams(ivCustomParamRight);
        customRightIv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (rightClickListener != null) {
                    rightClickListener.onClick();
                }
            }
        });

        txtTip = new TextView(getContext());
        LayoutParams txtParam = new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT);
        txtParam.gravity = Gravity.CENTER_HORIZONTAL;
        txtParam.setMargins(0, 0, 0, 0);
        txtTip.setText(TUIChatService.getAppContext().getString(R.string.tap_tips));
        txtTip.setTextColor(0xFFFFFFFF);
        txtTip.setGravity(Gravity.CENTER);
        txtTip.setLayoutParams(txtParam);

        this.addView(btnCapture);
        this.addView(btnCancel);
        this.addView(btnConfirm);
        this.addView(btnReturn);
        this.addView(customLeftIv);
        this.addView(customRightIv);
        this.addView(txtTip);
    }

    /**************************************************
     * Call API                      *
     **************************************************/
    public void resetCaptureLayout() {
        btnCapture.resetState();
        btnCancel.setVisibility(GONE);
        btnConfirm.setVisibility(GONE);
        btnCapture.setVisibility(VISIBLE);
        if (this.iconLeft != 0) {
            customLeftIv.setVisibility(VISIBLE);
        } else {
            btnReturn.setVisibility(VISIBLE);
        }
        if (this.iconRight != 0) {
            customRightIv.setVisibility(VISIBLE);
        }
    }

    public void startAlphaAnimation() {
        if (isFirst) {
            ObjectAnimator animatorTxtTip = ObjectAnimator.ofFloat(txtTip, "alpha", 1f, 0f);
            animatorTxtTip.setDuration(500);
            animatorTxtTip.start();
            isFirst = false;
        }
    }

    public void setTextWithAnimation(String tip) {
        txtTip.setText(tip);
        ObjectAnimator animatorTxtTip = ObjectAnimator.ofFloat(txtTip, "alpha", 0f, 1f, 1f, 0f);
        animatorTxtTip.setDuration(2500);
        animatorTxtTip.start();
    }

    public void setDuration(int duration) {
        btnCapture.setDuration(duration);
    }

    public void setButtonFeature(int state) {
        btnCapture.setButtonFeature(state);
    }

    public void setTip(String tip) {
        txtTip.setText(tip);
    }

    public void showTip() {
        txtTip.setVisibility(VISIBLE);
    }

    public void setIconSrc(int iconLeft, int iconRight) {
        this.iconLeft = iconLeft;
        this.iconRight = iconRight;
        if (this.iconLeft != 0) {
            customLeftIv.setImageResource(iconLeft);
            customLeftIv.setVisibility(VISIBLE);
            btnReturn.setVisibility(GONE);
        } else {
            customLeftIv.setVisibility(GONE);
            btnReturn.setVisibility(VISIBLE);
        }
        if (this.iconRight != 0) {
            customRightIv.setImageResource(iconRight);
            customRightIv.setVisibility(VISIBLE);
        } else {
            customRightIv.setVisibility(GONE);
        }
    }

    public void setLeftClickListener(ClickListener leftClickListener) {
        this.leftClickListener = leftClickListener;
    }

    public void setRightClickListener(ClickListener rightClickListener) {
        this.rightClickListener = rightClickListener;
    }
}
