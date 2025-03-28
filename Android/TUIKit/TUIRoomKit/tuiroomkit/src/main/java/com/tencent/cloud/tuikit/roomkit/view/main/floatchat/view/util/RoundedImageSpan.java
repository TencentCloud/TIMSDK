package com.tencent.cloud.tuikit.roomkit.view.main.floatchat.view.util;

import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.RectF;
import android.text.TextUtils;
import android.text.style.ReplacementSpan;

import androidx.annotation.NonNull;

public class RoundedImageSpan extends ReplacementSpan {
    private final int    mBackgroundColor;
    private final int    mCornerRadius;
    private final int    mPadding;
    private final String mText;
    private final int    mTextSize;

    public RoundedImageSpan(String text, int textSize, int backgroundColor, int cornerRadius, int padding) {
        mText = text;
        mTextSize = textSize;
        mBackgroundColor = backgroundColor;
        mCornerRadius = cornerRadius;
        mPadding = padding;
    }

    @Override
    public int getSize(Paint paint, CharSequence text, int start, int end, Paint.FontMetricsInt fm) {
        return (int) (paint.measureText(text, start, end) + mPadding * 2);
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end,
                     float x, int top, int y, int bottom, @NonNull Paint paint) {
        if (TextUtils.isEmpty(mText) || mText.length() <= 3) {
            return;
        }
        String s1 = mText.substring(0, 3);
        String s2 = mText.substring(3);

        int textSize1 = mTextSize * 2 / 3;
        paint.setTextSize(textSize1);
        float textWidth1 = paint.measureText(s1, 0, s1.length());
        paint.setTextSize(mTextSize);
        float textWidth2 = paint.measureText(s2, 0, s2.length());

        float textWidth = textWidth1 + textWidth2;

        RectF rect = new RectF(x, top, x + textWidth + mPadding * 2, bottom);

        paint.setColor(mBackgroundColor);
        canvas.drawRoundRect(rect, mCornerRadius, mCornerRadius, paint);

        paint.setColor(Color.WHITE);
        paint.setTextSize(textSize1);
        canvas.drawText(s1, 0, 3, x + mPadding, y, paint);
        paint.setTextSize(mTextSize);
        canvas.drawText(s2, 0, s2.length(), x + mPadding + textWidth1, y, paint);
    }
}
