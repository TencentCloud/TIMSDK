package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.content.Context;
import android.graphics.Color;
import android.text.Layout;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.R;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;

public class TimeInLineTextLayout extends FrameLayout {
    private TextView textView;
    private MessageStatusTimeView statusArea;
    private int lineCount;
    private boolean isRTL = false;
    private int lastLineWidth = 0;
    private boolean lastLineRunRTL = true;

    public TimeInLineTextLayout(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public TimeInLineTextLayout(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public TimeInLineTextLayout(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        isRTL = LayoutUtil.isRTL();
        textView = new TextView(context, null, R.style.ChatMinimalistMessageTextStyle);
        textView.setTextColor(Color.BLACK);
        textView.setTextSize(TypedValue.COMPLEX_UNIT_PX, textView.getResources().getDimension(R.dimen.chat_minimalist_message_text_size));
        LayoutParams textViewParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        addView(textView, textViewParams);
        statusArea = new MessageStatusTimeView(context);
        LayoutParams statusAreaParams = new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
        addView(statusArea, statusAreaParams);
    }

    public void setText(CharSequence charSequence) {
        textView.setText(charSequence);
    }

    public void setText(int resID) {
        textView.setText(resID);
    }

    public void setStatusIcon(int resID) {
        statusArea.setStatusIcon(resID);
    }

    public void setTimeText(CharSequence charSequence) {
        statusArea.setTimeText(charSequence);
    }

    public void setTimeColor(int color) {
        statusArea.setTimeColor(color);
    }

    public void setTextColor(int color) {
        textView.setTextColor(color);
    }

    public void setTextSize(int size) {
        textView.setTextSize(size);
    }

    public TextView getTextView() {
        return textView;
    }

    public void setOnStatusAreaClickListener(OnClickListener listener) {
        statusArea.setOnClickListener(listener);
    }

    public void setOnStatusAreaLongClickListener(OnLongClickListener listener) {
        statusArea.setOnLongClickListener(listener);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        int textViewWidth = textView.getMeasuredWidth();
        int textViewHeight = textView.getMeasuredHeight();
        int statusAreaWidth = statusArea.getMeasuredWidth();
        int statusAreaHeight = statusArea.getMeasuredHeight();
        if (isRTL) {
            if (lineCount <= 1) {
                textView.layout(statusAreaWidth, 0, statusAreaWidth + textViewWidth, textViewHeight);
            } else {
                textView.layout(0, 0, textViewWidth, textViewHeight);
            }
        } else {
            textView.layout(0, 0, textViewWidth, textViewHeight);
        }

        if (isRTL) {
            if (lineCount <= 1) {
                statusArea.layout(0, bottom - top - statusAreaHeight, statusAreaWidth, bottom - top);
            } else {
                if (lastLineRunRTL) {
                    statusArea.layout(0, bottom - top - statusAreaHeight, statusAreaWidth, bottom - top);
                } else {
                    statusArea.layout(right - left - statusAreaWidth, bottom - top - statusAreaHeight, right - left, bottom - top);
                }
            }
        } else {
            statusArea.layout(right - left - statusAreaWidth, bottom - top - statusAreaHeight, right - left, bottom - top);
        }
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int maxWidth;
        int maxHeight;
        // measure text view
        measureChildren(widthMeasureSpec, heightMeasureSpec);

        int textWidth = textView.getMeasuredWidth();
        int textHeight = textView.getMeasuredHeight();
        lineCount = textView.getLineCount();

        // get last line's width
        Layout layout = textView.getLayout();
        if (layout != null) {
            lastLineWidth = (int) layout.getLineWidth(lineCount - 1);
            int direction = layout.getParagraphDirection(lineCount - 1);
            lastLineRunRTL = direction == Layout.DIR_RIGHT_TO_LEFT;
        }

        int statusAreaWidth = statusArea.getMeasuredWidth();
        int statusAreaHeight = statusArea.getMeasuredHeight();
        MarginLayoutParams lp = (MarginLayoutParams) statusArea.getLayoutParams();
        statusAreaWidth += lp.leftMargin + lp.rightMargin;

        int layoutWidth = MeasureSpec.getSize(widthMeasureSpec);
        // switch a new line
        if (lastLineWidth + statusAreaWidth > layoutWidth) {
            maxHeight = textHeight + statusAreaHeight;
            lineCount++;
            maxWidth = Math.max(textWidth, statusAreaWidth);
        } else {
            maxHeight = Math.max(textHeight, statusAreaHeight);
            maxWidth = Math.max(textWidth, lastLineWidth + statusAreaWidth);
        }

        setMeasuredDimension(maxWidth, maxHeight);
    }
}
