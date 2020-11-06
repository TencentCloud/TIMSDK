package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.content.Intent;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.TextView;

import androidx.annotation.StringRes;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.message.LiveMessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;

public class GroupMessageHelper implements IOnCustomMessageDrawListener {
    public static final String ROOM_TITLE    = "room_title";
    public static final String GROUP_ID      = "group_id";
    public static final String USE_CDN_PLAY  = "use_cdn_play";
    public static final String ANCHOR_ID     = "anchor_id";
    public static final String PUSHER_NAME   = "pusher_name";
    public static final String COVER_PIC     = "cover_pic";
    public static final String PUSHER_AVATAR = "pusher_avatar";

    private IGroupMessageClickListener mIGroupMessageClickListener;

    public GroupMessageHelper(IGroupMessageClickListener IGroupMessageClickListener) {
        mIGroupMessageClickListener = IGroupMessageClickListener;
    }

    @Override
    public void onDraw(ICustomMessageViewGroup parent, final MessageInfo messageInfo) {
        // 获取到自定义消息的json数据
        if (messageInfo.getTimMessage().getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            return;
        }
        V2TIMCustomElem elem = messageInfo.getTimMessage().getCustomElem();
        final LiveMessageInfo info = new Gson().fromJson(new String(elem.getData()), LiveMessageInfo.class);

        // 把自定义消息view添加到TUIKit内部的父容器里
        View view = LayoutInflater.from(TUIKit.getAppContext()).inflate(R.layout.message_adapter_content_trtc, null, false);
        parent.addMessageContentView(view);

        TextView textLiveName = view.findViewById(R.id.msg_tv_live_name);
        TextView textStatus = view.findViewById(R.id.msg_tv_live_status);

        if (info != null) {
            if (!TextUtils.isEmpty(info.anchorName)) {
                textLiveName.setText(TUIKit.getAppContext().getString(R.string.live_group_user_live, info.anchorName));
            } else {
                textLiveName.setText(info.roomName);
            }
            textStatus.setText(info.roomStatus == 1 ? getString(R.string.live_group_live_streaming) : getString(R.string.live_group_live_end));
        }
        view.setClickable(true);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mIGroupMessageClickListener != null) {
                    boolean isHandleByUser = mIGroupMessageClickListener.handleLiveMessage(info, messageInfo.isGroup() ? messageInfo.getTimMessage().getGroupID() : "");
                    if (!isHandleByUser) {
                        startDefaultGroupLiveAudience(info);
                    }
                } else {
                    startDefaultGroupLiveAudience(info);
                }
            }
        });
    }

    private void startDefaultGroupLiveAudience(LiveMessageInfo info) {
        Intent intent = new Intent();
        intent.setAction("com.tencent.qcloud.tim.tuikit.live.grouplive.audience");
        intent.addCategory("android.intent.category.DEFAULT");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(ROOM_TITLE, info.roomName);
        intent.putExtra(GROUP_ID, info.roomId);
        intent.putExtra(USE_CDN_PLAY, false);
        intent.putExtra(ANCHOR_ID, info.anchorId);
        intent.putExtra(PUSHER_NAME, info.anchorName);
        intent.putExtra(COVER_PIC, info.roomCover);
        intent.putExtra(PUSHER_AVATAR, info.roomCover);
        TUIKit.getAppContext().startActivity(intent);
    }

    private String getString(@StringRes int stringId) {
        return TUIKit.getAppContext().getString(stringId);
    }
}
