package com.tencent.liteav.trtccalling.ui.common;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Path;
import android.util.AttributeSet;
import android.view.View;

import androidx.appcompat.widget.AppCompatImageView;

import com.tencent.liteav.trtccalling.R;

public class RoundCornerImageView extends AppCompatImageView {

    private float mWidth, mHeight;
    private int mDefaultRadius = 0;
    private int mRadius;
    private int mLeftTopRadius;
    private int mRightTopRadius;
    private int mRightBottomRadius;
    private int mLeftBottomRadius;

    public RoundCornerImageView(Context context) {
        this(context, null);
    }

    public RoundCornerImageView(Context context, AttributeSet attrs) {
        this(context, attrs, 0);
    }

    public RoundCornerImageView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);

        // 读取配置
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.TRTCCallingRoundCornerImageView);
        mRadius = array.getDimensionPixelOffset(R.styleable.TRTCCallingRoundCornerImageView_radius, mDefaultRadius);
        mLeftTopRadius = array.getDimensionPixelOffset(R.styleable.TRTCCallingRoundCornerImageView_left_top_radius, mDefaultRadius);
        mRightTopRadius = array.getDimensionPixelOffset(R.styleable.TRTCCallingRoundCornerImageView_right_top_radius, mDefaultRadius);
        mRightBottomRadius = array.getDimensionPixelOffset(R.styleable.TRTCCallingRoundCornerImageView_right_bottom_radius, mDefaultRadius);
        mLeftBottomRadius = array.getDimensionPixelOffset(R.styleable.TRTCCallingRoundCornerImageView_left_bottom_radius, mDefaultRadius);

        //如果四个角的值没有设置，那么就使用通用的radius的值。
        if (mDefaultRadius == mLeftTopRadius) {
            mLeftTopRadius = mRadius;
        }
        if (mDefaultRadius == mRightTopRadius) {
            mRightTopRadius = mRadius;
        }
        if (mDefaultRadius == mRightBottomRadius) {
            mRightBottomRadius = mRadius;
        }
        if (mDefaultRadius == mLeftBottomRadius) {
            mLeftBottomRadius = mRadius;
        }
        array.recycle();
    }


    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        mWidth = getWidth();
        mHeight = getHeight();
    }

    @Override
    protected void onDraw(Canvas canvas) {
        // 只有图片的宽高大于设置的圆角距离的时候才进行裁剪
        int maxLeft = Math.max(mLeftTopRadius, mLeftBottomRadius);
        int maxRight = Math.max(mRightTopRadius, mRightBottomRadius);
        int minWidth = maxLeft + maxRight;
        int maxTop = Math.max(mLeftTopRadius, mRightTopRadius);
        int maxBottom = Math.max(mLeftBottomRadius, mRightBottomRadius);
        int minHeight = maxTop + maxBottom;
        if (mWidth >= minWidth && mHeight > minHeight) {
            Path path = new Path();
            //四个角：右上，右下，左下，左上
            path.moveTo(mLeftTopRadius, 0);
            path.lineTo(mWidth - mRightTopRadius, 0);
            path.quadTo(mWidth, 0, mWidth, mRightTopRadius);

            path.lineTo(mWidth, mHeight - mRightBottomRadius);
            path.quadTo(mWidth, mHeight, mWidth - mRightBottomRadius, mHeight);

            path.lineTo(mLeftBottomRadius, mHeight);
            path.quadTo(0, mHeight, 0, mHeight - mLeftBottomRadius);

            path.lineTo(0, mLeftTopRadius);
            path.quadTo(0, 0, mLeftTopRadius, 0);

            canvas.clipPath(path);
        }
        super.onDraw(canvas);
    }
}