package com.tencent.qcloud.uikit.common.widget;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.util.SparseArray;
import android.widget.ImageView;

import com.tencent.qcloud.uikit.common.utils.UIUtils;

import java.util.HashMap;

/**
 * Created by valxehuang on 2018/8/19.
 */

@SuppressLint("AppCompatCustomView")
public class ShadeImageView extends ImageView {
    private Paint shadePaint = new Paint();
    private Bitmap roundBitMap;
    private static SparseArray<Bitmap> roundBitMaps = new SparseArray();


    private int radius = UIUtils.getPxByDp(5);

    public ShadeImageView(Context context) {
        super(context);
    }

    public ShadeImageView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(attrs);
    }

    public ShadeImageView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(attrs);
    }

    private void init(AttributeSet attrs) {
        setLayerType(LAYER_TYPE_HARDWARE, null);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        shadePaint.setColor(Color.RED);
        shadePaint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.DST_IN));
        roundBitMap = roundBitMaps.get(getMeasuredWidth() + radius);
        if (roundBitMap == null) {
            roundBitMap = getRoundBitmap();
            roundBitMaps.put(getMeasuredWidth() + radius, roundBitMap);
        }
        canvas.drawBitmap(roundBitMap, 0, 0, shadePaint);
    }


    /**
     * 获取圆角矩形图片方法
     *
     * @return Bitmap
     */
    private Bitmap getRoundBitmap() {
        Bitmap output = Bitmap.createBitmap(getWidth(),
                getHeight(), Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);
        final int color = Color.parseColor("#cfd3d8");
        final Rect rect = new Rect(0, 0, getMeasuredWidth(), getMeasuredHeight());
        final RectF rectF = new RectF(rect);
        Paint paint = new Paint();
        paint.setAntiAlias(true);
        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);
        canvas.drawRoundRect(rectF, radius, radius, paint);
        return output;

    }


    public int getRadius() {
        return radius;
    }

    public void setRadius(int radius) {
        this.radius = radius;
    }


}
