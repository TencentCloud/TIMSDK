package com.tencent.qcloud.tuikit.tuichat.classicui.setting;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;
import com.google.gson.Gson;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.CustomHelloMessage;
import com.tencent.qcloud.tuikit.tuichat.bean.InputMoreActionUnit;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.MessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.util.ChatMessageBuilder;

public class ChatLayoutSetting {
    private static final String TAG = ChatLayoutSetting.class.getSimpleName();

    private Context mContext;
    private String groupId;

    public ChatLayoutSetting(Context context) {
        mContext = context;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public void customizeMessageLayout(final MessageRecyclerView messageRecyclerView) {
        if (messageRecyclerView == null) {
            return;
        }
    }

    public void customizeChatLayout(final ChatView layout) {
        //        //====== NoticeLayout使用范例 ======//
        //====== NoticeLayout example======//
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

        // 设置聊天界面自定义视图为安全提示
        // Set custom view of chat interface as security prompt
        ViewGroup customNoticeLayout = TUIChatConfigs.getConfigs().getNoticeLayoutConfig().getCustomNoticeLayout();
        FrameLayout customView = layout.getCustomView();
        if (customNoticeLayout != null && customView.getVisibility() == View.GONE) {
            ViewParent viewParent = customNoticeLayout.getParent();
            if (viewParent instanceof ViewGroup) {
                ViewGroup parentView = (ViewGroup) viewParent;
                parentView.removeAllViews();
            }
            customView.addView(customNoticeLayout);
            customView.setVisibility(View.VISIBLE);
        }

        //====== MessageLayout使用范例 ======//
        //====== MessageLayout example ======//
        MessageRecyclerView messageRecyclerView = layout.getMessageLayout();
        //        ////// 设置聊天背景 Set chat background//////
        //        messageRecyclerView.setBackground(new ColorDrawable(0xFFEFE5D4));
        //        ////// 设置头像 Set Avatar//////
        //        // 设置默认头像，默认与朋友与自己的头像相同
        // Set the default avatar, the default is the same as your friend's and your own avatar
        //        messageRecyclerView.setAvatar(R.drawable.ic_more_file);
        //        // 设置头像圆角 Set avatar rounded corners
        //        messageRecyclerView.setAvatarRadius(50);
        //        // 设置头像大小 Set avatar size
        //        messageRecyclerView.setAvatarSize(new int[]{48, 48});
        //
        //        ////// 设置昵称样式（对方与自己的样式保持一致）//////
        //        ////// Set the nickname style (the other party is consistent with their own style) //////
        //        messageRecyclerView.setNameFontSize(12);
        //        messageRecyclerView.setNameFontColor(0xFF8B5A2B);
        //
        //        ////// 设置气泡 set bubbles///////
        //        // 设置自己聊天气泡的背景
        //        // Set the background of your own chat bubble
        //        messageRecyclerView.setRightBubble(new ColorDrawable(0xFFCCE4FC));
        //        // 设置朋友聊天气泡的背景
        //        // Set the background of friends chat bubbles
        //        messageRecyclerView.setLeftBubble(new ColorDrawable(0xFFE4E7EB));
        //
        //        ////// 设置聊天内容 Set up chat content//////
        //        // 设置聊天内容字体字体大小，朋友和自己用一种字体大小
        //        // Set the font size of chat content, friends and yourself use a font size
        //        messageRecyclerView.setChatContextFontSize(15);
        //        // 设置自己聊天内容字体颜色
        //        // Set your own chat content font color
        //        messageRecyclerView.setRightChatContentFontColor(0xFFA9A9A9);
        //        // 设置朋友聊天内容字体颜色
        //        // Set friend chat content font color
        //        messageRecyclerView.setLeftChatContentFontColor(0xFFA020F0);
        //
        //        ////// 设置聊天时间 Set chat time//////
        //        // 设置聊天时间线的背景
        //        // Set the background of the chat timeline
        //        messageRecyclerView.setChatTimeBubble(new ColorDrawable(0xFFE4E7EB));
        //        // 设置聊天时间的字体大小
        //        // Set the font size of chat time
        //        messageRecyclerView.setChatTimeFontSize(12);
        //        // 设置聊天时间的字体颜色
        //        // Set the font color of chat time
        //        messageRecyclerView.setChatTimeFontColor(0xFF7E848C);
        //
        //        ////// 设置聊天的提示信息 Set up chat alerts//////
        //        // 设置提示的背景
        //        // Set the background of the prompt
        //        messageRecyclerView.setTipsMessageBubble(new ColorDrawable(0xFFE4E7EB));
        //        // 设置提示的字体大小
        //        // Set the font size of the prompt
        //        messageRecyclerView.setTipsMessageFontSize(12);
        //        // 设置提示的字体颜色
        //        // Set the font color of the prompt
        //        messageRecyclerView.setTipsMessageFontColor(0xFF7E848C);
        //

        //
        //        // 新增一个PopMenuAction
        //        // Add a PopMenuAction
        //        PopMenuAction action = new PopMenuAction();
        //        action.setActionName("test");
        //        action.setActionClickListener(new PopActionClickListener() {
        //            @Override
        //            public void onActionClick(int position, Object data) {
        //                ToastUtil.toastShortMessage("新增一个pop action");
        //            }
        //        });
        //        messageRecyclerView.addPopAction(action);
        //
        //        final MessageRecyclerView.OnItemClickListener l = messageRecyclerView.getOnItemClickListener();
        //        messageRecyclerView.setOnItemClickListener(new MessageRecyclerView.OnItemClickListener() {
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
        //====== InputLayout example ======//
        final InputView inputView = layout.getInputLayout();

        //        // TODO 隐藏音频输入的入口，可以打开下面代码测试
        //        // To hide the entrance of audio input, you can open the following code to test
        //        inputView.disableAudioInput(true);
        //        // TODO 隐藏表情输入的入口，可以打开下面代码测试
        //        // To hide the entry of expression input, you can open the following code test
        //        inputView.disableEmojiInput(true);
        //        // TODO 隐藏更多功能的入口，可以打开下面代码测试
        //        // To hide the entrance of more functions, you can open the following code test
        //        inputView.disableMoreInput(true);
        //        // TODO 可以用自定义的事件来替换更多功能的入口，可以打开下面代码测试
        //        // You can replace the entry of more functions with custom events, you can open the following code test
        //        inputView.replaceMoreInput(new View.OnClickListener() {
        //            @Override
        //            public void onClick(View v) {
        //                ToastUtil.toastShortMessage("自定义的更多功能按钮事件");
        //                MessageInfo info = ChatMessageInfoUtil.buildTextMessage("自定义的消息");
        //                layout.sendMessage(info, false);
        //            }
        //        });
        //        // TODO 可以用自定义的fragment来替换更多功能，可以打开下面代码测试
        //        // You can replace more functions with custom fragments, you can open the following code to test
        //        inputView.replaceMoreInput(new CustomInputFragment().setChatLayout(layout));
        //
        //        // TODO 可以disable更多面板上的各个功能，可以打开下面代码测试
        //        // You can disable various functions on more panels, you can open the following code test
        //        inputView.disableCaptureAction(true);
        //        inputView.disableSendFileAction(true);
        //        inputView.disableSendPhotoAction(true);
        //        inputView.disableVideoRecordAction(true);

        // TODO 可以自己增加一些功能，可以打开下面代码测试
        // You can add some functions yourself, you can open the following code to test

        // 增加一个欢迎提示富文本
        // Add a welcome prompt with rich text
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isEnableWelcomeCustomMessage()) {
            InputMoreActionUnit unit = new InputMoreActionUnit() {};
            unit.setIconResId(R.drawable.custom);
            unit.setName(mContext.getString(R.string.test_custom_action));
            unit.setActionId(CustomHelloMessage.CUSTOM_HELLO_ACTION_ID);
            unit.setPriority(10);
            unit.setOnClickListener(unit.new OnActionClickListener() {
                @Override
                public void onClick() {
                    Gson gson = new Gson();
                    CustomHelloMessage customHelloMessage = new CustomHelloMessage();
                    customHelloMessage.version = TUIChatConstants.version;

                    String data = gson.toJson(customHelloMessage);
                    TUIMessageBean info = ChatMessageBuilder.buildCustomMessage(data, customHelloMessage.text, customHelloMessage.text.getBytes());
                    layout.sendMessage(info, false);
                }
            });
            inputView.addAction(unit);
        }
    }

    //    public static class CustomInputFragment extends BaseInputFragment {
    //        @Nullable
    //        @Override
    //        public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {
    //            View baseView = inflater.inflate(R.layout.test_chat_input_custom_fragment, container, false);
    //            Button btn1 = baseView.findViewById(R.id.test_send_message_btn1);
    //            btn1.setOnClickListener(new View.OnClickListener() {
    //                @Override
    //                public void onClick(View v) {
    //                    ToastUtil.toastShortMessage("自定义的按钮1");
    //                    if (getChatLayout() != null) {
    //                        Gson gson = new Gson();
    //                        CustomHelloMessage customHelloMessage = new CustomHelloMessage();
    //                        String data = gson.toJson(customHelloMessage);
    //                        MessageInfo info = ChatMessageInfoUtil.buildCustomMessage(data);
    //                        getChatLayout().sendMessage(info, false);
    //                    }
    //                }
    //            });
    //            Button btn2 = baseView.findViewById(R.id.test_send_message_btn2);
    //            btn2.setOnClickListener(new View.OnClickListener() {
    //                @Override
    //                public void onClick(View v) {
    //                    ToastUtil.toastShortMessage("自定义的按钮2");
    //                    if (getChatLayout() != null) {
    //                        Gson gson = new Gson();
    //                        CustomHelloMessage customHelloMessage = new CustomHelloMessage();
    //                        String data = gson.toJson(customHelloMessage);
    //                        MessageInfo info = ChatMessageInfoUtil.buildCustomMessage(data);
    //                        getChatLayout().sendMessage(info, false);
    //                    }
    //                }
    //            });
    //            return baseView;
    //        }

    //    }
}
