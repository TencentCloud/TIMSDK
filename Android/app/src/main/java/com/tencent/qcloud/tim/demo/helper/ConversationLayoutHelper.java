package com.tencent.qcloud.tim.demo.helper;

import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationLayout;
import com.tencent.qcloud.tim.uikit.modules.conversation.ConversationListLayout;

public class ConversationLayoutHelper {

    public static void customizeConversation(final ConversationLayout layout) {

        ConversationListLayout listLayout = (ConversationListLayout) layout.getConversationList();

        listLayout.setItemTopTextSize(16); // 设置adapter item中top文字大小
        listLayout.setItemBottomTextSize(12);// 设置adapter item中bottom文字大小
        listLayout.setItemDateTextSize(10);// 设置adapter item中timeline文字大小
        listLayout.setItemAvatarRadius(5);// 设置adapter item头像圆角大小
        listLayout.disableItemUnreadDot(false);// 设置adapter item是否不显示未读红点，默认显示

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
