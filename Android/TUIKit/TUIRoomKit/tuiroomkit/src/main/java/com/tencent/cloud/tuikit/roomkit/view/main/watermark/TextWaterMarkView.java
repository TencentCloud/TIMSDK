package com.tencent.cloud.tuikit.roomkit.view.main.watermark;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Path;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuicore.util.ScreenUtil;

public class TextWaterMarkView extends View {

    private static final int    MULTI_LINE              = 3;
    private static final int    MULTI_ROW               = 4;
    private static final int    MULTI_TEXT_SIZE         = ScreenUtil.dip2px(14);
    private static final int    SINGLE_TEXT_SIZE        = ScreenUtil.dip2px(36);
    private static final double TEXT_SHADOW_RATIO       = Math.sqrt(2);
    private static final float  FIRST_MARK_SHOW_PERCENT = 0.6f;

    private String             mText      = "null";
    private int                mTextColor = 0x5099A2B2;
    private WaterMarkLineStyle mLineStyle = WaterMarkLineStyle.MULTI_LINE;
    private int                mTextSize;
    private int                mNextLineDistance;
    private int                mMinOffset;

    private int mWidth;
    private int mHeight;

    private Paint mPaint;

    public TextWaterMarkView(Context context) {
        this(context, null);
    }

    public TextWaterMarkView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setColor(mTextColor);
        updateTextParams(mLineStyle);
    }

    public void setText(String text) {
        if (TextUtils.isEmpty(text)) {
            return;
        }
        mText = text;
        invalidate();
    }

    public void setTextColor(int color) {
        mPaint.setColor(color);
        invalidate();
    }

    public void setLineStyle(WaterMarkLineStyle lineStyle) {
        mLineStyle = lineStyle;
        updateTextParams(lineStyle);
        invalidate();
    }

    private void updateTextParams(WaterMarkLineStyle lineStyle) {
        mTextSize = lineStyle == WaterMarkLineStyle.MULTI_LINE ? MULTI_TEXT_SIZE : SINGLE_TEXT_SIZE;
        mPaint.setTextSize(mTextSize);
        mNextLineDistance = (int) (mTextSize * TEXT_SHADOW_RATIO);
        mMinOffset = mTextSize;
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        super.onLayout(changed, left, top, right, bottom);
        mWidth = right - left;
        mHeight = bottom - top;
    }

    @Override
    protected void onDraw(Canvas canvas) {
        canvas.drawColor(Color.TRANSPARENT);
        canvas.save();
        if (mLineStyle == WaterMarkLineStyle.SINGLE_LINE) {
            drawSingleLine(canvas);
        } else {
            drawMultiLine(canvas);
        }
        canvas.restore();
    }

    private void drawMultiLine(Canvas canvas) {
        int widthDivide = mWidth < mHeight ? MULTI_LINE : MULTI_ROW;
        int heightDivide = mHeight > mWidth ? MULTI_ROW : MULTI_LINE;
        int markWidth = (int) (mWidth / (widthDivide - ((1 - FIRST_MARK_SHOW_PERCENT) * 2)));
        int markHeight = (int) (mHeight / (heightDivide - ((1 - FIRST_MARK_SHOW_PERCENT) * 2)));
        String[] names = splitText(markWidth, markHeight);
        int textWidth = getMaxTextWidth(names);
        int xTextOffset = getOffsetForCenter(markWidth, textWidth);
        int yTextOffSet = getOffsetForCenter(markHeight, textWidth);
        int xMarkOffset = (int) (markWidth * (1 - FIRST_MARK_SHOW_PERCENT));
        int yMarkOffset = (int) (markHeight * (1 - FIRST_MARK_SHOW_PERCENT));
        for (int x = 0; x < mWidth; x += markWidth) {
            for (int y = 0; y <= mHeight; y += markHeight) {
                int xStart = x + xTextOffset - xMarkOffset;
                int yStart = y + markHeight - yTextOffSet - yMarkOffset;
                int xEnd = x + markWidth - xTextOffset - xMarkOffset;
                int yEnd = y + yTextOffSet - yMarkOffset;
                for (int i = 0; i < names.length; i++) {
                    Path path = new Path();
                    if (mHeight > mWidth) {
                        path.moveTo(xStart, yStart + i * mNextLineDistance);
                        path.lineTo(xEnd, yEnd + i * mNextLineDistance);
                    } else {
                        path.moveTo(xStart + i * mNextLineDistance, yStart);
                        path.lineTo(xEnd + i * mNextLineDistance, yEnd);
                    }
                    canvas.drawTextOnPath(names[i], path, 0, 0, mPaint);
                }
            }
        }
    }

    private void drawSingleLine(Canvas canvas) {
        int markWidth = mWidth;
        int markHeight = mHeight;
        String[] names = splitText(markWidth, markHeight);
        int textWidth = getMaxTextWidth(names);
        int xOffset = getOffsetForCenter(markWidth, textWidth);
        int yOffSet = getOffsetForCenter(markHeight, textWidth);
        for (int x = 0; x < mWidth; x += markWidth) {
            for (int y = markHeight; y <= mHeight; y += markHeight) {
                int xStart = x + xOffset;
                int yStart = y - yOffSet;
                int xEnd = x + markWidth - xOffset;
                int yEnd = y - markHeight + yOffSet;
                for (int i = 0; i < names.length; i++) {
                    Path path = new Path();
                    if (mHeight > mWidth) {
                        path.moveTo(xStart, yStart + i * mNextLineDistance);
                        path.lineTo(xEnd, yEnd + i * mNextLineDistance);
                    } else {
                        path.moveTo(xStart + i * mNextLineDistance, yStart);
                        path.lineTo(xEnd + i * mNextLineDistance, yEnd);
                    }
                    canvas.drawTextOnPath(names[i], path, 0, 0, mPaint);
                }
            }
        }
    }

    private int getOffsetForCenter(int size, int textSize) {
        int offset = (int) (size - textSize / TEXT_SHADOW_RATIO) >> 1;
        return Math.max(offset, mMinOffset);
    }

    private String[] splitText(int markWidth, int markHeight) {
        if (TextUtils.isEmpty(mText)) {
            return new String[]{""};
        }
        int textWidth = (int) mPaint.measureText(mText);
        int markSize = Math.min(markWidth, markHeight);
        if (textWidth < (markSize - (mMinOffset << 1)) * TEXT_SHADOW_RATIO) {
            return new String[]{mText};
        }
        String[] names = mText.split("\\(");
        if (names.length >= 2) {
            names[1] = "(" + names[1];
        }
        return names;
    }

    private int getMaxTextWidth(String[] names) {
        if (names.length == 0) {
            return 0;
        }
        float maxWidth = mPaint.measureText(names[0]);
        for (int i = 1; i < names.length; i++) {
            float width = mPaint.measureText(names[i]);
            maxWidth = Math.max(maxWidth, width);
        }

        return (int) maxWidth;
    }
}
