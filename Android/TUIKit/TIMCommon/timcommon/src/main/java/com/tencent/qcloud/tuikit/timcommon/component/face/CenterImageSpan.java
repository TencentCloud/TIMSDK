package com.tencent.qcloud.tuikit.timcommon.component.face;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.style.ImageSpan;

import androidx.annotation.NonNull;

public class CenterImageSpan extends ImageSpan {

    private int bgColor = -1;

    public CenterImageSpan(@NonNull Drawable drawable) {
        super(drawable);
    }

    public void setBgColor(int bgColor) {
        this.bgColor = bgColor;
    }

    @Override
    public int getSize(Paint paint, CharSequence text, int start, int end, Paint.FontMetricsInt fm) {
        Drawable drawable = getDrawable();
        Rect rect = drawable.getBounds();
        Paint.FontMetricsInt paintFm = paint.getFontMetricsInt();
        int center = (paintFm.top + paintFm.bottom) / 2;
        if (fm != null) {
            fm.ascent = center - (rect.height() / 2);
            fm.descent = center + (rect.height() / 2);
            fm.top = fm.ascent;
            fm.bottom = fm.descent;
        }

        return rect.right;
    }

    @Override
    public void draw(@NonNull Canvas canvas, CharSequence text, int start, int end, float x, int top, int y, int bottom, @NonNull Paint paint) {
        if (bgColor == -1) {
            super.draw(canvas, text, start, end, x, top, y, bottom, paint);
        } else {
            canvas.save();
            paint.setColor(bgColor);
            canvas.drawRect(x, top, getDrawable().getBounds().right + x, bottom, paint);
            canvas.restore();
            super.draw(canvas, text, start, end, x, top, y, bottom, paint);
        }
    }
}
