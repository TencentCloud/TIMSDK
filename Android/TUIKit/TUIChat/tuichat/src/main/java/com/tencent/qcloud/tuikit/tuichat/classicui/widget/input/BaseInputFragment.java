package com.tencent.qcloud.tuikit.tuichat.classicui.widget.input;

import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tuikit.tuichat.classicui.interfaces.IChatLayout;

public class BaseInputFragment extends Fragment {
    private IChatLayout mChatLayout;

    public IChatLayout getChatLayout() {
        return mChatLayout;
    }

    public BaseInputFragment setChatLayout(IChatLayout layout) {
        mChatLayout = layout;
        return this;
    }
}
