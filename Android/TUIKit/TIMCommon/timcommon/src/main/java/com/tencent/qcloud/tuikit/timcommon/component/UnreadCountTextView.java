package com.tencent.qcloud.tuikit.timcommon.component;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.util.TypedValue;
import android.view.View;

import androidx.appcompat.widget.AppCompatTextView;

import com.tencent.qcloud.tuikit.timcommon.R;

public class UnreadCountTextView extends AppCompatTextView {
    private int mNormalSize;
    private Paint mPaint;

    public UnreadCountTextView(Context context) {
        super(context);
        init(context, null);
    }

    public UnreadCountTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public UnreadCountTextView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        setTextDirection(View.TEXT_DIRECTION_LTR);
        mNormalSize = dp2px(18.4f);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.UnreadCountTextView);
        int paintColor = typedArray.getColor(R.styleable.UnreadCountTextView_paint_color, getResources().getColor(R.color.read_dot_bg));
        typedArray.recycle();

        mPaint = new Paint();
        mPaint.setColor(paintColor);
        mPaint.setAntiAlias(true);
    }

    public void setPaintColor(int color) {
        if (mPaint != null) {
            mPaint.setColor(color);
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        if (getText().length() == 0) {
            int l = (getMeasuredWidth() - dp2px(6)) / 2;
            int t = l;
            int r = getMeasuredWidth() - l;
            int b = r;
            canvas.drawOval(new RectF(l, t, r, b), mPaint);
        } else if (getText().length() == 1) {
            canvas.drawOval(new RectF(0, 0, mNormalSize, mNormalSize), mPaint);
        } else if (getText().length() > 1) {
            canvas.drawRoundRect(new RectF(0, 0, getMeasuredWidth(), getMeasuredHeight()), getMeasuredHeight() / 2, getMeasuredHeight() / 2, mPaint);
        }
        super.onDraw(canvas);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = mNormalSize;
        int height = mNormalSize;
        if (getText().length() > 1) {
            width = mNormalSize + dp2px((getText().length() - 1) * 10);
        }
        setMeasuredDimension(width, height);
    }

    private int dp2px(float dp) {
        DisplayMetrics displayMetrics = getResources().getDisplayMetrics();
        return (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, dp, displayMetrics);
    }
}
