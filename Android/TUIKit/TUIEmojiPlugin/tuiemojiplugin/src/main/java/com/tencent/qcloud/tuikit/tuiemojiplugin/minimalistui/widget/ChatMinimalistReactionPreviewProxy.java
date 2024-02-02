package com.tencent.qcloud.tuikit.tuiemojiplugin.minimalistui.widget;

import android.view.View;
import android.widget.FrameLayout;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.calssicui.widget.ChatFlowReactView;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionPreviewPresenter;

public class ChatMinimalistReactionPreviewProxy {
    public static void fill(TUIMessageBean messageBean, FrameLayout reactionAreaContainer) {
        int childCount = reactionAreaContainer.getChildCount();
        ChatReactView reactView;
        if (childCount == 0) {
            reactView = new ChatReactView(reactionAreaContainer.getContext());
            reactionAreaContainer.addView(reactView);
        } else {
            View view = reactionAreaContainer.getChildAt(0);
            if (view instanceof ChatFlowReactView) {
                reactView = (ChatReactView) view;
            } else {
                reactView = new ChatReactView(reactionAreaContainer.getContext());
                reactionAreaContainer.removeAllViews();
                reactionAreaContainer.addView(reactView);
            }
        }
        reactView.setVisibility(View.GONE);

        MessageReactionPreviewPresenter presenter = reactView.getPresenter();
        presenter.loadData(messageBean);
    }
}
