package com.tencent.qcloud.tuikit.tuiemojiplugin.presenter;

import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionUserBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.model.TUIEmojiProvider;
import java.util.List;

public class TUIEmojiPresenter {
    private static final String TAG = "TUIEmojiPresenter";
    private TUIEmojiProvider provider;

    public TUIEmojiPresenter() {
        provider = new TUIEmojiProvider();
    }


    public void addMessageReaction(TUIMessageBean messageBean, String reactionID, TUICallback callback) {
        provider.addMessageReaction(messageBean, reactionID, callback);
    }

    public void removeMessageReaction(TUIMessageBean messageBean, String reactionID, TUICallback callback) {
        provider.removeMessageReaction(messageBean, reactionID, callback);
    }

    public void getMessageReactions(List<TUIMessageBean> messageBeans, int maxUserCountPerReaction, TUIValueCallback<List<MessageReactionBean>> callback) {
        provider.getMessageReactions(messageBeans, maxUserCountPerReaction, callback);
    }

    public void getAllUserListOfMessageReaction(
        TUIMessageBean messageBean, String reactionID, int nextSeq, int count, TUIValueCallback<MessageReactionUserBean> callback) {
        provider.getAllUserListOfMessageReaction(messageBean, reactionID, nextSeq, count, callback);
    }
}
