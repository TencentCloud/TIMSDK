package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.text.Html;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.StringRes;

import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.MessageInfo;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.ICustomMessageViewGroup;
import com.tencent.qcloud.tuikit.tuichat.ui.interfaces.OnItemLongClickListener;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.HashMap;


public class MessageCustomHolder extends MessageContentHolder implements ICustomMessageViewGroup {
    public static final String TAG = MessageCustomHolder.class.getSimpleName();

    private MessageInfo mMessageInfo;
    private int mPosition;

    private TextView msgBodyText;

    private boolean isShowMutiSelect = false;

    public MessageCustomHolder(View itemView) {
        super(itemView);
    }

    public void setShowMutiSelect(boolean showMutiSelect) {
        isShowMutiSelect = showMutiSelect;
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_text;
    }

    @Override
    public void initVariableViews() {
        msgBodyText = rootView.findViewById(R.id.msg_body_tv);
    }

    @Override
    public void layoutViews(MessageInfo msg, int position) {
        mMessageInfo = msg;
        mPosition = position;
        super.layoutViews(msg, position);

        if (msg == null) {
            return;
        }
        String data = new String(msg.getCustomElemData());
        Gson gson = new Gson();
        HashMap customJsonMap = null;
        try {
            customJsonMap = gson.fromJson(data, HashMap.class);
        } catch (JsonSyntaxException e) {
            TUIChatLog.e("MessageCustomHolder", " getCustomJsonMap error ");
        }
        String businessId = null;
        Object businessIdObj = null;
        if (customJsonMap != null) {
            businessIdObj = customJsonMap.get(TUIConstants.Message.CUSTOM_BUSINESS_ID_KEY);
        }
        if (businessIdObj instanceof String) {
            businessId = (String) businessIdObj;
        }

        // 欢迎消息
        if (TextUtils.equals(businessId, TUIChatConstants.BUSINESS_ID_CUSTOM_HELLO)) {
            drawCustomHelloMessage(msg, position);
        } else {

            // 因为recycleview的复用性，可能该holder回收后继续被custom类型的item复用
            // 但是因为addMessageContentView破坏了msgContentFrame的view结构，所以会造成items的显示错乱。
            // 这里我们重新添加一下msgBodyText
            msgContentFrame.removeAllViews();
            if (msgBodyText.getParent() != null) {
                ((ViewGroup) msgBodyText.getParent()).removeView(msgBodyText);
            }
            msgContentFrame.addView(msgBodyText);
            msgBodyText.setVisibility(View.VISIBLE);

            if (msg.getExtra() != null) {
                if (TextUtils.equals(TUIChatService.getAppContext().getString(R.string.custom_msg), msg.getExtra().toString())) {
                    msgBodyText.setText(Html.fromHtml(TUIChatConstants.covert2HTMLString(TUIChatService.getAppContext().getString(R.string.no_support_custom_msg))));
                } else {
                    msgBodyText.setText(msg.getExtra().toString());
                }
            }
            if (properties.getChatContextFontSize() != 0) {
                msgBodyText.setTextSize(properties.getChatContextFontSize());
            }
            if (msg.isSelf()) {
                if (properties.getRightChatContentFontColor() != 0) {
                    msgBodyText.setTextColor(properties.getRightChatContentFontColor());
                }
            } else {
                if (properties.getLeftChatContentFontColor() != 0) {
                    msgBodyText.setTextColor(properties.getLeftChatContentFontColor());
                }
            }

            if (isShowMutiSelect) {
                mMutiSelectCheckBox.setVisibility(View.VISIBLE);
            } else {
                mMutiSelectCheckBox.setVisibility(View.GONE);
            }
        }
    }

    @Override
    public void layoutVariableViews(final MessageInfo msg, final int position) {

    }

    private void hideAll() {
        for (int i = 0; i < ((RelativeLayout) rootView).getChildCount(); i++) {
            ((RelativeLayout) rootView).getChildAt(i).setVisibility(View.GONE);
        }
    }

    @Override
    public void addMessageItemView(View view) {
        hideAll();
        if (view != null) {
            ((RelativeLayout) rootView).removeView(view);
            ((RelativeLayout) rootView).addView(view);
        }
    }

    @Override
    public void addMessageContentView(View view) {
        // item有可能被复用，因为不能确定是否存在其他自定义view，这里把所有的view都隐藏之后重新layout
        hideAll();
        super.layoutViews(mMessageInfo, mPosition);

        if (view != null) {
            for (int i = 0; i < msgContentFrame.getChildCount(); i++) {
                msgContentFrame.getChildAt(i).setVisibility(View.GONE);
            }
            msgContentFrame.removeView(view);
            msgContentFrame.addView(view);
        }
    }

    private void drawCustomHelloMessage(MessageInfo messageInfo, int position) {
        LinearLayout.LayoutParams msgContentFrameParams = (LinearLayout.LayoutParams) msgContentFrame.getLayoutParams();
        msgContentFrameParams.width = ViewGroup.LayoutParams.WRAP_CONTENT;
        msgContentFrame.setLayoutParams(msgContentFrameParams);
        View view = LayoutInflater.from(TUIChatService.getAppContext()).inflate(R.layout.test_custom_message_layout1, null, false);
        addMessageContentView(view);

        // 自定义消息view的实现，这里仅仅展示文本信息，并且实现超链接跳转
        TextView textView = view.findViewById(R.id.test_custom_message_tv);
        String text = TUIChatService.getAppContext().getString(R.string.no_support_msg);
        String data = new String(messageInfo.getCustomElemData());

        String link = "";
        try {
            HashMap map = new Gson().fromJson(data, HashMap.class);
            if (map != null) {
                text = (String) map.get("text");
                link = (String) map.get("link");
            }
        } catch (JsonSyntaxException e) {

        }

        textView.setText(text);
        view.setClickable(true);
        String finalLink = link;
        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri content_url = Uri.parse(finalLink);
                intent.setData(content_url);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                TUIChatService.getAppContext().startActivity(intent);
            }
        });

        view.setOnLongClickListener(new View.OnLongClickListener() {
            @Override
            public boolean onLongClick(View v) {
                if (onItemLongClickListener != null) {
                    onItemLongClickListener.onMessageLongClick(v, position, messageInfo);
                }
                return false;
            }
        });
    }

}
