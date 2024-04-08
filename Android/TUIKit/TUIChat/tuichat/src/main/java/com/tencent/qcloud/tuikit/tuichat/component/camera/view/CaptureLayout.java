package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.content.res.Configuration;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.LayoutInflater;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.CaptureListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ClickListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ReturnListener;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.TypeListener;

public class CaptureLayout extends FrameLayout {
    private CaptureListener captureListener; 
    private TypeListener typeListener; 
    private ReturnListener returnListener; 
    private ClickListener leftClickListener; 
    private ClickListener rightClickListener; 
    private CaptureButton btnCapture; 
    private View btnConfirm; 
    private View btnCancel; 
    private ReturnButton btnReturn; 
    private ImageView backBtn; 
    private ImageView selectPhotoBtn; 
    private TextView txtTip; 
    private int layoutWidth;
    private int layoutHeight;
    private int buttonSize;
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
        layoutHeight = buttonSize * 2;

        initView();
        initEvent();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
        setMeasuredDimension(layoutWidth, layoutHeight);
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

    public void initEvent() {
        selectPhotoBtn.setVisibility(GONE);
        btnCancel.setVisibility(GONE);
        btnConfirm.setVisibility(GONE);
    }

    public void startTypeBtnAnimator() {
        backBtn.setVisibility(GONE);
        selectPhotoBtn.setVisibility(GONE);
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
        
        LayoutInflater.from(getContext()).inflate(R.layout.chat_camera_capture_layout, this);
        btnCapture = findViewById(R.id.capture_btn);
        btnCancel = findViewById(R.id.cancel_btn);
        btnConfirm = findViewById(R.id.confirm_btn);
        backBtn = findViewById(R.id.back_btn);
        selectPhotoBtn = findViewById(R.id.select_image_btn);
        txtTip = findViewById(R.id.text_tips);

        btnCapture.setView(buttonSize);
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

        btnCancel.getBackground().setAutoMirrored(true);
        btnCancel.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (typeListener != null) {
                    typeListener.cancel();
                }
                startAlphaAnimation();
            }
        });

        btnConfirm.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View view) {
                if (typeListener != null) {
                    typeListener.confirm();
                }
                startAlphaAnimation();
            }
        });

        backBtn.getDrawable().setAutoMirrored(true);
        backBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (leftClickListener != null) {
                    leftClickListener.onClick();
                }
            }
        });

        selectPhotoBtn.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                if (rightClickListener != null) {
                    rightClickListener.onClick();
                }
            }
        });
    }

    /**************************************************
     * Call API                      *
     **************************************************/
    public void resetCaptureLayout() {
        btnCapture.resetState();
        btnCancel.setVisibility(GONE);
        btnConfirm.setVisibility(GONE);
        btnCapture.setVisibility(VISIBLE);
        backBtn.setVisibility(VISIBLE);
        selectPhotoBtn.setVisibility(VISIBLE);
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

    public void setLeftClickListener(ClickListener leftClickListener) {
        this.leftClickListener = leftClickListener;
    }

    public void setRightClickListener(ClickListener rightClickListener) {
        this.rightClickListener = rightClickListener;
    }
}
