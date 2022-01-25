package com.tencent.qcloud.tuikit.tuichat.ui.view.message.viewholder;

import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.ui.view.message.SelectTextHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class TextMessageHolder extends MessageContentHolder {

    private TextView msgBodyText;
    private SelectTextHelper mSelectableTextHelper;
    private String selectedText;

    private final Runnable mShowSelectViewRunnable =
            () -> mSelectableTextHelper.reset();

    public TextMessageHolder(View itemView) {
        super(itemView);
        msgBodyText = itemView.findViewById(R.id.msg_body_tv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_text;
    }

    public void resetSelectableText() {
        //msgBodyText.callOnClick();
        msgBodyText.postDelayed(mShowSelectViewRunnable, 120);
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof TextMessageBean)) {
            return;
        }
        TextMessageBean textMessageBean = (TextMessageBean) msg;

        if (!textMessageBean.isSelf()) {
            int otherTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), R.attr.chat_other_msg_text_color);
            int otherTextColor = msgBodyText.getResources().getColor(otherTextColorResId);
            msgBodyText.setTextColor(otherTextColor);
        } else {
            int selfTextColorResId = TUIThemeManager.getAttrResId(msgBodyText.getContext(), R.attr.chat_self_msg_text_color);
            int selfTextColor = msgBodyText.getResources().getColor(selfTextColorResId);
            msgBodyText.setTextColor(selfTextColor);
        }

        boolean isEmoji = false;
        msgBodyText.setVisibility(View.VISIBLE);
        if (textMessageBean.getText() != null) {
            isEmoji = FaceManager.handlerEmojiText(msgBodyText, textMessageBean.getText(), false);
        } else if (!TextUtils.isEmpty(textMessageBean.getExtra())) {
            isEmoji = FaceManager.handlerEmojiText(msgBodyText, textMessageBean.getExtra(), false);
        } else {
            isEmoji = FaceManager.handlerEmojiText(msgBodyText, TUIChatService.getAppContext().getString(R.string.no_support_msg), false);
        }
        if (properties.getChatContextFontSize() != 0) {
            msgBodyText.setTextSize(properties.getChatContextFontSize());
        }
        if (textMessageBean.isSelf()) {
            if (properties.getRightChatContentFontColor() != 0) {
                msgBodyText.setTextColor(properties.getRightChatContentFontColor());
            }
        } else {
            if (properties.getLeftChatContentFontColor() != 0) {
                msgBodyText.setTextColor(properties.getLeftChatContentFontColor());
            }
        }

        msgContentFrame.setOnLongClickListener(new View.OnLongClickListener() {
                @Override
                public boolean onLongClick(View v) {
                    //mSelectableTextHelper.selectAll();
                    return true;
                }
            });

        mSelectableTextHelper = new SelectTextHelper
                .Builder(msgBodyText)// 放你的textView到这里！！
                .setCursorHandleColor(TUIChatService.getAppContext().getResources().getColor(R.color.font_blue))// 游标颜色
                .setCursorHandleSizeInDp(22)// 游标大小 单位dp
                .setSelectedColor(TUIChatService.getAppContext().getResources().getColor(R.color.test_blue))// 选中文本的颜色
                .setSelectAll(true)// 初次选中是否全选 default true
                .setIsEmoji(isEmoji)
                .setScrollShow(false)// 滚动时是否继续显示 default true
                .setSelectedAllNoPop(true)// 已经全选无弹窗，设置了监听会回调 onSelectAllShowCustomPop 方法
                .setMagnifierShow(false)// 放大镜 default true
                .build();

        mSelectableTextHelper.setSelectListener(new SelectTextHelper.OnSelectListener() {
            /**
             * 点击回调
             */
            @Override
            public void onClick(View v) {
                //clickTextView(textView.getText().toString().trim());
            }

            /**
             * 长按回调
             */
            @Override
            public void onLongClick(View v) {
                //postShowCustomPop(SHOW_DELAY);
            }

            /**
             * 选中文本回调
             */
            @Override
            public void onTextSelected(CharSequence content) {
                selectedText = content.toString();
                textMessageBean.setSelectText(selectedText);
                TUIChatLog.d("TextMessageHolder", "onTextSelected selectedText = " + selectedText);
                if (onItemClickListener != null) {
                    onItemClickListener.onTextSelected(msgContentFrame, position, msg);
                }
            }

            /**
             * 弹窗关闭回调
             */
            @Override
            public void onDismiss() {
            }

            /**
             * 点击TextView里的url回调
             *
             * 已被下面重写
             * textView.setMovementMethod(new LinkMovementMethodInterceptor());
             */
            @Override
            public void onClickUrl(String url) {
                //toast("点击了：  " + url);
            }

            /**
             * 全选显示自定义弹窗回调
             */
            @Override
            public void onSelectAllShowCustomPop() {
                //postShowCustomPop(SHOW_DELAY);
            }

            /**
             * 重置回调
             */
            @Override
            public void onReset() {
                //SelectTextEventBus.getDefault().dispatch(new SelectTextEvent("dismissOperatePop"));
            }

            /**
             * 解除自定义弹窗回调
             */
            @Override
            public void onDismissCustomPop() {
                //SelectTextEventBus.getDefault().dispatch(new SelectTextEvent("dismissOperatePop"));
            }

            /**
             * 是否正在滚动回调
             */
            @Override
            public void onScrolling() {
                //removeShowSelectView();
            }
        });
    }

}
