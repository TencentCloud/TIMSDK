package com.tencent.qcloud.uikit.business.chat.view;


import com.tencent.qcloud.uikit.business.chat.model.MessageInfo;
import com.tencent.qcloud.uikit.common.utils.UIUtils;
import com.tencent.qcloud.uikit.common.widget.DynamicLayoutView;


public abstract class DynamicChatUserIconView extends DynamicLayoutView<MessageInfo> {
    private int iconRadius = -1;

    public int getIconRadius() {
        return iconRadius;
    }

    /**
     * 设置聊天头像圆角
     *
     * @param iconRadius
     */
    public void setIconRadius(int iconRadius) {
        this.iconRadius = UIUtils.getPxByDp(iconRadius);
    }
}
