package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder;

import android.view.View;

import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;

public class LocationMessageHolder extends MessageContentHolder {

    public LocationMessageHolder(View itemView) {
        super(itemView);
    }

    @Override
    public int getVariableLayout() {
        return 0;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {

    }

}
