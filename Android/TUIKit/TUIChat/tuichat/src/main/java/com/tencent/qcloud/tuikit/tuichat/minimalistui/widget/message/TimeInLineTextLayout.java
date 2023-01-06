package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message;

import android.content.Context;
import android.graphics.Color;
import android.text.Layout;
import android.util.AttributeSet;
import android.util.TypedValue;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.tuichat.R;

public class TimeInLineTextLayout extends FrameLayout {

    private TextView textView;
    private MessageStatusTimeView statusArea;

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
        textView.layout(0, 0, textViewWidth, textViewHeight);
        int statusAreaWidth = statusArea.getMeasuredWidth();
        int statusAreaHeight = statusArea.getMeasuredHeight();
        statusArea.layout(right - left - statusAreaWidth, bottom - top - statusAreaHeight, right - left, bottom - top);
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        int maxWidth, maxHeight;
        // measure text view
        measureChildren(widthMeasureSpec, heightMeasureSpec);

        int textWidth = textView.getMeasuredWidth();
        int textHeight = textView.getMeasuredHeight();
        int lineCount = textView.getLineCount();

        // get last line's width
        int lastLineWidth = 0;
        Layout layout = textView.getLayout();
        if (layout != null) {
            int start = layout.getLineStart(lineCount - 1);
            int end = layout.getLineEnd(lineCount - 1);
            float startX = layout.getPrimaryHorizontal(start);
            float endX = layout.getSecondaryHorizontal(end);
            lastLineWidth = (int) (endX - startX);
        }

        int statusAreaWidth = statusArea.getMeasuredWidth();
        int statusAreaHeight = statusArea.getMeasuredHeight();
        MarginLayoutParams lp = (MarginLayoutParams) statusArea.getLayoutParams();
        statusAreaWidth += lp.leftMargin + lp.rightMargin;

        int layoutWidth = MeasureSpec.getSize(widthMeasureSpec);
        // switch a new line
        if (lastLineWidth + statusAreaWidth > layoutWidth) {
            maxHeight = textHeight + statusAreaHeight;
            maxWidth = Math.max(textWidth, statusAreaWidth);
        } else {
            maxHeight = Math.max(textHeight, statusAreaHeight);
            maxWidth = Math.max(textWidth, lastLineWidth + statusAreaWidth);
        }

        setMeasuredDimension(maxWidth, maxHeight);
    }
}
