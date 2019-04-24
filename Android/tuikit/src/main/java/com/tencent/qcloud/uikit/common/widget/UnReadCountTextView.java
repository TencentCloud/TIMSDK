package com.tencent.qcloud.uikit.common.widget;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.AttributeSet;
import android.util.TypedValue;

import com.tencent.qcloud.uikit.common.utils.UIUtils;


public class UnReadCountTextView extends android.support.v7.widget.AppCompatTextView {
    int normalSize = UIUtils.getPxByDp(16);
    Paint paint;

    public UnReadCountTextView(Context context) {
        super(context);
        init();
    }

    public UnReadCountTextView(Context context, AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public UnReadCountTextView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        paint = new Paint();
        paint.setColor(Color.RED);
        setTextColor(Color.WHITE);
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 10);
    }


    @Override
    protected void onDraw(Canvas canvas) {
        if (getText().length() == 1) {
            canvas.drawOval(new RectF(0, 0, normalSize, normalSize), paint);
        } else if (getText().length() > 1) {
            canvas.drawRoundRect(new RectF(0, 0, getMeasuredWidth(), getMeasuredHeight()), getMeasuredHeight() / 2, getMeasuredHeight() / 2, paint);
        }
        super.onDraw(canvas);

    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int width = normalSize;
        int height = normalSize;
        if (getText().length() > 1) {
            width = normalSize + UIUtils.getPxByDp((getText().length() - 1) * 10);
        }
        setMeasuredDimension(width, height);
    }
}
