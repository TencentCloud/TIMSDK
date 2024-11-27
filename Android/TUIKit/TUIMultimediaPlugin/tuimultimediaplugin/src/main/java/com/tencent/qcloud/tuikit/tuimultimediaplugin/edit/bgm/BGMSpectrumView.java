package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import java.util.Arrays;
import java.util.Random;
import java.util.Timer;
import java.util.TimerTask;


public class BGMSpectrumView extends View {

    private static final int SPECTRUM_POINT_NUM = 20;
    private static final float[] DEFAULT_FREQUENCY_SPECTRUM = new float[SPECTRUM_POINT_NUM];

    static {
        Random random = new Random();
        for (int i = 0; i < DEFAULT_FREQUENCY_SPECTRUM.length; i++) {
            DEFAULT_FREQUENCY_SPECTRUM[i] = random.nextFloat();
        }
    }

    private final float[] mFrequencySpectrumArray = new float[SPECTRUM_POINT_NUM];
    private Paint mPaint;
    private float mStrokePreWidth;
    private float mViewHeight;
    private Timer mUpdateFrequencyTimer;

    public BGMSpectrumView(Context context) {
        this(context, null);
    }

    public BGMSpectrumView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public BGMSpectrumView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        Arrays.fill(mFrequencySpectrumArray, 0);
        initPaint();
    }

    public void start() {
        if (mUpdateFrequencyTimer != null) {
            return;
        }
        mUpdateFrequencyTimer = new Timer();
        mUpdateFrequencyTimer.schedule(new TimerTask() {
            @Override
            public void run() {
                Random random = new Random();
                for (int i = 0; i < mFrequencySpectrumArray.length; i++) {
                    mFrequencySpectrumArray[i] = random.nextFloat();
                }
                postInvalidate();
            }
        }, 0, 100);
    }

    public void stop() {
        if (mUpdateFrequencyTimer != null) {
            mUpdateFrequencyTimer.cancel();
            mUpdateFrequencyTimer = null;
        }
    }

    private void initPaint() {
        mPaint = new Paint();
        mPaint.setColor(TUIMultimediaIConfig.getInstance().getThemeColor());
        mPaint.setAntiAlias(true);
        mPaint.setStyle(Paint.Style.FILL);
    }

    @Override
    public void setEnabled(boolean enabled) {
        if (enabled) {
            start();
            mPaint.setColor(TUIMultimediaIConfig.getInstance().getThemeColor());
        } else {
            stop();
            mPaint.setColor(TUIMultimediaResourceUtils.getColor(R.color.multimedia_plugin_bgm_item_spectrum_color_disable));
            postInvalidate();
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        float[] frequencySpectrumArray =
                mUpdateFrequencyTimer != null ? mFrequencySpectrumArray : DEFAULT_FREQUENCY_SPECTRUM;
        for (int i = 0; i < frequencySpectrumArray.length; i++) {
            canvas.drawLine(mStrokePreWidth * i, mViewHeight, mStrokePreWidth * i,
                    mViewHeight - mViewHeight * frequencySpectrumArray[i], mPaint);
        }
    }

    @Override
    protected void onSizeChanged(int w, int h, int oldW, int oldH) {
        super.onSizeChanged(w, h, oldW, oldH);
        float mViewWidth = getWidth();
        mViewHeight = getHeight();
        mStrokePreWidth = (mViewWidth / SPECTRUM_POINT_NUM);
        mPaint.setStrokeWidth(mStrokePreWidth - 1);
    }
}
