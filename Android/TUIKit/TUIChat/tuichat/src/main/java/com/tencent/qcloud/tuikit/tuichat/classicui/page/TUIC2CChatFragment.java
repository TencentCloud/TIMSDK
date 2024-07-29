package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.Nullable;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIC2CChatFragment extends TUIBaseChatFragment {
    private static final String TAG = TUIC2CChatFragment.class.getSimpleName();

    private final C2CChatPresenter presenter;

    public TUIC2CChatFragment() {
        presenter = new C2CChatPresenter();
        presenter.initListener();
    }

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
        TUIChatLog.i(TAG, "oncreate view " + this);

        baseView = super.onCreateView(inflater, container, savedInstanceState);
        if (!(chatInfo instanceof C2CChatInfo)) {
            return baseView;
        }

        initView();

        return baseView;
    }

    @Override
    protected void initView() {
        super.initView();

        setTitleBarExtension();

        chatView.setPresenter(presenter);
        presenter.setChatInfo((C2CChatInfo) chatInfo);
        presenter.setTypingListener(chatView.mTypingListener);
        chatView.setChatInfo(chatInfo);
    }

    private void setTitleBarExtension() {
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID, chatInfo.getId());
        List<TUIExtensionInfo> extensionInfoList = TUICore.getExtensionList(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, param);
        if (!extensionInfoList.isEmpty()) {
            Collections.sort(extensionInfoList, new Comparator<TUIExtensionInfo>() {
                @Override
                public int compare(TUIExtensionInfo o1, TUIExtensionInfo o2) {
                    return o2.getWeight() - o1.getWeight();
                }
            });

            Collections.singletonList(extensionInfoList);
            TUIExtensionInfo extensionInfo = extensionInfoList.get(0);
            titleBar.setRightIcon((Integer) extensionInfo.getIcon());
            titleBar.setOnRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TUIExtensionEventListener eventListener = extensionInfo.getExtensionListener();
                    if (eventListener != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID, chatInfo.getId());
                        map.put(TUIConstants.TUIChat.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                        eventListener.onClicked(map);
                    }
                }
            });
        }
    }

    @Override
    public C2CChatPresenter getPresenter() {
        return presenter;
    }

    @Override
    public C2CChatInfo getChatInfo() {
        return (C2CChatInfo) chatInfo;
    }

    public void setChatInfo(C2CChatInfo c2CChatInfo) {
        this.chatInfo = c2CChatInfo;
    }
}
