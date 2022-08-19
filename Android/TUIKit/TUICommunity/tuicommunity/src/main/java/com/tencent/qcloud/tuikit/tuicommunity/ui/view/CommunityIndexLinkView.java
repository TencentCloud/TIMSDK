package com.tencent.qcloud.tuikit.tuicommunity.ui.view;

import android.content.Context;
import android.content.Intent;
import android.content.res.TypedArray;
import android.os.Build;
import android.text.method.LinkMovementMethod;
import android.util.AttributeSet;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.FrameLayout;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityUtil;

public class CommunityIndexLinkView extends FrameLayout {
    private TextView indexTv;
    private TextView linkTv;

    public CommunityIndexLinkView(Context context) {
        super(context);
        init(context, null);
    }

    public CommunityIndexLinkView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init(context, attrs);
    }

    public CommunityIndexLinkView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init(context, attrs);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    public CommunityIndexLinkView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes) {
        super(context, attrs, defStyleAttr, defStyleRes);
        init(context, attrs);
    }

    private void init(Context context, AttributeSet attrs) {
        View view = LayoutInflater.from(context).inflate(R.layout.community_index_link_layout, this);
        indexTv = view.findViewById(R.id.index_tv);
        linkTv = view.findViewById(R.id.link_tv);
        TypedArray typedArray = context.obtainStyledAttributes(attrs, R.styleable.CommunityIndexLinkView);
        String contentText = typedArray.getString(R.styleable.CommunityIndexLinkView_content_link_text);
        int index = typedArray.getInteger(R.styleable.CommunityIndexLinkView_content_index, 0);
        String link = typedArray.getString(R.styleable.CommunityIndexLinkView_content_link);
        indexTv.setText(index + "");
        linkTv.setText(contentText);
        linkTv.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                CommunityUtil.openWebUrl(getContext(), link);
            }
        });
        linkTv.setMovementMethod(LinkMovementMethod.getInstance());
        typedArray.recycle();
    }
}
