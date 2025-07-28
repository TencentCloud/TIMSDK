package com.tencent.qcloud.tuikit.tuichat.classicui.page;

import android.content.Intent;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;

import androidx.annotation.Nullable;
import androidx.core.graphics.drawable.DrawableCompat;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.util.TIMCommonUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.C2CChatInfo;
import com.tencent.qcloud.tuikit.tuichat.bean.ChatInfo;
import com.tencent.qcloud.tuikit.tuichat.presenter.C2CChatPresenter;
import com.tencent.qcloud.tuikit.tuichat.presenter.FriendProfilePresenter;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUIC2CChatFragment extends TUIBaseChatFragment {
    private static final String TAG = TUIC2CChatFragment.class.getSimpleName();

    private final C2CChatPresenter presenter;
    private final FriendProfilePresenter friendProfilePresenter = new FriendProfilePresenter();

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
        if (TIMCommonUtil.isChatbot(chatInfo.getId())) {
            titleBar.setRightIcon(R.drawable.chat_chatbot_clear_message_icon);
            Drawable drawable = titleBar.getRightIcon().getDrawable();
            if (drawable != null) {
                drawable = DrawableCompat.wrap(drawable);
                DrawableCompat.setTint(drawable, 0x444444);
                titleBar.getRightIcon().setImageDrawable(drawable);
            }
            titleBar.setOnRightClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    new TUIKitDialog(getContext())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getContext().getString(R.string.clear_msg_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.sure), v13 -> presenter.clearHistoryMessage())
                        .setNegativeButton(getContext().getString(com.tencent.qcloud.tuicore.R.string.cancel), v14 -> {})
                        .show();
                }
            });
            return;
        }
        titleBar.setRightIcon(R.drawable.chat_title_bar_more_menu_icon);
        titleBar.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Map<String, Object> param = new HashMap<>();
                param.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID, chatInfo.getId());
                List<TUIExtensionInfo> extensionInfoList =
                    TUICore.getExtensionList(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.CLASSIC_EXTENSION_ID, param);
                if (!extensionInfoList.isEmpty()) {
                    Collections.sort(extensionInfoList, new Comparator<TUIExtensionInfo>() {
                        @Override
                        public int compare(TUIExtensionInfo o1, TUIExtensionInfo o2) {
                            return o2.getWeight() - o1.getWeight();
                        }
                    });
                    TUIExtensionInfo extensionInfo = extensionInfoList.get(0);
                    TUIExtensionEventListener eventListener = extensionInfo.getExtensionListener();
                    if (eventListener != null) {
                        Map<String, Object> map = new HashMap<>();
                        map.put(TUIConstants.TUIChat.Extension.ChatNavigationMoreItem.USER_ID, chatInfo.getId());
                        map.put(TUIChatConstants.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
                        eventListener.onClicked(map);
                    }
                } else {
                    String userId = chatInfo.getId();
                    openFriendProfile(userId);
                }
            }
        });
    }

    private void openFriendProfile(String userId) {
        Intent intent = new Intent(getContext(), FriendProfileActivity.class);
        intent.putExtra(TUIConstants.TUIChat.CHAT_ID, userId);
        intent.putExtra(TUIChatConstants.CHAT_BACKGROUND_URI, mChatBackgroundThumbnailUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
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
