package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.AttributeSet;
import android.view.View;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.qcloud.tuicore.util.ScreenUtil;

public class CircleIndicator extends View {
    private static final int MIN_THRESHOLD_TO_SHOW = 2;

    private Paint circlePaint;

    private int   mPageNum;
    private float mScrollPercent = 0f;
    private int   mCurrentPosition;
    private int   mGapSize;

    private float mRadius;
    private int   mColorOn;
    private int   mColorOff;

    public CircleIndicator(Context context) {
        super(context);
        init();
    }

    public CircleIndicator(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public CircleIndicator(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        mRadius = getResources()
                .getDimensionPixelSize(R.dimen.tuivideoseat_page_dot_radius);
        circlePaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        mColorOn = Color.WHITE;
        mColorOff = getResources().getColor(R.color.tuivideoseat_color_grey);
        mGapSize = ScreenUtil.dip2px(10);
    }

    public void setSelectDotColor(int colorOn) {
        this.mColorOn = colorOn;
    }

    public void setUnSelectDotColor(int colorOff) {
        this.mColorOff = colorOff;
    }


    public void onPageScrolled(int position, float percent) {
        mScrollPercent = percent;
        mCurrentPosition = position;
        if (mPageNum >= MIN_THRESHOLD_TO_SHOW) {
            invalidate();
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        if (mPageNum < MIN_THRESHOLD_TO_SHOW) {
            return;
        }
        float left = (getWidth() - (mPageNum - 1) * mGapSize) * 0.5f;
        float height = getHeight() * 0.5f;
        circlePaint.setColor(mColorOff);
        for (int i = 0; i < mPageNum; i++) {
            canvas.drawCircle(left + i * mGapSize, height, mRadius, circlePaint);
        }
        circlePaint.setColor(mColorOn);
        canvas.drawCircle(left + mCurrentPosition * mGapSize + mGapSize * mScrollPercent, height, mRadius,
                circlePaint);
    }

    public void setPageNum(int num) {
        mPageNum = num;
        if (num < MIN_THRESHOLD_TO_SHOW) {
            setVisibility(INVISIBLE);
        } else {
            setVisibility(VISIBLE);
        }
    }
}
