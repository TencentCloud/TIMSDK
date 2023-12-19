package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget;

import android.view.View;
import android.view.ViewGroup;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.R;

public class InvisibleHolder extends MessageContentHolder {
    private View rootView;
    public InvisibleHolder(View itemView) {
        super(itemView);
        rootView = itemView;
    }

    @Override
    public int getVariableLayout() {
        return R.layout.chat_bot_message_adapter_invisible;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        RecyclerView.LayoutParams params = new RecyclerView.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT);
        params.height = 0;
        params.width = 0;
        rootView.setVisibility(View.GONE);
        rootView.setLayoutParams(params);
    }
}
