package com.tencent.qcloud.uipojo.chat;

import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.qcloud.tim.tuikit.R;
import com.tencent.qcloud.uikit.business.chat.group.view.GroupChatPanel;
import com.tencent.qcloud.uikit.common.BaseFragment;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;
import com.tencent.qcloud.uipojo.utils.Constants;

/**
 * Created by valxehuang on 2018/7/30.
 */

public class GroupChatFragment extends BaseFragment {
    private View mBaseView;
    private GroupChatPanel chatPanel;
    private PageTitleBar chatTitleBar;
    private String groupChatId;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        mBaseView = inflater.inflate(R.layout.chat_fragment_group, container, false);
        Bundle datas = getArguments();
        //由会话列表传入的会话ID（群组ID）
        groupChatId = datas.getString(Constants.INTENT_DATA);
        initView();
        return mBaseView;
    }

    private void initView() {
        //从布局文件中获取聊天面板组件
        chatPanel = mBaseView.findViewById(R.id.chat_panel);
        //单聊组件的默认UI和交互初始化
        chatPanel.initDefault();
        /*
         * GroupChatPanel在初始化完成后需要入会话ID（即群组ID，具体可参考IMSDK接入文档）来加载聊天消息。在上一章节SessionClickListener中回调函数的参数SessionInfo对象中持有每一会话的会话ID，如果是群会话则为群组ID，所以在会话列表点击时都可传入会话ID。

         * 特殊的如果用户应用不具备类似会话列表相关的组件，则在使用群聊面板时需自行实现逻辑获取群组ID传入。
         */
        chatPanel.setBaseChatId(groupChatId);

        //获取标题栏
        chatTitleBar = chatPanel.getTitleBar();
        //设置标题栏的返回按钮点击事件,需开发者自行控制
        chatTitleBar.setLeftClick(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                getActivity().finish();
            }
        });

    }

}
