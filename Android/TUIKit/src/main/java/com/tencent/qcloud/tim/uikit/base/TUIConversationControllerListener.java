package com.tencent.qcloud.tim.uikit.base;

public interface TUIConversationControllerListener {
    /**
     * 根据自定义的 IBaseInfo 得到要显示在消息列表的字符
     * @param baseInfo 自定义的 IBaseInfo
     * @return 要显示在消息列表的的字符
     */
    CharSequence getConversationDisplayString(IBaseInfo baseInfo);
}
