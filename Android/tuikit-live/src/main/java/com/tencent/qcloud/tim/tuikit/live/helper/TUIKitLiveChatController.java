package com.tencent.qcloud.tim.tuikit.live.helper;

import android.content.Context;
import android.content.Intent;
import android.text.Html;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMConversation;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.liteav.SelectContactActivity;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.liteav.login.UserModel;
import com.tencent.liteav.model.ITRTCAVCall;
import com.tencent.liteav.ui.TRTCAudioCallActivity;
import com.tencent.liteav.ui.TRTCVideoCallActivity;
import com.tencent.qcloud.tim.tuikit.live.R;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.tuikit.live.utils.TUILiveLog;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.base.TUIChatControllerListener;
import com.tencent.qcloud.tim.uikit.base.IBaseAction;
import com.tencent.qcloud.tim.uikit.base.IBaseInfo;
import com.tencent.qcloud.tim.uikit.base.IBaseViewHolder;
import com.tencent.qcloud.tim.uikit.base.TUIConversationControllerListener;
import com.tencent.qcloud.tim.uikit.modules.chat.base.InputMoreActionUnit;
import com.tencent.liteav.model.CallModel;
import com.tencent.liteav.model.LiveMessageInfo;
import com.tencent.liteav.model.LiveModel;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageCustomHolder;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.MessageTipsHolder;
import com.tencent.qcloud.tim.uikit.modules.message.MessageCustom;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.DateTimeUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

public class TUIKitLiveChatController implements TUIChatControllerListener {
    public static final String TAG = TUIKitLiveChatController.class.getSimpleName();
    public static final String BUSINESS_ID_AV_CALL = "av_call";

    private boolean enableVideoCall = true;
    private boolean enableAudioCall = true;
    private boolean enableGroupLiveEntry = true;

    public interface GroupLiveHandler {
        boolean startGroupLive(String groupId);
    }

    private static GroupLiveHandler groupLiveHandler;

    public static void setGroupLiveHandler(GroupLiveHandler outsideGroupLiveHandler) {
        groupLiveHandler = outsideGroupLiveHandler;
    }

    private static LiveGroupMessageClickListener liveGroupMessageClickListener;

    public static void setLiveGroupMessageClickListener(LiveGroupMessageClickListener clickListener) {
        liveGroupMessageClickListener = clickListener;
    }

    @Override
    public List<IBaseAction> onRegisterMoreActions() {
        List<IBaseAction> actionList = new ArrayList<>();
        if (enableVideoCall) {
            InputMoreActionUnit videoCallAction = createInputMoreAction(InputMoreActionType.TYPE_VIDEO_CALL, R.string.video_call,
                    R.drawable.ic_more_video_call);
            actionList.add(videoCallAction);
        }
        if (enableAudioCall) {
            InputMoreActionUnit audioCallAction = createInputMoreAction(InputMoreActionType.TYPE_AUDIO_CALL, R.string.audio_call,
                    R.drawable.ic_more_audio_call);
            actionList.add(audioCallAction);
        }
        if (enableGroupLiveEntry) {
            InputMoreActionUnit groupLiveAction = createInputMoreAction(InputMoreActionType.TYPE_GROUP_LIVE, R.string.live_group_live,
                    R.drawable.ic_more_group_live);
            actionList.add(groupLiveAction);
        }
        return actionList;
    }

    private InputMoreActionUnit createInputMoreAction(final int actionId, final int titleId, final int resId) {
        InputMoreActionUnit action = new InputMoreActionUnit() {
            @Override
            public void onAction(String chatInfoId, int chatType) {
                onInputMoreActionClick(getActionId(), chatInfoId, chatType);
            }

            @Override
            public boolean isEnable(int chatType) {
                // C2C 聊天时群直播 Action 不显示
                if (chatType == V2TIMConversation.V2TIM_C2C
                        && getActionId() == InputMoreActionType.TYPE_GROUP_LIVE) {
                    return false;
                }
                return true;
            }
        };
        action.setActionId(actionId);
        action.setTitleId(titleId);
        action.setIconResId(resId);
        return action;
    }

    private void onInputMoreActionClick(final int actionId, String chatInfoId, int chatType) {
        if (chatType == V2TIMConversation.V2TIM_C2C) {
            ProfileManager.getInstance().getUserInfoByUserId(chatInfoId, new ProfileManager.GetUserInfoCallback() {
                @Override
                public void onSuccess(UserModel model) {
                    List<UserModel> list = new ArrayList<>();
                    list.add(model);
                    startC2CCall(actionId, list);
                }

                @Override
                public void onFailed(int code, String msg) {
                    TUILiveLog.e(TAG, "onInputMoreActionClick error " + msg + " actionId : " + actionId);
                }
            });
        } else {
            startGroupCall(actionId, chatInfoId);
        }
    }

    @Override
    public IBaseInfo createCommonInfoFromTimMessage(V2TIMMessage timMessage) {
        Context context = TUIKitLive.getAppContext();
        if (context == null) {
            TUILiveLog.e(TAG, "createCommonInfoFromTimMessage : context is null");
            return null;
        }
        boolean isGroup = !TextUtils.isEmpty(timMessage.getGroupID());

        MessageInfo msgInfo = new TUIKitLiveMessageInfo();
        msgInfo.setMsgType(TUIKitLiveMessageInfo.MSG_TYPE_TUIKIT_LIVE);
        MessageInfoUtil.setMessageInfoCommonAttributes(msgInfo, timMessage);

        V2TIMCustomElem customElem = timMessage.getCustomElem();
        if (customElem == null || customElem.getData() == null) {
            return null;
        }
        String data = new String(customElem.getData());
        TUIKitLog.i(TAG, "custom data:" + data);
        String content = context.getString(R.string.custom_msg);
        msgInfo.setExtra(content);
        Gson gson = new Gson();
        MessageCustom messageCustom = null;
        try {
            messageCustom = gson.fromJson(data, MessageCustom.class);

            if (!TextUtils.isEmpty(messageCustom.businessID) && messageCustom.businessID.equals(LiveMessageInfo.BUSINESS_ID_LIVE_GROUP)) {
                Gson liveGson = new Gson();
                LiveMessageInfo liveMessageInfo = liveGson.fromJson(data, LiveMessageInfo.class);
                String anchorName;
                if (!TextUtils.isEmpty(liveMessageInfo.anchorName)) {
                    anchorName = liveMessageInfo.anchorName;
                } else if (!TextUtils.isEmpty(liveMessageInfo.anchorId)){
                    anchorName = liveMessageInfo.anchorId;
                } else {
                    anchorName = liveMessageInfo.roomName;
                }
                content = "[" + anchorName + TUIKit.getAppContext().getString(R.string.live_room) + "]";
                msgInfo.setExtra(content);
                return msgInfo;
            } else if (LiveModel.isLiveRoomSignal(messageCustom.data)) {
                LiveModel liveModel = LiveModel.convert2LiveData(timMessage);
                content = liveModel.message;
                msgInfo.setMsgType(MessageInfo.MSG_TYPE_TEXT);
                msgInfo.setExtra(content);
                return msgInfo;
            } else {
                CallModel callModel = CallModel.convert2VideoCallData(timMessage);
                if (callModel == null) {
                    return null;
                }
                String senderShowName = timMessage.getSender();
                if (!TextUtils.isEmpty(timMessage.getNameCard())) {
                    senderShowName = timMessage.getNameCard();
                } else if (!TextUtils.isEmpty(timMessage.getFriendRemark())) {
                    senderShowName = timMessage.getFriendRemark();
                } else if (!TextUtils.isEmpty(timMessage.getNickName())) {
                    senderShowName = timMessage.getNickName();
                }
                switch (callModel.action) {
                    case CallModel.VIDEO_CALL_ACTION_DIALING:
                        content = isGroup ? ("\"" + senderShowName + "\"" +
                                context.getString(R.string.start_group_call)) : (context.getString(R.string.start_call));
                        break;
                    case CallModel.VIDEO_CALL_ACTION_SPONSOR_CANCEL:
                        content = isGroup ? context.getString(R.string.cancle_group_call) : context.getString(R.string.cancle_call);
                        break;
                    case CallModel.VIDEO_CALL_ACTION_LINE_BUSY:
                        content = isGroup ? ("\"" + senderShowName + "\"" +
                                context.getString(R.string.line_busy)) : context.getString(R.string.other_line_busy);
                        break;
                    case CallModel.VIDEO_CALL_ACTION_REJECT:
                        content = isGroup ? ("\"" + senderShowName + "\"" +
                                context.getString(R.string.reject_group_calls)) : context.getString(R.string.reject_calls);
                        break;
                    case CallModel.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT:
                        if (isGroup && callModel.invitedList != null && callModel.invitedList.size() == 1
                                && callModel.invitedList.get(0).equals(timMessage.getSender())) {
                            content = "\"" + senderShowName + "\"" + context.getString(R.string.no_response_call);
                        } else {
                            StringBuilder inviteeShowStringBuilder = new StringBuilder();
                            if (callModel.invitedList != null && callModel.invitedList.size() > 0) {
                                for (String invitee : callModel.invitedList) {
                                    inviteeShowStringBuilder.append(invitee).append("、");
                                }
                                if (inviteeShowStringBuilder.length() > 0) {
                                    inviteeShowStringBuilder.delete(inviteeShowStringBuilder.length() - 1, inviteeShowStringBuilder.length());
                                }
                            }
                            content = isGroup ? ("\"" + inviteeShowStringBuilder.toString() + "\""
                                    + context.getString(R.string.no_response_call)) : context.getString(R.string.no_response_call);
                        }
                        break;
                    case CallModel.VIDEO_CALL_ACTION_ACCEPT:
                        content = isGroup ? ("\"" + senderShowName + "\"" +
                                context.getString(R.string.accept_call)) : context.getString(R.string.accept_call);
                        break;
                    case CallModel.VIDEO_CALL_ACTION_HANGUP:
                        content = isGroup ? context.getString(R.string.stop_group_call) :
                                context.getString(R.string.stop_call_tip) + DateTimeUtil.formatSecondsTo00(callModel.duration);
                        break;
                    default:
                        content = context.getString(R.string.invalid_command);
                        break;
                }
                if (isGroup) {
                    msgInfo.setMsgType(TUIKitLiveMessageInfo.MSG_TYPE_GROUP_AV_CALL_NOTICE);
                } else {
                    msgInfo.setMsgType(MessageInfo.MSG_TYPE_TEXT);
                }
                msgInfo.setExtra(content);
                return msgInfo;
            }

        } catch (Exception e) {
            TUIKitLog.e(TAG, "invalid json: " + data + ", exception:" + e);
        }
        return null;
    }

    @Override
    public IBaseViewHolder createCommonViewHolder(ViewGroup parent, int viewType) {
        if (viewType != TUIKitLiveMessageInfo.MSG_TYPE_TUIKIT_LIVE && viewType != TUIKitLiveMessageInfo.MSG_TYPE_GROUP_AV_CALL_NOTICE) {
            return null;
        }
        if (parent == null) {
            return null;
        }
        LayoutInflater inflater = LayoutInflater.from(TUIKit.getAppContext());
        View contentView;
        if (viewType == TUIKitLiveMessageInfo.MSG_TYPE_TUIKIT_LIVE) {
            contentView = inflater.inflate(R.layout.message_adapter_item_content, parent, false);
            return new TUIKitLiveViewHolder(contentView);
        } else {
            contentView = inflater.inflate(com.tencent.qcloud.tim.uikit.R.layout.message_adapter_item_empty, parent, false);
            return new TUIKitLiveTipsViewHolder(contentView);
        }
    }

    private static void startC2CCall(int actionId, List<UserModel> userModels) {
        if (actionId == InputMoreActionType.TYPE_VIDEO_CALL) {
            TRTCVideoCallActivity.startCallSomeone(TUIKitLive.getAppContext(), userModels);
        } else if (actionId == InputMoreActionType.TYPE_AUDIO_CALL) {
            TRTCAudioCallActivity.startCallSomeone(TUIKitLive.getAppContext(), userModels);
        } else {
            TUILiveLog.i(TAG, "startC2CCall failed unknown actionId : " + actionId);
        }
    }

    private static void startGroupCall(int actionId, String groupId) {
        if (actionId == InputMoreActionType.TYPE_VIDEO_CALL) {
            SelectContactActivity.start(TUIKitLive.getAppContext(), groupId, ITRTCAVCall.TYPE_VIDEO_CALL);
        } else if (actionId == InputMoreActionType.TYPE_AUDIO_CALL) {
            SelectContactActivity.start(TUIKitLive.getAppContext(), groupId, ITRTCAVCall.TYPE_AUDIO_CALL);
        } else if (actionId == InputMoreActionType.TYPE_GROUP_LIVE) {
            if (groupLiveHandler != null) {
                if (groupLiveHandler.startGroupLive(groupId)) {
                    return;
                }
            }
            startDefaultGroupLiveAnchor(groupId);
        } else {
            TUILiveLog.i(TAG, "startGroupCall failed unknown actionId : " + actionId);
        }
    }

    private static void startDefaultGroupLiveAnchor(String groupId) {
        Intent intent = new Intent();
        intent.setAction("com.tencent.qcloud.tim.tuikit.live.grouplive.anchor");
        intent.addCategory("android.intent.category.DEFAULT");
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra("group_id", groupId);
        TUIKitLive.getAppContext().startActivity(intent);
    }

    @Override
    public boolean bindCommonViewHolder(IBaseViewHolder baseViewHolder, IBaseInfo baseInfo, int position) {
        if (baseInfo instanceof TUIKitLiveMessageInfo) {
            TUIKitLiveMessageInfo msg = (TUIKitLiveMessageInfo) baseInfo;
            if (baseViewHolder instanceof TUIKitLiveViewHolder) {
                ICustomMessageViewGroup customHolder = (ICustomMessageViewGroup) baseViewHolder;
                if (isLive(msg)) {
                    new TUIKitLiveGroupMessageHelper(liveGroupMessageClickListener).onDraw(customHolder, msg, position);
                    return true;
                }
            }
        }
        return false;
    }


    public static boolean isLive(MessageInfo messageInfo) {
        try {
            JSONObject jsonObject = new JSONObject(new String(messageInfo.getTimMessage().getCustomElem().getData()));
            return jsonObject.getString("roomType") != null;
        } catch (JSONException e) {
            e.printStackTrace();
            return false;
        }
    }

    static class TUIKitLiveMessageInfo extends MessageInfo {
        public static final int MSG_TYPE_TUIKIT_LIVE = 100000;
        /**
         * 群音视频呼叫提示消息
         */
        public static final int MSG_TYPE_GROUP_AV_CALL_NOTICE = 100001;
    }

    static class TUIKitLiveViewHolder extends MessageCustomHolder {
        public TUIKitLiveViewHolder(View itemView) {
            super(itemView);
        }
    }

    static class TUIKitLiveTipsViewHolder extends MessageTipsHolder {
        public TUIKitLiveTipsViewHolder(View itemView) {
            super(itemView);
        }

        @Override
        public void layoutViews(MessageInfo msg, int position) {
            super.layoutViews(msg, position);
            if (mChatTipsTv != null) {
                mChatTipsTv.setText(Html.fromHtml(msg.getExtra().toString()));
            }
        }
    }

    public static class TUIKitLiveConversationController implements TUIConversationControllerListener {

        @Override
        public CharSequence getConversationDisplayString(IBaseInfo baseInfo) {
            if (baseInfo instanceof TUIKitLiveChatController.TUIKitLiveMessageInfo) {
                return (CharSequence) ((TUIKitLiveChatController.TUIKitLiveMessageInfo) baseInfo).getExtra();
            }
            return null;
        }
    }

    public static final class InputMoreActionType {
        public static final int TYPE_AUDIO_CALL = 1; // "AudioCall"
        public static final int TYPE_VIDEO_CALL = 2; // "VideoCall"
        public static final int TYPE_GROUP_LIVE = 3; // "GroupLive"
    }
}
