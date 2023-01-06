package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;
import android.widget.RelativeLayout;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuikit.tuichat.R;

public class MinimalistMessageLayout extends RelativeLayout {
    private View msgArea;
    private View quoteArea;
    private View translationArea;
    private View replyArea;

    private boolean isStart = false;
    private Paint paint;
    private Path quotePath;
    private Path translationPath;
    private Path replyPath;

    private Rect msgAreaRect;
    private Rect translationRect;
    private Rect quoteRect;
    private Rect replyRect;
    private float strokeWidth;

    public MinimalistMessageLayout(Context context) {
        super(context);
        init();
    }

    public MinimalistMessageLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public MinimalistMessageLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public MinimalistMessageLayout(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init();
    }

    private void init() {
        setWillNotDraw(false);
        quotePath = new Path();
        translationPath = new Path();
        replyPath = new Path();
        msgAreaRect = new Rect();
        translationRect = new Rect();
        quoteRect = new Rect();
        replyRect = new Rect();
        paint = new Paint();
        strokeWidth = getResources().getDimension(R.dimen.chat_minimalist_message_quato_line_width);
        paint.setStrokeWidth(strokeWidth);
        paint.setStyle(Paint.Style.STROKE);
        paint.setAntiAlias(true);
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);
        msgArea = findViewById(R.id.msg_area);
        translationArea = findViewById(R.id.translate_content_fl);
        quoteArea = findViewById(R.id.quote_content_fl);
        replyArea = findViewById(R.id.msg_reply_preview);
        drawLine(canvas);
    }

    public void setIsStart(boolean isStart) {
        this.isStart = isStart;
    }

    private Rect getChildRectInParent(View child) {
        int[] location = new int[2];
        getLocationInWindow(location);

        Rect rect = new Rect();
        int[] childLocation = new int[2];
        child.getLocationInWindow(childLocation);
        int left = childLocation[0] - location[0];
        int top = childLocation[1] - location[1];
        int right = left + child.getWidth();
        int bottom = top + child.getHeight();
        rect.set(left, top, right, bottom);
        return rect;
    }

    private void drawLine(Canvas canvas) {
        canvas.drawColor(0x00FFFFFF);
        if (msgArea.getVisibility() == VISIBLE) {
            float msgX, msgCenterY;
            msgAreaRect = getChildRectInParent(msgArea);
            if (isStart) {
                paint.setColor(getResources().getColor(R.color.chat_minimalist_left_message_bubble_color));
                msgX = msgAreaRect.left + strokeWidth / 2;
            } else {
                paint.setColor(getResources().getColor(R.color.chat_minimalist_right_message_bubble_color));
                msgX = msgAreaRect.right - strokeWidth / 2;
            }
            msgCenterY = msgAreaRect.top + msgAreaRect.height() * 1.0f / 2;
            if (translationArea.getVisibility() == VISIBLE) {
                float translationX, translationCenterY;
                translationRect = getChildRectInParent(translationArea);
                if (isStart) {
                    translationX = translationRect.left;
                } else {
                    translationX = translationRect.right;
                }
                translationCenterY = translationRect.top + translationRect.height() * 1.0f / 2;
                int translationControlRadius = (int) Math.abs(translationX - msgX);
                translationPath.reset();
                translationPath.moveTo(msgX, msgCenterY);
                translationPath.quadTo(msgX, translationCenterY - translationControlRadius, msgX, translationCenterY - translationControlRadius);
                translationPath.quadTo(msgX, translationCenterY, translationX, translationCenterY);
                canvas.drawPath(translationPath, paint);
            }
            if (quoteArea.getVisibility() == VISIBLE) {
                float quoteX, quoteCenterY;
                quoteRect = getChildRectInParent(quoteArea);
                if (isStart) {
                    quoteX = quoteRect.left;
                } else {
                    quoteX = quoteRect.right;
                }
                quoteCenterY = quoteRect.top + quoteRect.height() * 1.0f / 2;
                int quoteControlRadius = (int) Math.abs(quoteX - msgX);
                quotePath.reset();
                quotePath.moveTo(msgX, msgCenterY);
                quotePath.quadTo(msgX, quoteCenterY - quoteControlRadius, msgX, quoteCenterY - quoteControlRadius);
                quotePath.quadTo(msgX, quoteCenterY, quoteX, quoteCenterY);
                canvas.drawPath(quotePath, paint);
            }
            if (replyArea.getVisibility() == VISIBLE) {
                float replyX, replyCenterY;
                replyRect = getChildRectInParent(replyArea);
                if (isStart) {
                    replyX = replyRect.left;
                } else {
                    replyX = replyRect.right;
                }
                replyCenterY = replyRect.top + replyRect.height() * 1.0f / 2;
                int replyControlRadius = (int) Math.abs(replyX - msgX);
                replyPath.reset();
                replyPath.moveTo(msgX, msgCenterY);
                replyPath.quadTo(msgX, replyCenterY - replyControlRadius, msgX, replyCenterY - replyControlRadius);
                replyPath.quadTo(msgX, replyCenterY, replyX, replyCenterY);
                canvas.drawPath(replyPath, paint);
            }
        }
    }
}
