package com.tencent.qcloud.tuikit.tuichat.minimalistui.setting;

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
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.ChatView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.input.InputView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.MessageRecyclerView;
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

        
        //====== MessageLayout example ======//
        MessageRecyclerView messageRecyclerView = layout.getMessageLayout();
        
        //        messageRecyclerView.setBackground(new ColorDrawable(0xFFEFE5D4));
        
        
        // Set the default avatar, the default is the same as your friend's and your own avatar
        //        messageRecyclerView.setAvatar(R.drawable.ic_more_file);
        
        messageRecyclerView.setAvatarRadius(100);
        
        //        messageRecyclerView.setAvatarSize(new int[]{48, 48});
        //
        
        //        ////// Set the nickname style (the other party is consistent with their own style) //////
        //        messageRecyclerView.setNameFontSize(12);
        //        messageRecyclerView.setNameFontColor(0xFF8B5A2B);
        //
        
        
        //        // Set the background of your own chat bubble
        //        messageRecyclerView.setRightBubble(new ColorDrawable(0xFFCCE4FC));
        
        //        // Set the background of friends chat bubbles
        //        messageRecyclerView.setLeftBubble(new ColorDrawable(0xFFE4E7EB));
        //
        
        
        //        // Set the font size of chat content, friends and yourself use a font size
        //        messageRecyclerView.setChatContextFontSize(15);
        
        //        // Set your own chat content font color
        //        messageRecyclerView.setRightChatContentFontColor(0xFFA9A9A9);
        
        //        // Set friend chat content font color
        //        messageRecyclerView.setLeftChatContentFontColor(0xFFA020F0);
        //
        
        
        //        // Set the background of the chat timeline
        //        messageRecyclerView.setChatTimeBubble(new ColorDrawable(0xFFE4E7EB));
        
        //        // Set the font size of chat time
        //        messageRecyclerView.setChatTimeFontSize(12);
        
        //        // Set the font color of chat time
        //        messageRecyclerView.setChatTimeFontColor(0xFF7E848C);
        //
        
        
        //        // Set the background of the prompt
        //        messageRecyclerView.setTipsMessageBubble(new ColorDrawable(0xFFE4E7EB));
        
        //        // Set the font size of the prompt
        //        messageRecyclerView.setTipsMessageFontSize(12);
        
        //        // Set the font color of the prompt
        //        messageRecyclerView.setTipsMessageFontColor(0xFF7E848C);
        //

        //
        
        //        // Add a PopMenuAction
        //        PopMenuAction action = new PopMenuAction();
        //        action.setActionName("test");
        //        action.setActionClickListener(new PopActionClickListener() {
        //            @Override
        //            public void onActionClick(int position, Object data) {
        
        //            }
        //        });
        //        messageRecyclerView.addPopAction(action);
        //
        //        final MessageRecyclerView.OnItemClickListener l = messageRecyclerView.getOnItemClickListener();
        //        messageRecyclerView.setOnItemClickListener(new MessageRecyclerView.OnItemClickListener() {
        //            @Override
        //            public void onMessageLongClick(View view, int position, MessageInfo messageInfo) {
        //                l.onMessageLongClick(view, position, messageInfo);
        
        //            }
        //
        //            @Override
        //            public void onUserIconClick(View view, int position, MessageInfo messageInfo) {
        //                l.onUserIconClick(view, position, messageInfo);
        
        //            }
        //        });

        
        //====== InputLayout example ======//
        final InputView inputView = layout.getInputLayout();

        
        //        // To hide the entrance of audio input, you can open the following code to test
        //        inputView.disableAudioInput(true);
        
        //        // To hide the entry of expression input, you can open the following code test
        //        inputView.disableEmojiInput(true);
        
        //        // To hide the entrance of more functions, you can open the following code test
        //        inputView.disableMoreInput(true);
        
        //        // You can replace the entry of more functions with custom events, you can open the following code test
        //        inputView.replaceMoreInput(new View.OnClickListener() {
        //            @Override
        //            public void onClick(View v) {
        
        
        //                layout.sendMessage(info, false);
        //            }
        //        });
        
        //        // You can replace more functions with custom fragments, you can open the following code to test
        //        inputView.replaceMoreInput(new CustomInputFragment().setChatLayout(layout));
        //
        
        //        // You can disable various functions on more panels, you can open the following code test
        //        inputView.disableCaptureAction(true);
        //        inputView.disableSendFileAction(true);
        //        inputView.disableSendPhotoAction(true);
        //        inputView.disableVideoRecordAction(true);

        
        // You can add some functions yourself, you can open the following code to test

        
        // Add a welcome prompt with rich text
        if (TUIChatConfigs.getConfigs().getGeneralConfig().isEnableWelcomeCustomMessage()) {
            InputMoreActionUnit unit = new InputMoreActionUnit() {};
            unit.setIconResId(R.drawable.chat_minimalist_more_action_custom_icon);
            unit.setName(inputView.getResources().getString(R.string.test_custom_action));
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
