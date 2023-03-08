package com.tencent.qcloud.tuikit.tuichat.bean.message;

import android.text.TextUtils;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.io.Serializable;

public class CustomGroupNoteTipsMessageBean extends TUIMessageBean{

    public class CustomGroupNoteTipsMessage implements Serializable {
        public String businessID = TUIConstants.TUIPlugin.BUSINESS_ID_PLUGIN_GROUP_NOTE_TIPS;
    }

    private CustomGroupNoteTipsMessage customGroupNoteTipsMessage;

    private Object groupNoteTipsBeanObject;

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        String data = new String(v2TIMMessage.getCustomElem().getData());
        TUIChatLog.d("CustomGroupNoteTipsMessageBean", "data = " + data);
        if(!TextUtils.isEmpty(data)) {
            try {
                customGroupNoteTipsMessage = new Gson().fromJson(data, CustomGroupNoteTipsMessage.class);
            } catch (Exception e) {
                TUIChatLog.e("CustomGroupNoteTipsMessageBean", "exception e = " + e);
            }
        }
        if (customGroupNoteTipsMessage != null) {
            setExtra(TUIChatService.getAppContext().getString(R.string.group_note_extra));
        } else {
            String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
            setExtra(text);
        }
    }

    public CustomGroupNoteTipsMessage getCustomGroupNoteTipsMessage() {
        return customGroupNoteTipsMessage;
    }

    public Object getGroupNoteTipsBeanObject() {
        return groupNoteTipsBeanObject;
    }

    public void setGroupNoteTipsBeanObject(Object groupNoteTipsBeanObject) {
        this.groupNoteTipsBeanObject = groupNoteTipsBeanObject;
    }
}
