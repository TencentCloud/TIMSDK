package com.tencent.qcloud.tim.uikit.modules.chat.layout.message.holder;

import android.text.Html;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tim.uikit.modules.message.MessageInfo;
import com.tencent.qcloud.tim.uikit.utils.TUIKitConstants;

public class MessageCustomHolder extends MessageContentHolder implements ICustomMessageViewGroup {

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
    }

    @Override
    public void layoutVariableViews(final MessageInfo msg, final int position) {

        // 因为recycleview的复用性，可能该holder回收后继续被custom类型的item复用
        // 但是因为addMessageContentView破坏了msgContentFrame的view结构，所以会造成items的显示错乱。
        // 这里我们重新添加一下msgBodyText
        msgContentFrame.removeAllViews();
        if (msgBodyText.getParent() != null) {
            ((ViewGroup)msgBodyText.getParent()).removeView(msgBodyText);
        }
        msgContentFrame.addView(msgBodyText);
        msgBodyText.setVisibility(View.VISIBLE);

        if (msg.getExtra() != null) {
            if (TextUtils.equals(TUIKit.getAppContext().getString(R.string.custom_msg), msg.getExtra().toString())) {
                msgBodyText.setText(Html.fromHtml(TUIKitConstants.covert2HTMLString(TUIKit.getAppContext().getString(R.string.no_support_custom_msg))));
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

        if (isShowMutiSelect){
            mMutiSelectCheckBox.setVisibility(View.VISIBLE);
        } else {
            mMutiSelectCheckBox.setVisibility(View.GONE);
        }
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

}
