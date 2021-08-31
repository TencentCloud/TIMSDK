package com.tencent.qcloud.tim.tuikit.live.component.danmaku;

import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.style.ImageSpan;

import java.lang.ref.WeakReference;

/**
 * Module:   TCCenteredImageSpan
 *
 * Function: 弹幕控件
 *
 */
public class DanmakuCenterImageSpan extends ImageSpan {

    private WeakReference<Drawable> mDrawableRef;

    public DanmakuCenterImageSpan(final Drawable drawable) {
        super(drawable);
    }

    @Override
    public int getSize(Paint paint, CharSequence text,
                       int start, int end,
                       Paint.FontMetricsInt fm) {
        Drawable drawable = getCachedDrawable();
        Rect rect = drawable.getBounds();

        if (fm != null) {
            Paint.FontMetricsInt pfm = paint.getFontMetricsInt();
            // keep it the same as paint's fm
            fm.ascent = pfm.ascent;
            fm.descent = pfm.descent;
            fm.top = pfm.top;
            fm.bottom = pfm.bottom;
        }

        return rect.right;
    }

    @Override
    public void draw(Canvas canvas, CharSequence text,
                     int start, int end, float x,
                     int top, int y, int bottom, Paint paint) {
        Drawable b = getCachedDrawable();
        canvas.save();

        int drawableHeight = b.getIntrinsicHeight();
        int fontAscent = paint.getFontMetricsInt().ascent;
        int fontDescent = paint.getFontMetricsInt().descent;
        int transY = bottom - b.getBounds().bottom +  // align bottom to bottom
                (drawableHeight - fontDescent + fontAscent) / 2;  // align center to center

        canvas.translate(x, transY);
        b.draw(canvas);
        canvas.restore();
    }

    // Redefined locally because it is a private member from DynamicDrawableSpan
    private Drawable getCachedDrawable() {
        WeakReference<Drawable> wr = mDrawableRef;
        Drawable drawable = null;

        if (wr != null)
            drawable = wr.get();

        if (drawable == null) {
            drawable = getDrawable();
            mDrawableRef = new WeakReference<>(drawable);
        }

        return drawable;
    }
}

