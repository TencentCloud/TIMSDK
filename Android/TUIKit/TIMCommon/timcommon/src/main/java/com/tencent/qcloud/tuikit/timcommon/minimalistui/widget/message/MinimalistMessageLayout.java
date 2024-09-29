package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.Path;
import android.graphics.Rect;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;
import androidx.constraintlayout.widget.ConstraintLayout;

import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;

public class MinimalistMessageLayout extends ConstraintLayout {
    private View msgArea;
    private View quoteArea;
    private View bottomArea;
    private View replyArea;

    private boolean isStart = false;
    private Paint paint;
    private Path quotePath;
    private Path bottomPath;
    private Path replyPath;

    private Rect msgAreaRect;
    private Rect bottomRect;
    private Rect quoteRect;
    private Rect replyRect;
    private float strokeWidth;

    private boolean isRTL = false;

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
        isRTL = LayoutUtil.isRTL();
        quotePath = new Path();
        bottomPath = new Path();
        replyPath = new Path();
        msgAreaRect = new Rect();
        bottomRect = new Rect();
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
        bottomArea = findViewById(R.id.bottom_content_fl);
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
            msgAreaRect = getChildRectInParent(msgArea);
            float msgX;
            if (isStart) {
                if (isRTL) {
                    paint.setColor(getResources().getColor(R.color.chat_minimalist_right_message_bubble_color));
                    msgX = msgAreaRect.right - strokeWidth / 2;
                } else {
                    paint.setColor(getResources().getColor(R.color.chat_minimalist_left_message_bubble_color));
                    msgX = msgAreaRect.left + strokeWidth / 2;
                }
            } else {
                if (isRTL) {
                    paint.setColor(getResources().getColor(R.color.chat_minimalist_left_message_bubble_color));
                    msgX = msgAreaRect.left + strokeWidth / 2;
                } else {
                    paint.setColor(getResources().getColor(R.color.chat_minimalist_right_message_bubble_color));
                    msgX = msgAreaRect.right - strokeWidth / 2;
                }
            }
            float msgCenterY;
            msgCenterY = msgAreaRect.top + msgAreaRect.height() * 1.0f / 2;
            drawBottomArea(canvas, msgX, msgCenterY);
            drawQuoteArea(canvas, msgX, msgCenterY);
            drawReplyArea(canvas, msgX, msgCenterY);
        }
    }

    private void drawReplyArea(Canvas canvas, float msgX, float msgCenterY) {
        if (replyArea.getVisibility() == VISIBLE) {
            float replyX;
            float replyCenterY;
            replyRect = getChildRectInParent(replyArea);
            if (isStart) {
                if (isRTL) {
                    replyX = replyRect.right;
                } else {
                    replyX = replyRect.left;
                }
            } else {
                if (isRTL) {
                    replyX = replyRect.left;
                } else {
                    replyX = replyRect.right;
                }
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

    private void drawQuoteArea(Canvas canvas, float msgX, float msgCenterY) {
        if (quoteArea.getVisibility() == VISIBLE) {
            float quoteX;
            float quoteCenterY;
            quoteRect = getChildRectInParent(quoteArea);
            if (isStart) {
                if (isRTL) {
                    quoteX = quoteRect.right;
                } else {
                    quoteX = quoteRect.left;
                }
            } else {
                if (isRTL) {
                    quoteX = quoteRect.left;
                } else {
                    quoteX = quoteRect.right;
                }
            }
            quoteCenterY = quoteRect.top + quoteRect.height() * 1.0f / 2;
            int quoteControlRadius = (int) Math.abs(quoteX - msgX);
            quotePath.reset();
            quotePath.moveTo(msgX, msgCenterY);
            quotePath.quadTo(msgX, quoteCenterY - quoteControlRadius, msgX, quoteCenterY - quoteControlRadius);
            quotePath.quadTo(msgX, quoteCenterY, quoteX, quoteCenterY);
            canvas.drawPath(quotePath, paint);
        }
    }

    private void drawBottomArea(Canvas canvas, float msgX, float msgCenterY) {
        if (bottomArea.getVisibility() == VISIBLE) {
            float bottomX;
            float bottomCenterY;
            bottomRect = getChildRectInParent(bottomArea);
            if (isStart) {
                if (isRTL) {
                    bottomX = bottomRect.right;
                } else {
                    bottomX = bottomRect.left;
                }
            } else {
                if (isRTL) {
                    bottomX = bottomRect.left;
                } else {
                    bottomX = bottomRect.right;
                }
            }
            bottomCenterY = bottomRect.top + bottomRect.height() * 1.0f / 2;
            int bottomControlRadius = (int) Math.abs(bottomX - msgX);
            bottomPath.reset();
            bottomPath.moveTo(msgX, msgCenterY);
            bottomPath.quadTo(msgX, bottomCenterY - bottomControlRadius, msgX, bottomCenterY - bottomControlRadius);
            bottomPath.quadTo(msgX, bottomCenterY, bottomX, bottomCenterY);
            canvas.drawPath(bottomPath, paint);
        }
    }
}
