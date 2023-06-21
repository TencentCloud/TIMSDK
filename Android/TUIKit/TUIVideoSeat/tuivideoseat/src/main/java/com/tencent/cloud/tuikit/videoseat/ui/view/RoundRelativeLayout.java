package com.tencent.cloud.tuikit.videoseat.ui.view;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Path;
import android.graphics.RectF;
import android.graphics.Region;
import android.util.AttributeSet;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;

public class RoundRelativeLayout extends RelativeLayout {
    private int   mRadius;
    private RectF mRect;
    private Path  mPath;

    public RoundRelativeLayout(Context context) {
        this(context, null);
    }

    public RoundRelativeLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        setWillNotDraw(false);
        mRadius = 0;
        mPath = new Path();
    }

    public void setRadius(int radius) {
        if (radius < 0) {
            return;
        }
        mRadius = radius;
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
        mPath.addRoundRect(mRect, mRadius, mRadius, Path.Direction.CW);
        int saveCount = canvas.save();
        canvas.clipPath(mPath, Region.Op.INTERSECT);
        super.draw(canvas);
        canvas.restoreToCount(saveCount);
    }
}
