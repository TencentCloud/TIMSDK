package com.tencent.qcloud.tuikit.tuiemojiplugin.calssicui.widget;

import android.view.View;
import android.widget.FrameLayout;

import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.FileMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.MergeMessageBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionPreviewPresenter;

public class ChatClassicReactionPreviewProxy {
    public static void fill(TUIMessageBean messageBean, FrameLayout reactionAreaContainer) {
        int childCount = reactionAreaContainer.getChildCount();
        ChatFlowReactView flowReactView;
        if (childCount == 0) {
            flowReactView = new ChatFlowReactView(reactionAreaContainer.getContext());
            reactionAreaContainer.addView(flowReactView);
        } else {
            View view = reactionAreaContainer.getChildAt(0);
            if (view instanceof ChatFlowReactView) {
                flowReactView = (ChatFlowReactView) view;
            } else {
                flowReactView = new ChatFlowReactView(reactionAreaContainer.getContext());
                reactionAreaContainer.removeAllViews();
                reactionAreaContainer.addView(flowReactView);
            }
        }
        if (!messageBean.isSelf() || messageBean instanceof MergeMessageBean || messageBean instanceof FileMessageBean) {
            flowReactView.setThemeColorId(TUIThemeManager.getAttrResId(flowReactView.getContext(), com.tencent.qcloud.tuikit.timcommon.R.attr.chat_react_other_text_color));
        } else {
            flowReactView.setThemeColorId(0);
        }
        flowReactView.setVisibility(View.GONE);

        MessageReactionPreviewPresenter presenter = flowReactView.getPresenter();
        presenter.loadData(messageBean);
    }
}
