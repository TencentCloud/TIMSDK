package com.tencent.qcloud.tim.demo.helper;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;

import androidx.annotation.Nullable;

import com.google.gson.Gson;
import com.tencent.imsdk.v2.V2TIMCustomElem;
import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.liteav.login.ProfileManager;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.scenes.LiveRoomAnchorActivity;
import com.tencent.qcloud.tim.demo.scenes.LiveRoomAudienceActivity;
import com.tencent.qcloud.tim.demo.scenes.net.RoomManager;
import com.tencent.qcloud.tim.demo.utils.DemoLog;
import com.tencent.qcloud.tim.tuikit.live.TUIKitLive;
import com.tencent.qcloud.tim.uikit.TUIKitImpl;
import com.tencent.qcloud.tim.uikit.modules.chat.ChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore.InputMoreActionUnit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IGroupMessageClickListener;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IOnCustomMessageDrawListener;
import com.tencent.qcloud.tim.uikit.modules.message.LiveMessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

public class ChatLayoutHelper {

    private static final String TAG = ChatLayoutHelper.class.getSimpleName();

    private Context mContext;

    public ChatLayoutHelper(Context context) {
        mContext = context;
    }

    public void customizeChatLayout(final ChatLayout layout) {

//        //====== NoticeLayout使用范例 ======//
//        NoticeLayout noticeLayout = layout.getNoticeLayout();
//        noticeLayout.alwaysShow(true);
//        noticeLayout.getContent().setText("现在插播一条广告");
//        noticeLayout.getContentExtra().setText("参看有奖");
//        noticeLayout.setOnNoticeClickListener(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                ToastUtil.toastShortMessage("赏白银五千两");
//            }
//        });
//
        //====== MessageLayout使用范例 ======//
        MessageLayout messageLayout = layout.getMessageLayout();
//        ////// 设置聊天背景 //////
//        messageLayout.setBackground(new ColorDrawable(0xFFEFE5D4));
//        ////// 设置头像 //////
//        // 设置默认头像，默认与朋友与自己的头像相同
//        messageLayout.setAvatar(R.drawable.ic_more_file);
//        // 设置头像圆角
//        messageLayout.setAvatarRadius(50);
//        // 设置头像大小
//        messageLayout.setAvatarSize(new int[]{48, 48});
//
//        ////// 设置昵称样式（对方与自己的样式保持一致）//////
//        messageLayout.setNameFontSize(12);
//        messageLayout.setNameFontColor(0xFF8B5A2B);
//
//        ////// 设置气泡 ///////
//        // 设置自己聊天气泡的背景
//        messageLayout.setRightBubble(new ColorDrawable(0xFFCCE4FC));
//        // 设置朋友聊天气泡的背景
//        messageLayout.setLeftBubble(new ColorDrawable(0xFFE4E7EB));
//
//        ////// 设置聊天内容 //////
//        // 设置聊天内容字体字体大小，朋友和自己用一种字体大小
//        messageLayout.setChatContextFontSize(15);
//        // 设置自己聊天内容字体颜色
//        messageLayout.setRightChatContentFontColor(0xFFA9A9A9);
//        // 设置朋友聊天内容字体颜色
//        messageLayout.setLeftChatContentFontColor(0xFFA020F0);
//
//        ////// 设置聊天时间 //////
//        // 设置聊天时间线的背景
//        messageLayout.setChatTimeBubble(new ColorDrawable(0xFFE4E7EB));
//        // 设置聊天时间的字体大小
//        messageLayout.setChatTimeFontSize(12);
//        // 设置聊天时间的字体颜色
//        messageLayout.setChatTimeFontColor(0xFF7E848C);
//
//        ////// 设置聊天的提示信息 //////
//        // 设置提示的背景
//        messageLayout.setTipsMessageBubble(new ColorDrawable(0xFFE4E7EB));
//        // 设置提示的字体大小
//        messageLayout.setTipsMessageFontSize(12);
//        // 设置提示的字体颜色
//        messageLayout.setTipsMessageFontColor(0xFF7E848C);
//
        // 设置自定义的消息渲染时的回调
        messageLayout.setOnCustomMessageDrawListener(new CustomMessageDraw());

        // 设置点击群消息
        messageLayout.setIGroupMessageClickListener(new IGroupMessageClickListener() {

            @Override
            public boolean handleLiveMessage(LiveMessageInfo info, String groupId) {
                String selfUserId = ProfileManager.getInstance().getUserModel().userId;
                if (String.valueOf(info.anchorId).equals(selfUserId)) {
                    createRoom(groupId);
                } else {
                    checkRoomExist(info);
                }
                return true;
            }
        });
//
//        // 新增一个PopMenuAction
//        PopMenuAction action = new PopMenuAction();
//        action.setActionName("test");
//        action.setActionClickListener(new PopActionClickListener() {
//            @Override
//            public void onActionClick(int position, Object data) {
//                ToastUtil.toastShortMessage("新增一个pop action");
//            }
//        });
//        messageLayout.addPopAction(action);
//
//        final MessageLayout.OnItemClickListener l = messageLayout.getOnItemClickListener();
//        messageLayout.setOnItemClickListener(new MessageLayout.OnItemClickListener() {
//            @Override
//            public void onMessageLongClick(View view, int position, MessageInfo messageInfo) {
//                l.onMessageLongClick(view, position, messageInfo);
//                ToastUtil.toastShortMessage("demo中自定义长按item");
//            }
//
//            @Override
//            public void onUserIconClick(View view, int position, MessageInfo messageInfo) {
//                l.onUserIconClick(view, position, messageInfo);
//                ToastUtil.toastShortMessage("demo中自定义点击头像");
//            }
//        });


        //====== InputLayout使用范例 ======//
        final InputLayout inputLayout = layout.getInputLayout();

//        // TODO 隐藏音频输入的入口，可以打开下面代码测试
//        inputLayout.disableAudioInput(true);
//        // TODO 隐藏表情输入的入口，可以打开下面代码测试
//        inputLayout.disableEmojiInput(true);
//        // TODO 隐藏更多功能的入口，可以打开下面代码测试
//        inputLayout.disableMoreInput(true);
//        // TODO 可以用自定义的事件来替换更多功能的入口，可以打开下面代码测试
//        inputLayout.replaceMoreInput(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                ToastUtil.toastShortMessage("自定义的更多功能按钮事件");
//                MessageInfo info = MessageInfoUtil.buildTextMessage("自定义的消息");
//                layout.sendMessage(info, false);
//            }
//        });
//        // TODO 可以用自定义的fragment来替换更多功能，可以打开下面代码测试
//        inputLayout.replaceMoreInput(new CustomInputFragment().setChatLayout(layout));
//
//        // TODO 可以disable更多面板上的各个功能，可以打开下面代码测试
//        inputLayout.disableCaptureAction(true);
//        inputLayout.disableSendFileAction(true);
//        inputLayout.disableSendPhotoAction(true);
//        inputLayout.disableVideoRecordAction(true);
        inputLayout.enableAudioCall();
        inputLayout.enableVideoCall();

        // TODO 可以自己增加一些功能，可以打开下面代码测试
        // 增加一个欢迎提示富文本
        InputMoreActionUnit unit = new InputMoreActionUnit();
        unit.setIconResId(R.drawable.custom);
        unit.setTitleId(R.string.test_custom_action);
        unit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Gson gson = new Gson();
                CustomHelloMessage customHelloMessage = new CustomHelloMessage();
                customHelloMessage.version = TUIKitConstants.version;
                customHelloMessage.text = "欢迎加入云通信IM大家庭！";
                customHelloMessage.link = "https://cloud.tencent.com/document/product/269/3794";

                String data = gson.toJson(customHelloMessage);
                MessageInfo info = MessageInfoUtil.buildCustomMessage(data);
                layout.sendMessage(info, false);
            }
        });
        inputLayout.addAction(unit);
    }

    public static class CustomInputFragment extends BaseInputFragment {
        @Nullable
        @Override
        public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
            View baseView = inflater.inflate(R.layout.test_chat_input_custom_fragment, container, false);
            Button btn1 = baseView.findViewById(R.id.test_send_message_btn1);
            btn1.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ToastUtil.toastShortMessage("自定义的按钮1");
                    if (getChatLayout() != null) {
                        Gson gson = new Gson();
                        CustomHelloMessage customHelloMessage = new CustomHelloMessage();
                        String data = gson.toJson(customHelloMessage);
                        MessageInfo info = MessageInfoUtil.buildCustomMessage(data);
                        getChatLayout().sendMessage(info, false);
                    }
                }
            });
            Button btn2 = baseView.findViewById(R.id.test_send_message_btn2);
            btn2.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    ToastUtil.toastShortMessage("自定义的按钮2");
                    if (getChatLayout() != null) {
                        Gson gson = new Gson();
                        CustomHelloMessage customHelloMessage = new CustomHelloMessage();
                        String data = gson.toJson(customHelloMessage);
                        MessageInfo info = MessageInfoUtil.buildCustomMessage(data);
                        getChatLayout().sendMessage(info, false);
                    }
                }
            });
            return baseView;
        }

    }

    public class CustomMessageDraw implements IOnCustomMessageDrawListener {

        /**
         * 自定义消息渲染时，会调用该方法，本方法实现了自定义消息的创建，以及交互逻辑
         *
         * @param parent 自定义消息显示的父View，需要把创建的自定义消息view添加到parent里
         * @param info   消息的具体信息
         */
        @Override
        public void onDraw(ICustomMessageViewGroup parent, MessageInfo info) {
            // 获取到自定义消息的json数据
            if (info.getTimMessage().getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_CUSTOM) {
                return;
            }
            V2TIMCustomElem elem = info.getTimMessage().getCustomElem();
            // 自定义的json数据，需要解析成bean实例
            CustomHelloMessage data = null;
            try {
                data = new Gson().fromJson(new String(elem.getData()), CustomHelloMessage.class);
            } catch (Exception e) {
                DemoLog.w(TAG, "invalid json: " + new String(elem.getData()) + " " + e.getMessage());
            }
            if (data == null) {
                DemoLog.e(TAG, "No Custom Data: " + new String(elem.getData()));
            } else if (data.version == TUIKitConstants.JSON_VERSION_1
                    || (data.version == TUIKitConstants.JSON_VERSION_4 && data.businessID.equals("text_link"))) {
                CustomHelloTIMUIController.onDraw(parent, data);
            } else {
                DemoLog.w(TAG, "unsupported version: " + data);
            }
        }
    }

    private static void checkRoomExist(final LiveMessageInfo info) {
        RoomManager.getInstance().checkRoomExist(RoomManager.TYPE_GROUP_LIVE, info.roomId, new RoomManager.ActionCallback() {
            @Override
            public void onSuccess() {
                enterRoom(info);
            }

            @Override
            public void onFailed(int code, String msg) {
                ToastUtil.toastShortMessage(TUIKitLive.getAppContext().getString(R.string.live_is_over));
            }
        });
    }

    private static void createRoom(String groupId) {
        LiveRoomAnchorActivity.start(TUIKitImpl.getAppContext(), groupId);
    }

    private static void enterRoom(LiveMessageInfo info) {
        Intent intent = new Intent(TUIKitImpl.getAppContext(), LiveRoomAudienceActivity.class);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        intent.putExtra(RoomManager.ROOM_TITLE, info.roomName);
        intent.putExtra(RoomManager.GROUP_ID, info.roomId);
        intent.putExtra(RoomManager.USE_CDN_PLAY, false);
        intent.putExtra(RoomManager.ANCHOR_ID, info.anchorId);
        intent.putExtra(RoomManager.PUSHER_NAME, info.anchorName);
        intent.putExtra(RoomManager.COVER_PIC, info.roomCover);
        intent.putExtra(RoomManager.PUSHER_AVATAR, info.roomCover);
        TUIKitImpl.getAppContext().startActivity(intent);
    }
}
