package com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message;

import android.content.Context;
import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.timcommon.R;

public class MessageStatusTimeView extends FrameLayout {
    private TextView timeView;
    private ImageView statusIconView;

    public MessageStatusTimeView(@NonNull Context context) {
        super(context);
        init(context, null);
    }

    public MessageStatusTimeView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public MessageStatusTimeView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        LayoutInflater.from(context).inflate(R.layout.chat_minimalist_text_status_layout, this);
        statusIconView = findViewById(R.id.status_icon);
        timeView = findViewById(R.id.time);
    }

    public void setStatusIcon(int resID) {
        if (resID == 0) {
            statusIconView.setVisibility(GONE);
        } else {
            statusIconView.setBackgroundResource(resID);
            Drawable drawable = statusIconView.getBackground();
            if (drawable instanceof Animatable) {
                ((Animatable) drawable).start();
            }
            statusIconView.setVisibility(VISIBLE);
        }
    }

    public void setTimeText(CharSequence charSequence) {
        timeView.setText(charSequence);
    }

    public void setTimeColor(int color) {
        timeView.setTextColor(color);
    }
}
