package com.tencent.qcloud.tim.uikit.component;

import android.content.Context;
import android.support.annotation.Nullable;
import android.util.AttributeSet;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.INoticeLayout;

public class NoticeLayout extends RelativeLayout implements INoticeLayout {

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
        inflate(getContext(), R.layout.chat_notice_layout, this);
        mContentText = findViewById(R.id.notice_content);
        mContentExtraText = findViewById(R.id.notice_content_extra);
    }

    @Override
    public TextView getContent() {
        return mContentText;
    }

    @Override
    public TextView getContentExtra() {
        return mContentExtraText;
    }

    @Override
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

    @Override
    public void alwaysShow(boolean show) {
        mAwaysShow = show;
        if (mAwaysShow) {
            super.setVisibility(VISIBLE);
        }
    }
}
