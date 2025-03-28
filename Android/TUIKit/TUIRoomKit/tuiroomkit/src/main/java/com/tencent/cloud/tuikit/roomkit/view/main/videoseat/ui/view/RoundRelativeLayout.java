package com.tencent.cloud.tuikit.roomkit.view.main.videoseat.ui.view;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Region;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;

import com.tencent.cloud.tuikit.roomkit.R;

public class RoundRelativeLayout extends RelativeLayout {
    private float[] mRadiusArr = {0, 0, 0, 0, 0, 0, 0, 0};

    private RectF mRect;
    private Path  mPath;

    public RoundRelativeLayout(Context context) {
        this(context, null);
    }

    public RoundRelativeLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setWillNotDraw(false);
        mPath = new Path();
        initAttributes(context, attrs);
    }

    public void setRadius(float radius) {
        setRadius(radius, radius, radius, radius);
    }

    public void setRadius(int radiusD) {
        float radius = radiusD;
        setRadius(radius, radius, radius, radius);
    }

    public void setRadius(float topLeftRadius, float topRightRadius, float bottomRightRadius, float bottomLeftRadius) {
        mRadiusArr[0] = topLeftRadius;
        mRadiusArr[1] = topLeftRadius;
        mRadiusArr[2] = topRightRadius;
        mRadiusArr[3] = topRightRadius;
        mRadiusArr[4] = bottomRightRadius;
        mRadiusArr[5] = bottomRightRadius;
        mRadiusArr[6] = bottomLeftRadius;
        mRadiusArr[7] = bottomLeftRadius;
        invalidate();
    }

    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        super.onLayout(changed, l, t, r, b);
        mRect = new RectF(0, 0, r - l, b - t);
    }

    @Override
    public void draw(Canvas canvas) {
        mPath.reset();
        mPath.addRoundRect(mRect, mRadiusArr, Path.Direction.CW);
        int saveCount = canvas.save();
        canvas.clipPath(mPath, Region.Op.INTERSECT);
        super.draw(canvas);
        canvas.restoreToCount(saveCount);
    }

    private void initAttributes(Context context, @Nullable AttributeSet attrs) {
        if (attrs == null) {
            return;
        }
        TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.RoundRelativeLayout);
        float radius = array.getDimensionPixelOffset(R.styleable.RoundRelativeLayout_radius, 0);
        if (radius > 0) {
            setRadius(radius);
            return;
        }
        float topLeftRadius = array.getDimensionPixelOffset(R.styleable.RoundRelativeLayout_topLeftRadius, 0);
        float topRightRadius = array.getDimensionPixelOffset(R.styleable.RoundRelativeLayout_topRightRadius, 0);
        float bottomRightRadius = array.getDimensionPixelOffset(R.styleable.RoundRelativeLayout_bottomRightRadius, 0);
        float bottomLeftRadius = array.getDimensionPixelOffset(R.styleable.RoundRelativeLayout_bottomLeftRadius, 0);
        setRadius(topLeftRadius, topRightRadius, bottomRightRadius, bottomLeftRadius);
    }
}
