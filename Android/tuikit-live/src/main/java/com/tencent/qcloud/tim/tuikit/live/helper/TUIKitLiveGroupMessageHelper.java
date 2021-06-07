package com.tencent.qcloud.tim.tuikit.live.helper;

import android.content.Intent;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.StringRes;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.liteav.model.LiveMessageInfo;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IOnCustomMessageDrawListener;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageContentHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageCustomHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.ScreenUtil;

public class TUIKitLiveGroupMessageHelper implements IOnCustomMessageDrawListener {
    public static final String ROOM_TITLE    = "room_title";
    public static final String GROUP_ID      = "group_id";
    public static final String USE_CDN_PLAY  = "use_cdn_play";
    public static final String ANCHOR_ID     = "anchor_id";
    public static final String PUSHER_NAME   = "pusher_name";
    public static final String COVER_PIC     = "cover_pic";
    public static final String PUSHER_AVATAR = "pusher_avatar";

    private LiveGroupMessageClickListener mLiveGroupMessageClickListener;

    public TUIKitLiveGroupMessageHelper(LiveGroupMessageClickListener LiveGroupMessageClickListener) {
        mLiveGroupMessageClickListener = LiveGroupMessageClickListener;
    }

    @Override
    public void onDraw(final ICustomMessageViewGroup parent, final MessageInfo messageInfo, final int position) {
        // 获取到自定义消息的json数据
        if (messageInfo.getTimMessage().getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
            return;
        }

        if (parent instanceof MessageContentHolder) {
            MessageContentHolder customHolder = (MessageContentHolder) parent;
            ViewGroup.LayoutParams msgContentLinearParams = customHolder.msgContentLinear.getLayoutParams();
            msgContentLinearParams.width = ViewGroup.LayoutParams.WRAP_CONTENT;
            customHolder.msgContentLinear.setLayoutParams(msgContentLinearParams);

            LinearLayout.LayoutParams msgContentFrameParams = (LinearLayout.LayoutParams) customHolder.msgContentFrame.getLayoutParams();
            msgContentFrameParams.width = ScreenUtil.dip2px(220);
            msgContentFrameParams.gravity = Gravity.RIGHT | Gravity.END;
            customHolder.msgContentFrame.setLayoutParams(msgContentFrameParams);
            if (messageInfo.isSelf()) {
                customHolder.msgContentFrame.setBackgroundResource(R.drawable.chat_right_live_group_bg);
            } else {
                customHolder.msgContentFrame.setBackgroundResource(R.drawable.chat_left_live_group_bg);
            }
            // 群直播消息不显示已读状态
            customHolder.isReadText.setVisibility(View.INVISIBLE);
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
            } else if (!TextUtils.isEmpty(info.anchorId)) {
                textLiveName.setText(TUIKit.getAppContext().getString(R.string.live_group_user_live, info.anchorId));
            } else {
                textLiveName.setText(info.roomName);
            }
            textStatus.setText(info.roomStatus == 1 ? getString(R.string.live_group_live_streaming) : getString(R.string.live_group_live_end));
        }
        view.setClickable(true);
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLiveGroupMessageClickListener != null) {
                    boolean isHandleByUser = mLiveGroupMessageClickListener.handleLiveMessage(info, messageInfo.isGroup() ? messageInfo.getTimMessage().getGroupID() : "");
                    if (!isHandleByUser) {
                        startDefaultGroupLiveAudience(info);
                    }
                } else {
                    startDefaultGroupLiveAudience(info);
                }
            }
        });

        view.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (parent instanceof MessageCustomHolder) {
                    MessageLayout.OnItemLongClickListener onItemLongClickListener = ((MessageCustomHolder) parent).getOnItemClickListener();
                    if (onItemLongClickListener != null){
                        onItemLongClickListener.onMessageLongClick(v, position, messageInfo);
                    }
                }
                return false;
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
