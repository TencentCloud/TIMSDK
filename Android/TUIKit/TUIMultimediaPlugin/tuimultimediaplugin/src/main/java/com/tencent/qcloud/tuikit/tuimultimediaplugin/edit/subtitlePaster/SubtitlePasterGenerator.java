package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaPlugin;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import java.util.ArrayList;
import java.util.List;

public class SubtitlePasterGenerator {

    private static final float TEXT_BITMAP_SCALE = 4.0f;
    private static final int LINE_SPACING_DP = 2;
    private final String TAG = SubtitlePasterGenerator.class.getSimpleName() + "_" + hashCode();
    private Bitmap mPasterBitmap;
    private Paint mPaint;
    private SubtitleInfo mParams;

    public void setSubtitleInfo(@NonNull SubtitleInfo params) {
        mParams = params;
        if (mPasterBitmap != null && mPasterBitmap.isRecycled()) {
            return;
        }
        initPaint();

        if (mPasterBitmap == null && !mParams.getText().isEmpty()) {
            int lineTextHeight = (int) (getFontHeight() +
                    TUIMultimediaResourceUtils.dip2px(TUIMultimediaPlugin.getAppContext(), LINE_SPACING_DP));
            int height = lineTextHeight * mParams.textList.size();
            int width = 0;
            for (String text : mParams.textList) {
                int lineWidth = (int) mPaint.measureText(text);
                if (lineWidth > width) {
                    width = lineWidth;
                }
            }
            LiteavLog.i(TAG, "subtitle bitmap width = " + width + " height = " + height);
            mPasterBitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        }
    }

    public float getScale() {
        return TEXT_BITMAP_SCALE;
    }

    @Nullable
    public Bitmap createTextBitmap() {
        if (mPasterBitmap == null || mPasterBitmap.isRecycled()) {
            return null;
        }
        Bitmap bitmap = Bitmap.createBitmap(
                mPasterBitmap.getWidth(), mPasterBitmap.getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(bitmap);
        canvas.drawBitmap(mPasterBitmap, 0, 0, mPaint);
        drawText(canvas);
        if (!mPasterBitmap.isRecycled()) {
            mPasterBitmap.recycle();
            mPasterBitmap = null;
        }
        return bitmap;
    }

    private void drawText(@NonNull Canvas canvas) {
        List<TextParams> list = locateText();
        for (TextParams params : list) {
            canvas.drawText(params.text, params.x, params.y, mPaint);
        }
    }

    @NonNull
    private List<TextParams> locateText() {
        List<TextParams> list = new ArrayList<>();
        List<String> text = mParams.textList;
        float baseX = 0;
        float baseY = getFontBaseHeight()
                - TUIMultimediaResourceUtils.dip2px(TUIMultimediaPlugin.getAppContext(), LINE_SPACING_DP) * 1.0f / 2;
        int lineTextHeight = (int) (getFontHeight() +
                TUIMultimediaResourceUtils.dip2px(TUIMultimediaPlugin.getAppContext(), LINE_SPACING_DP));
        for (int i = 0; i < text.size(); i++) {
            list.add(new TextParams(text.get(i), baseX, baseY + lineTextHeight * i));
        }
        return list;
    }

    private void initPaint() {
        mPaint = new Paint();
        mPaint.setColor(mParams.textColor != 0 ? mParams.textColor : Color.WHITE);
        mPaint.setTextSize(mParams.textSize * TEXT_BITMAP_SCALE);
        mPaint.setAntiAlias(true);
    }

    private float getFontHeight() {
        Paint.FontMetrics metrics = new Paint.FontMetrics();
        mPaint.getFontMetrics(metrics);
        return metrics.bottom - metrics.top;
    }

    private float getFontBaseHeight() {
        Paint.FontMetrics metrics = new Paint.FontMetrics();
        mPaint.getFontMetrics(metrics);
        return metrics.bottom - metrics.top - metrics.descent;
    }

    private static class TextParams {

        public float x, y;
        public String text;

        public TextParams(String text, float x, float y) {
            this.x = x;
            this.y = y;
            this.text = text;
        }
    }
}
