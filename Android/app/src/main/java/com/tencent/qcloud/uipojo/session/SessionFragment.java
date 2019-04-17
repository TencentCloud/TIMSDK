package com.tencent.qcloud.uipojo.session;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.tuikit.R;
import com.tencent.qcloud.uikit.business.session.model.SessionInfo;
import com.tencent.qcloud.uikit.business.session.view.SessionPanel;
import com.tencent.qcloud.uikit.business.session.view.wedgit.SessionClickListener;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uipojo.chat.ChatActivity;

/**
 * Created by valxehuang on 2018/7/17.
 */

public class SessionFragment extends BaseFragment implements SessionClickListener {
    private View baseView;
    private SessionPanel sessionPanel;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        baseView = inflater.inflate(R.layout.fragment_session, container, false);
        initView();
        return baseView;
    }


    private void initView() {

        // 获取会话列表组件，
        sessionPanel = baseView.findViewById(R.id.session_panel);
        // 会话面板初始化默认功能
        sessionPanel.initDefault();
        // 这里设置会话列表点击的跳转逻辑，告诉添加完SessionPanel后会话被点击后该如何处理
        sessionPanel.setSessionClick(this);

    }

    @Override
    public void onSessionClick(SessionInfo session) {
        //此处为demo的实现逻辑，更根据会话类型跳转到相关界面，开发者可根据自己的应用场景灵活实现
        if (session.isGroup()) {
            //如果是群组，跳转到群聊界面
            ChatActivity.startGroupChat(getActivity(), session.getPeer());
        } else {
            //否则跳转到C2C单聊界面
            ChatActivity.startC2CChat(getActivity(), session.getPeer());

        }
    }
}
