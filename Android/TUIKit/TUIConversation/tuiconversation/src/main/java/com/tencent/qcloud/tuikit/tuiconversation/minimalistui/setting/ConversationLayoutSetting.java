package com.tencent.qcloud.tuikit.tuiconversation.minimalistui.setting;

import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.IConversationLayout;
import com.tencent.qcloud.tuikit.tuiconversation.minimalistui.interfaces.IConversationListLayout;

public class ConversationLayoutSetting {
    public static void customizeConversation(final IConversationLayout layout) {
        IConversationListLayout listLayout = (IConversationListLayout) layout.getConversationList();

        listLayout.setItemAvatarRadius(ScreenUtil.dip2px(49f));

        
        //        final ConversationInfo customInfo = new ConversationInfo();
        //        customInfo.setType(ConversationInfo.TYPE_CUSTOM);
        
        //        customInfo.setGroup(false);
        
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
