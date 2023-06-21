package com.tencent.qcloud.tuikit.timcommon.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.PaintFlagsDrawFilter;
import android.graphics.Path;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.R;

public class RoundFrameLayout extends FrameLayout {
    private final Path path = new Path();
    private final RectF rectF = new RectF();
    private final PaintFlagsDrawFilter aliasFilter = new PaintFlagsDrawFilter(0, Paint.ANTI_ALIAS_FLAG | Paint.FILTER_BITMAP_FLAG);
    private int radius;
    private int leftTopRadius;
    private int rightTopRadius;
    private int rightBottomRadius;
    private int leftBottomRadius;

    public RoundFrameLayout(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public RoundFrameLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public RoundFrameLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    private void init(Context context, AttributeSet attrs) {
        setLayerType(View.LAYER_TYPE_HARDWARE, null);
        int defaultRadius = 0;
        if (attrs != null) {
            TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.RoundFrameLayout);
            radius = array.getDimensionPixelOffset(R.styleable.RoundFrameLayout_corner_radius, defaultRadius);
            leftTopRadius = array.getDimensionPixelOffset(R.styleable.RoundFrameLayout_left_top_corner_radius, defaultRadius);
            rightTopRadius = array.getDimensionPixelOffset(R.styleable.RoundFrameLayout_right_top_corner_radius, defaultRadius);
            rightBottomRadius = array.getDimensionPixelOffset(R.styleable.RoundFrameLayout_right_bottom_corner_radius, defaultRadius);
            leftBottomRadius = array.getDimensionPixelOffset(R.styleable.RoundFrameLayout_left_bottom_corner_radius, defaultRadius);
            array.recycle();
        }

        if (defaultRadius == leftTopRadius) {
            leftTopRadius = radius;
        }
        if (defaultRadius == rightTopRadius) {
            rightTopRadius = radius;
        }
        if (defaultRadius == rightBottomRadius) {
            rightBottomRadius = radius;
        }
        if (defaultRadius == leftBottomRadius) {
            leftBottomRadius = radius;
        }
    }

    @Override
    protected void dispatchDraw(Canvas canvas) {
        path.reset();
        canvas.setDrawFilter(aliasFilter);
        rectF.set(0, 0, getMeasuredWidth(), getMeasuredHeight());
        // left-top -> right-top -> right-bottom -> left-bottom
        float[] radius = {
            leftTopRadius, leftTopRadius, rightTopRadius, rightTopRadius, rightBottomRadius, rightBottomRadius, leftBottomRadius, leftBottomRadius};
        path.addRoundRect(rectF, radius, Path.Direction.CW);
        canvas.clipPath(path);
        super.dispatchDraw(canvas);
    }
}
