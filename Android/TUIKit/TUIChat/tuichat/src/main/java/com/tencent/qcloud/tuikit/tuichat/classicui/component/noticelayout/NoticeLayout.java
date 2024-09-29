package com.tencent.qcloud.tuikit.tuichat.classicui.component.noticelayout;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tuikit.tuichat.R;

public class NoticeLayout extends RelativeLayout {
    private RelativeLayout mNoticeLayout;
    private TextView mContentText;
    private TextView mContentExtraText;
    private boolean mAwaysShow;

    public NoticeLayout(Context context) {
        super(context);
        init();
    }

    public NoticeLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public NoticeLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.notice_layout, this);
        mNoticeLayout = findViewById(R.id.notice_layout);
        mContentText = findViewById(R.id.notice_content);
        mContentExtraText = findViewById(R.id.notice_content_extra);
    }

    public RelativeLayout getParentLayout() {
        return mNoticeLayout;
    }

    public TextView getContent() {
        return mContentText;
    }

    public TextView getContentExtra() {
        return mContentExtraText;
    }

    public void setOnNoticeClickListener(OnClickListener l) {
        setOnClickListener(l);
    }

    @Override
    public void setVisibility(int visibility) {
        if (mAwaysShow) {
            super.setVisibility(VISIBLE);
        } else {
            super.setVisibility(visibility);
        }
    }

    public void alwaysShow(boolean show) {
        mAwaysShow = show;
        if (mAwaysShow) {
            super.setVisibility(VISIBLE);
        }
    }
}
