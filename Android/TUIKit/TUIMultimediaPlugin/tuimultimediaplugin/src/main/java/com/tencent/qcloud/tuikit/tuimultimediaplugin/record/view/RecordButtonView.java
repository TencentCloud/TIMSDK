package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view;

import android.animation.AnimatorSet;
import android.animation.ObjectAnimator;
import android.content.Context;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.widget.RelativeLayout;
import androidx.annotation.NonNull;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;

public class RecordButtonView extends RelativeLayout implements View.OnTouchListener {

    private final Context mContext;

    private View mButtonInnerView;
    private ProgressRingView mButtonOuterProgressRingView;
    private OnTouchListener mOnTouchListener;
    private boolean mIsOnlySupportTakePhoto = false;

    public RecordButtonView(Context context) {
        super(context);
        mContext = context;
        initViews();
    }

    public RecordButtonView(Context context, AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        initViews();
    }

    public RecordButtonView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        initViews();
    }

    public void setIsOnlySupportTakePhoto(boolean isOnlySupportTakePhoto) {
        mIsOnlySupportTakePhoto = isOnlySupportTakePhoto;
    }

    public void setProcess(float process) {
        mButtonOuterProgressRingView.setProgress(process);
    }

    private void initViews() {
        View rootView = LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_record_start_record_button,
                this, true);
        mButtonOuterProgressRingView = rootView.findViewById(R.id.record_button_ring_progress_bar);
        mButtonOuterProgressRingView.setVisibility(VISIBLE);

        super.setOnTouchListener(this);

        mButtonInnerView = findViewById(R.id.record_button_inner_circle);
    }

    @Override
    public void setOnTouchListener(OnTouchListener listener) {
        mOnTouchListener = listener;
    }

    @Override
    public boolean performClick() {
        return super.performClick();
    }

    @Override
    public boolean onTouch(View view, @NonNull MotionEvent motionEvent) {
        int action = motionEvent.getAction();
        switch (action) {
            case MotionEvent.ACTION_DOWN: {
                startTakePhotoAnim();
                break;
            }
            case MotionEvent.ACTION_UP: {
                endTakePhotoAnim();
                break;
            }
        }
        if (mOnTouchListener != null) {
            return mOnTouchListener.onTouch(view, motionEvent);
        }
        return false;
    }

    private void startTakePhotoAnim() {
        ViewGroup rootLayout = findViewById(R.id.layout_compose_record_btn);

        float scale = 1.0f;
        if (!mIsOnlySupportTakePhoto) {
            scale = (Math.min(rootLayout.getWidth(), rootLayout.getHeight()) - 5) * 1.0f /
                    Math.min(mButtonOuterProgressRingView.getWidth(), mButtonOuterProgressRingView.getHeight());
        }

        ObjectAnimator btnBkgZoomOutXAn = ObjectAnimator.ofFloat(mButtonOuterProgressRingView, "scaleX", scale);
        ObjectAnimator btnBkgZoomOutYAn = ObjectAnimator.ofFloat(mButtonOuterProgressRingView, "scaleY", scale);

        ObjectAnimator btnZoomInXAn = ObjectAnimator.ofFloat(mButtonInnerView, "scaleX", 0.5f);
        ObjectAnimator btnZoomInYAn = ObjectAnimator.ofFloat(mButtonInnerView, "scaleY", 0.5f);

        AnimatorSet animatorSet = new AnimatorSet();
        animatorSet.setDuration(80);
        animatorSet.setInterpolator(new LinearInterpolator());
        animatorSet.play(btnBkgZoomOutXAn)
                .with(btnBkgZoomOutYAn)
                .with(btnZoomInXAn)
                .with(btnZoomInYAn);
        animatorSet.start();
    }

    public void endTakePhotoAnim() {
        ObjectAnimator btnBkgZoomInXAn = ObjectAnimator.ofFloat(mButtonOuterProgressRingView, "scaleX", 1f);
        ObjectAnimator btnBkgZoomIntYAn = ObjectAnimator.ofFloat(mButtonOuterProgressRingView, "scaleY", 1f);

        ObjectAnimator btnZoomInXAn = ObjectAnimator.ofFloat(mButtonInnerView, "scaleX", 1f);
        ObjectAnimator btnZoomInYAn = ObjectAnimator.ofFloat(mButtonInnerView, "scaleY", 1f);

        AnimatorSet animatorSet = new AnimatorSet();
        animatorSet.setDuration(80);
        animatorSet.setInterpolator(new LinearInterpolator());
        animatorSet.play(btnBkgZoomInXAn)
                .with(btnBkgZoomIntYAn)
                .with(btnZoomInXAn)
                .with(btnZoomInYAn);
        animatorSet.start();
    }
}
