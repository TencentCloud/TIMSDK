package com.tencent.qcloud.tim.demo.helper;

import android.content.Context;
import android.content.Intent;
import android.graphics.drawable.ColorDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import com.google.gson.Gson;
import com.tencent.imsdk.TIMCustomElem;
import com.tencent.qcloud.tim.demo.DemoApplication;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.uikit.component.NoticeLayout;
import com.tencent.qcloud.tim.uikit.component.action.PopActionClickListener;
import com.tencent.qcloud.tim.uikit.component.action.PopMenuAction;
import com.tencent.qcloud.tim.uikit.modules.chat.ChatLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.base.BaseInputFragment;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.input.InputLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.inputmore.InputMoreActionUnit;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.MessageLayout;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.ICustomMessageViewGroup;
import com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder.IOnCustomMessageDrawListener;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfoUtil;
import com.tencent.qcloud.tim.uikit.utils.ToastUtil;

public class ChatLayoutHelper {

    public static void customizeChatLayout(final Context context, final ChatLayout layout) {

        //====== NoticeLayout使用范例 ======//
        NoticeLayout noticeLayout = layout.getNoticeLayout();
        noticeLayout.alwaysShow(true);
        noticeLayout.getContent().setText("现在插播一条广告");
        noticeLayout.getContentExtra().setText("参看有奖");
        noticeLayout.setOnNoticeClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ToastUtil.toastShortMessage("赏白银五千两");
            }
        });

        //====== MessageLayout使用范例 ======//
        MessageLayout messageLayout = layout.getMessageLayout();
        ////// 设置聊天背景 //////
        messageLayout.setBackground(new ColorDrawable(0xB0E2FF00));
        ////// 设置头像 //////
        // 设置默认头像，默认与朋友与自己的头像相同
        messageLayout.setAvatar(R.drawable.ic_more_file);
        // 设置头像圆角
        messageLayout.setAvatarRadius(50);
        // 设置头像大小
        messageLayout.setAvatarSize(new int[]{48, 48});

        ////// 设置昵称样式（对方与自己的样式保持一致）//////
        messageLayout.setNameFontSize(12);
        messageLayout.setNameFontColor(0x8B5A2B00);

        ////// 设置气泡 ///////
        // 设置自己聊天气泡的背景
//        messageLayout.setRightBubble(context.getResources().getDrawable(R.drawable.chat_opposite_bg));
        // 设置朋友聊天气泡的背景
//        messageLayout.setLeftBubble(context.getResources().getDrawable(R.drawable.chat_self_bg));

        ////// 设置聊天内容 //////
        // 设置聊天内容字体字体大小，朋友和自己用一种字体大小
        messageLayout.setChatContextFontSize(15);
        // 设置自己聊天内容字体颜色
        messageLayout.setRightChatContentFontColor(0xA9A9A900);
        // 设置朋友聊天内容字体颜色
        messageLayout.setLeftChatContentFontColor(0xA020F000);

        ////// 设置聊天时间 //////
        // 设置聊天时间线的背景
        messageLayout.setChatTimeBubble(new ColorDrawable(0x8B691400));
        // 设置聊天时间的字体大小
        messageLayout.setChatTimeFontSize(20);
        // 设置聊天时间的字体颜色
        messageLayout.setChatTimeFontColor(0xEE00EE00);

        ////// 设置聊天的提示信息 //////
        // 设置提示的背景
        messageLayout.setTipsMessageBubble(new ColorDrawable(0xA020F000));
        // 设置提示的字体大小
        messageLayout.setTipsMessageFontSize(20);
        // 设置提示的字体颜色
        messageLayout.setTipsMessageFontColor(0x7CFC0000);

        // 设置自定义的消息渲染时的回调
        messageLayout.setOnCustomMessageDrawListener(new CustomMessageDraw());

        // 新增一个PopMenuAction
        PopMenuAction action = new PopMenuAction();
        action.setActionName("test");
        action.setActionClickListener(new PopActionClickListener() {
            @Override
            public void onActionClick(int position, Object data) {
                ToastUtil.toastShortMessage("新增一个pop action");
            }
        });
        messageLayout.addPopAction(action);

        final MessageLayout.OnItemClickListener l = messageLayout.getOnItemClickListener();
        messageLayout.setOnItemClickListener(new MessageLayout.OnItemClickListener() {
            @Override
            public void onMessageLongClick(View view, int position, MessageInfo messageInfo) {
                l.onMessageLongClick(view, position, messageInfo);
                ToastUtil.toastShortMessage("demo中自定义长按item");
            }

            @Override
            public void onUserIconClick(View view, int position, MessageInfo messageInfo) {
                l.onUserIconClick(view, position, messageInfo);
                ToastUtil.toastShortMessage("demo中自定义点击头像");
            }
        });


        //====== InputLayout使用范例 ======//
        InputLayout inputLayout = layout.getInputLayout();

        // TODO 隐藏音频输入的入口，可以打开下面代码测试
//        inputLayout.disableAudioInput(true);
        // TODO 隐藏表情输入的入口，可以打开下面代码测试
//        inputLayout.disableEmojiInput(true);
        // TODO 隐藏更多功能的入口，可以打开下面代码测试
//        inputLayout.disableMoreInput(true);
        // TODO 可以用自定义的事件来替换更多功能的入口，可以打开下面代码测试
//        inputLayout.replaceMoreInput(new View.OnClickListener() {
//            @Override
//            public void onClick(View v) {
//                ToastUtil.toastShortMessage("自定义的更多功能按钮事件");
//                MessageInfo info = MessageInfoUtil.buildTextMessage("自定义的消息");
//                container.sendMessage(info, false);
//            }
//        });
        // TODO 可以用自定义的fragment来替换更多功能，可以打开下面代码测试
        inputLayout.replaceMoreInput(new CustomInputFragment().setChatLayout(layout));

        // TODO 可以disable更多面板上的各个功能，可以打开下面代码测试
//        inputLayout.disableCaptureAction(true);
//        inputLayout.disableSendFileAction(true);
//        inputLayout.disableSendPhotoAction(true);
//        inputLayout.disableVideoRecordAction(true);
        // TODO 可以自己增加一些功能，可以打开下面代码测试
        InputMoreActionUnit unit = new InputMoreActionUnit();
        unit.setIconResId(R.drawable.default_user_icon);
        unit.setTitleId(R.string.profile);
        unit.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ToastUtil.toastShortMessage("自定义的更多功能");
                MessageInfo info = MessageInfoUtil.buildTextMessage("我是谁");
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
                    if (getChatLayout() != null) {
                        Gson gson = new Gson();
                        CustomMessageData customMessageData = new CustomMessageData();
                        String data = gson.toJson(customMessageData);
                        MessageInfo info = MessageInfoUtil.buildCustomMessage(data);
                        getChatLayout().sendMessage(info, false);
                    }
                }
            });
            Button btn2 = baseView.findViewById(R.id.test_send_message_btn2);
            btn2.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if (getChatLayout() != null) {
                        Gson gson = new Gson();
                        CustomMessageData customMessageData = new CustomMessageData();
                        customMessageData.type = CustomMessageData.TYPE_PUSH_TEXT_VIDEO;
                        String data = gson.toJson(customMessageData);
                        MessageInfo info = MessageInfoUtil.buildCustomMessage(data);
                        getChatLayout().sendMessage(info, false);
                    }
                }
            });
            return baseView;
        }

    }

    /**
     * 自定义消息的bean实体，用来与json的相互转化
     */
    public static class CustomMessageData {
        // 超文本类型，点击可以跳转到一个webview
        final static int TYPE_HYPERLINK = 1;
        // 视频+说明类型
        final static int TYPE_PUSH_TEXT_VIDEO = 2;
        // 自定义消息类型，根据业务可能会有很多种
        int type = TYPE_HYPERLINK;
        String text = "这是一个测试消息，可点击查看";
        String url = "https://cloud.tencent.com/document/product/269";
    }

    public static class CustomMessageDraw implements IOnCustomMessageDrawListener {

        /**
         * 自定义消息渲染时，会调用该方法，本方法实现了自定义消息的创建，以及交互逻辑
         * @param parent 自定义消息显示的父View，需要把创建的自定义消息view添加到parent里
         * @param info 消息的具体信息
         */
        @Override
        public void onDraw(ICustomMessageViewGroup parent, MessageInfo info) {
            View view = null;
            // 获取到自定义消息的json数据
            TIMCustomElem elem = (TIMCustomElem) info.getTIMMessage().getElement(0);
            // 自定义的json数据，需要解析成bean实例
            final CustomMessageData customMessageData = new Gson().fromJson(new String(elem.getData()), CustomMessageData.class);
            // 通过类型来创建不同的自定义消息展示view
            switch(customMessageData.type) {
                case CustomMessageData.TYPE_HYPERLINK:
                    view = LayoutInflater.from(DemoApplication.instance()).inflate(R.layout.test_custom_message_layout1, null, false);
                    // 把自定义消息view添加到TUIKit内部的父容器里
                    parent.addMessageContentView(view);
                    break;
                case CustomMessageData.TYPE_PUSH_TEXT_VIDEO:
                    view = LayoutInflater.from(DemoApplication.instance()).inflate(R.layout.test_custom_message_layout2, null, false);
                    // 把自定义消息view添加到TUIKit内部的父容器里
                    parent.addMessageItemView(view);
                    break;
            }

            // 自定义消息view的实现，这里仅仅展示文本信息，并且实现超链接跳转
            TextView textView = view.findViewById(R.id.test_custom_message_tv);
            textView.setText(customMessageData.text);
            textView.setClickable(true);
            textView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    Uri content_url = Uri.parse(customMessageData.url);
                    intent.setData(content_url);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    DemoApplication.instance().startActivity(intent);
                }
            });
        }
    }

}
