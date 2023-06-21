package com.tencent.qcloud.tuikit.tuicommunity.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
import android.graphics.drawable.shapes.Shape;
import android.util.AttributeSet;
import android.view.Gravity;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.widget.AppCompatTextView;

import com.tencent.qcloud.tuikit.tuicommunity.R;

public class SelectTextButton extends AppCompatTextView {
    private int radius;
    private int borderWidth;
    private int color;

    private int leftTopRadius;
    private int rightTopRadius;
    private int rightBottomRadius;
    private int leftBottomRadius;
    
    public SelectTextButton(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public SelectTextButton(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public SelectTextButton(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        setLayerType(View.LAYER_TYPE_SOFTWARE, null);
        setGravity(Gravity.CENTER);
        if (attrs != null) {
            TypedArray array = context.obtainStyledAttributes(attrs, R.styleable.SelectTextButton);
            radius = array.getDimensionPixelOffset(R.styleable.SelectTextButton_button_radius, 0);
            borderWidth = array.getDimensionPixelOffset(R.styleable.SelectTextButton_border_width, 2);
            color = array.getColor(R.styleable.SelectTextButton_color, 0xFFFFFF);
            leftTopRadius = array.getDimensionPixelOffset(R.styleable.SelectTextButton_button_left_top_radius, 0);
            rightTopRadius = array.getDimensionPixelOffset(R.styleable.SelectTextButton_button_right_top_radius, 0);
            rightBottomRadius = array.getDimensionPixelOffset(R.styleable.SelectTextButton_button_right_bottom_radius, 0);
            leftBottomRadius = array.getDimensionPixelOffset(R.styleable.SelectTextButton_button_left_bottom_radius, 0);
            array.recycle();
        }

        if (leftTopRadius == 0) {
            leftTopRadius = radius;
        }
        if (rightTopRadius == 0) {
            rightTopRadius = radius;
        }
        if (rightBottomRadius == 0) {
            rightBottomRadius = radius;
        }
        if (leftBottomRadius == 0) {
            leftBottomRadius = radius;
        }
        setBackground();
    }

    private void setBackground() {
        float[] radius = {
            leftTopRadius, leftTopRadius, rightTopRadius, rightTopRadius, rightBottomRadius, rightBottomRadius, leftBottomRadius, leftBottomRadius};
        RectF rectF = new RectF(borderWidth, borderWidth, borderWidth, borderWidth);
        RoundRectShape shape = new RoundRectShape(radius, rectF, radius);
        ShapeDrawable shapeDrawable = new ShapeDrawable(shape) {
            @Override
            protected void onDraw(Shape shape, Canvas canvas, Paint paint) {
                paint.setColor(color);
                paint.setStyle(Paint.Style.FILL);
                paint.setAntiAlias(true);
                super.onDraw(shape, canvas, paint);
            }
        };

        setBackground(shapeDrawable);
    }

    public void setColor(int color) {
        this.color = color;
        invalidate();
    }
}
