package com.tencent.qcloud.tim.tuikit.live.component.danmaku;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.BitmapShader;
import android.graphics.Canvas;
import android.graphics.ColorFilter;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PixelFormat;
import android.graphics.Rect;
import android.graphics.Shader;
import android.graphics.drawable.Drawable;

import com.tencent.qcloud.tim.tuikit.live.R;

/**
 * Module:   TCCircleDrawable
 *
 * Function: 弹幕所需的圆形 Drawable
 *
 */
public class DanmakuCircleDrawable extends Drawable {

    private Paint   mPaint;
    private Bitmap  mBitmap;
    private Bitmap  mBitmapHeart;
    private boolean mHasHeart;

    private static final int BLACK_COLOR          = 0xb2000000;     //黑色 背景
    private static final int BACKGROUND_ADD_SIZE  = 4;              //背景比图片多出来的部分

    public DanmakuCircleDrawable(Bitmap bitmap) {
        mBitmap = bitmap;
        BitmapShader bitmapShader = new BitmapShader(bitmap,
                Shader.TileMode.CLAMP,
                Shader.TileMode.CLAMP);

        mPaint = new Paint();
        mPaint.setAntiAlias(true);
        mPaint.setShader(bitmapShader);
    }

    /**
     * 右下角包含一个‘心’的圆形drawable
     *
     * @param context context
     * @param bitmap btimap
     * @param hasHeart hasHeart
     */
    public DanmakuCircleDrawable(Context context, Bitmap bitmap, boolean hasHeart) {
        this(bitmap);
        mHasHeart = hasHeart;
        if (hasHeart) {
            setBitmapHeart(context);
        }
    }

    private void setBitmapHeart(Context context) {
        Bitmap bitmap = BitmapFactory.decodeResource(context.getResources(), R.drawable.live_ic_liked);
        if (bitmap != null) {
            Matrix matrix = new Matrix();
            matrix.postScale(0.8f, 0.8f);
            mBitmapHeart = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
        }
    }

    @Override
    public void draw(Canvas canvas) {
        if (mHasHeart && mBitmapHeart != null) {
            //设置背景
            Paint backgroundPaint = new Paint();
            backgroundPaint.setAntiAlias(true);
            backgroundPaint.setColor(BLACK_COLOR);
            canvas.drawCircle(getIntrinsicWidth() / 2 + BACKGROUND_ADD_SIZE, getIntrinsicHeight() / 2
                            + BACKGROUND_ADD_SIZE, getIntrinsicWidth() / 2 + BACKGROUND_ADD_SIZE, backgroundPaint);

            //先将画布平移，防止图片不在正中间，然后绘制图片
            canvas.translate(BACKGROUND_ADD_SIZE, BACKGROUND_ADD_SIZE);
            canvas.drawCircle(getIntrinsicWidth() / 2, getIntrinsicHeight() / 2, getIntrinsicWidth() / 2, mPaint);

            //在右下角绘制‘心’
            Rect srcRect = new Rect(0, 0, mBitmapHeart.getWidth(), mBitmapHeart.getHeight());
            Rect desRect = new Rect(getIntrinsicWidth() - mBitmapHeart.getWidth() + BACKGROUND_ADD_SIZE * 2,
                    getIntrinsicHeight() - mBitmapHeart.getHeight() + BACKGROUND_ADD_SIZE * 2,
                    getIntrinsicWidth() + BACKGROUND_ADD_SIZE * 2, getIntrinsicHeight() + BACKGROUND_ADD_SIZE * 2);
            Paint paint = new Paint(Paint.ANTI_ALIAS_FLAG);
            paint.setFilterBitmap(true);
            paint.setDither(true);
            canvas.drawBitmap(mBitmapHeart, srcRect, desRect, paint);
        } else {
            canvas.drawCircle(getIntrinsicWidth() / 2, getIntrinsicHeight() / 2, getIntrinsicWidth() / 2, mPaint);
        }
    }

    @Override
    public int getIntrinsicWidth() {
        return mBitmap.getWidth();
    }

    @Override
    public int getIntrinsicHeight() {
        return mBitmap.getHeight();
    }

    @Override
    public void setAlpha(int alpha) {
        mPaint.setAlpha(alpha);
    }

    @Override
    public void setColorFilter(ColorFilter cf) {
        mPaint.setColorFilter(cf);
    }

    @Override
    public int getOpacity() {
        return PixelFormat.TRANSLUCENT;
    }
}

