package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.IChatLayout;

public class BaseInputFragment extends BaseFragment {
    private IChatLayout mChatLayout;

    public IChatLayout getChatLayout() {
        return mChatLayout;
    }

    public BaseInputFragment setChatLayout(IChatLayout layout) {
        mChatLayout = layout;
        return this;
    }
}
