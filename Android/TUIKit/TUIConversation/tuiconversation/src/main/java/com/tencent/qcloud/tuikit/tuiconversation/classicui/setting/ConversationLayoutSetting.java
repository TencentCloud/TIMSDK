package com.tencent.qcloud.tuikit.tuiconversation.classicui.setting;

import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.classicui.widget.ConversationListLayout;

public class ConversationLayoutSetting {

    public static void customizeConversation(final ConversationLayout layout) {

        ConversationListLayout listLayout = (ConversationListLayout) layout.getConversationList();

        listLayout.setItemTopTextSize(16);
        listLayout.setItemBottomTextSize(12);
        listLayout.setItemDateTextSize(10);
        listLayout.setItemAvatarRadius(5);
        listLayout.disableItemUnreadDot(false);

        // 动态插入，删除Item，包括自定义会话
//        final ConversationInfo customInfo = new ConversationInfo();
//        customInfo.setType(ConversationInfo.TYPE_CUSTOM);
//        customInfo.setId("自定义会话");
//        customInfo.setGroup(false);
//        customInfo.setTitle("乔丹风行8代跑鞋 风随我动！");
//        customInfo.setIconUrl("https://img1.gtimg.com/ninja/2/2019/03/ninja155375585738456.jpg");
//
//
//        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                layout.addConversationInfo(0, customInfo);
//            }
//        }, 3000);

//        new Handler(Looper.getMainLooper()).postDelayed(new Runnable() {
//            @Override
//            public void run() {
//                layout.removeConversationInfo(0);
//            }
//        }, 5000);
    }

}
