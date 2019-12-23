package com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore;

import android.content.Context;
import android.support.annotation.Nullable;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import com.tencent.qcloud.tim.uikit.R;

import java.util.List;

public class InputMoreLayout extends LinearLayout {

    public InputMoreLayout(Context context) {
        super(context);
        init();
    }

    public InputMoreLayout(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        init();
    }

    public InputMoreLayout(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        init();
    }

    private void init() {
        inflate(getContext(), R.layout.chat_inputmore_layout, this);
    }

    // 初始化更多布局adapter
    public void init(List<InputMoreActionUnit> actions) {

        final ViewPager viewPager = findViewById(R.id.viewPager);

        ActionsPagerAdapter adapter = new ActionsPagerAdapter(viewPager, actions);
        viewPager.setAdapter(adapter);
    }

}
