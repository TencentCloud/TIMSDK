package com.tencent.qcloud.tuikit.timcommon.component;

import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.text.style.DynamicDrawableSpan;
import androidx.annotation.NonNull;

public class GifSpan extends DynamicDrawableSpan {
    private static final String TAG = "EmojiGifSpan";
    private Drawable mGifDrawable;

    public GifSpan(Drawable drawable) {
        mGifDrawable = drawable;
        if (mGifDrawable instanceof Animatable) {
            ((Animatable) mGifDrawable).start();
        }
    }

    @Override
    public Drawable getDrawable() {
        return mGifDrawable;
    }

    @Override
    public int getSize(@NonNull Paint paint, CharSequence text, int start, int end, Paint.FontMetricsInt fm) {
        Drawable drawable = getDrawable();
        Rect rect = drawable.getBounds();
        
        if (fm != null) {
            Paint.FontMetricsInt paintFm = paint.getFontMetricsInt();
            int drawableHeight = rect.height();
            
            int center = (paintFm.ascent + paintFm.descent) / 2;
            fm.ascent = center - drawableHeight / 2;
            fm.descent = center + drawableHeight / 2;
            fm.top = fm.ascent;
            fm.bottom = fm.descent;
        }
        
        return rect.right;
    }
}