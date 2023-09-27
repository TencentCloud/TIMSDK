package com.tencent.qcloud.tuikit.tuivoicetotextplugin.widget;

import android.content.ClipData;
import android.content.ClipboardManager;
import android.content.Context;
import android.text.TextUtils;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.LinearInterpolator;
import android.view.animation.RotateAnimation;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.MessageProperties;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIBaseChatFragment;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.TUIBaseChatMinimalistFragment;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.R;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.TUIVoiceToTextService;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.model.VoiceToTextProvider;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.presenter.VoiceToTextPresenter;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.util.TUIVoiceToTextLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VoiceToTextMessageLayoutProxy {
    private static final String TAG = "PollMessageLayoutProxy";

    protected List<ChatPopMenu.ChatPopMenuAction> mConvertedPopActions = new ArrayList<>();
    private ChatPopMenu mConvertedChatPopMenu;

    public VoiceToTextMessageLayoutProxy() {}

    public void showVoiceToTextView(BaseFragment fragment, String themeStyle, RecyclerView recyclerView, ViewGroup viewGroup, TUIMessageBean tuiMessageBean) {
        if (viewGroup == null || tuiMessageBean == null) {
            return;
        }

        setVoiceToTextContent(fragment, themeStyle, recyclerView, viewGroup, tuiMessageBean);
    }

    public void convertMessage(TUIMessageBean tuiMessageBean) {
        VoiceToTextPresenter voiceToTextPresenter = new VoiceToTextPresenter();
        voiceToTextPresenter.convertMessage(tuiMessageBean, new IUIKitCallback<String>() {
            @Override
            public void onSuccess(String data) {

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                ToastUtil.toastShortMessage(TUIVoiceToTextService.getAppContext().getString(R.string.convert_to_text_failed_tips));
            }
        });
    }

    protected void setVoiceToTextContent(BaseFragment fragment, String themeStyle, RecyclerView recyclerView, ViewGroup viewGroup, TUIMessageBean msg) {
        LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.convert_content_layout, viewGroup);
        ImageView loadingImage = viewGroup.findViewById(R.id.convert_loading_iv);
        TextView convertedText = viewGroup.findViewById(R.id.convert_tv);
        VoiceToTextPresenter voiceToTextPresenter = new VoiceToTextPresenter();

        int status = voiceToTextPresenter.getConvertedTextStatus(msg.getV2TIMMessage());
        if (status == VoiceToTextProvider.MSG_VOICE_TO_TEXT_STATUS_SHOWN) {
            ViewGroup parentViewGroup = (ViewGroup) viewGroup.getParent();
            parentViewGroup.setVisibility(View.VISIBLE);
            viewGroup.setVisibility(View.VISIBLE);
            stopConvertLoading(loadingImage);
            convertedText.setVisibility(View.VISIBLE);
            if (TextUtils.equals(themeStyle, TUIConstants.TUIChat.THEME_STYLE_MINIMALIST)) {
                convertedText.setTextSize(TypedValue.COMPLEX_UNIT_PX,
                    convertedText.getResources().getDimension(com.tencent.qcloud.tuikit.timcommon.R.dimen.chat_minimalist_message_text_size));
            }
            if (MessageProperties.getInstance().getChatContextFontSize() != 0) {
                convertedText.setTextSize(MessageProperties.getInstance().getChatContextFontSize());
            }

            convertedText.setText(voiceToTextPresenter.getConvertedText(msg.getV2TIMMessage()));
            if (fragment != null) {
                viewGroup.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View view) {
                        showConvertedItemPopMenu(fragment, themeStyle, recyclerView, view, msg);
                        return true;
                    }
                });
            }
        } else if (status == VoiceToTextProvider.MSG_VOICE_TO_TEXT_STATUS_LOADING) {
            ViewGroup parentViewGroup = (ViewGroup) viewGroup.getParent();
            parentViewGroup.setVisibility(View.VISIBLE);
            viewGroup.setVisibility(View.VISIBLE);
            startConvertLoading(loadingImage);
            convertedText.setVisibility(View.GONE);
            viewGroup.setOnLongClickListener(null);
        } else {
            stopConvertLoading(loadingImage);
            viewGroup.setVisibility(View.GONE);
            viewGroup.setOnLongClickListener(null);
        }
    }

    private void showConvertedItemPopMenu(BaseFragment fragment, String themeStyle, RecyclerView recyclerView, View view, TUIMessageBean messageInfo) {
        initConvertedPopActions(fragment, themeStyle, messageInfo);
        if (mConvertedPopActions.size() == 0) {
            return;
        }

        if (mConvertedChatPopMenu != null) {
            mConvertedChatPopMenu.hide();
            mConvertedChatPopMenu = null;
        }
        mConvertedChatPopMenu = new ChatPopMenu(view.getContext());
        mConvertedChatPopMenu.setShowFaces(false);
        mConvertedChatPopMenu.setChatPopMenuActionList(mConvertedPopActions);

        int[] location = new int[2];
        recyclerView.getLocationOnScreen(location);
        mConvertedChatPopMenu.show(view, location[1]);
    }

    private void initConvertedPopActions(BaseFragment fragment, String themeStyle, TUIMessageBean msg) {
        if (msg == null) {
            return;
        }

        VoiceToTextPresenter voiceToTextPresenter = new VoiceToTextPresenter();
        ChatPopMenu.ChatPopMenuAction copyAction = new ChatPopMenu.ChatPopMenuAction();
        copyAction.setActionName(fragment.getContext().getString(R.string.copy_action));
        copyAction.setActionIcon(com.tencent.qcloud.tuikit.tuichat.R.drawable.pop_menu_copy);
        copyAction.setActionClickListener(() -> onCopyConvertedTextClick(voiceToTextPresenter.getConvertedText(msg.getV2TIMMessage())));
        ChatPopMenu.ChatPopMenuAction forwardAction = null;
        if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            forwardAction = new ChatPopMenu.ChatPopMenuAction();
            forwardAction.setActionName(fragment.getContext().getString(R.string.forward_action));
            forwardAction.setActionIcon(R.drawable.pop_menu_forward);
            forwardAction.setActionClickListener(() -> onForwardConvertedTextClick(fragment, themeStyle, msg));
        }
        ChatPopMenu.ChatPopMenuAction hiddenAction = new ChatPopMenu.ChatPopMenuAction();
        hiddenAction.setActionName(fragment.getContext().getString(R.string.hide_action));
        hiddenAction.setActionIcon(R.drawable.pop_menu_hide);
        hiddenAction.setActionClickListener(() -> onHideConvertedTextClick(msg));

        mConvertedPopActions.clear();
        mConvertedPopActions.add(copyAction);
        if (forwardAction != null) {
            mConvertedPopActions.add(forwardAction);
        }
        mConvertedPopActions.add(hiddenAction);
    }

    private void onCopyConvertedTextClick(String convertedText) {
        ClipboardManager clipboard = (ClipboardManager) TUIChatService.getAppContext().getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboard == null || TextUtils.isEmpty(convertedText)) {
            return;
        }
        ClipData clip = ClipData.newPlainText("message", convertedText);
        clipboard.setPrimaryClip(clip);
        String copySuccess = TUIChatService.getAppContext().getResources().getString(R.string.copy_success_tip);
        ToastUtil.toastShortMessage(copySuccess);
    }

    private void onHideConvertedTextClick(TUIMessageBean messageBean) {
        VoiceToTextPresenter voiceToTextPresenter = new VoiceToTextPresenter();
        voiceToTextPresenter.saveConvertedResult(messageBean.getV2TIMMessage(), voiceToTextPresenter.getConvertedText(messageBean.getV2TIMMessage()),
            VoiceToTextProvider.MSG_VOICE_TO_TEXT_STATUS_HIDDEN);
        Map<String, Object> param = new HashMap<>();
        param.put(TUIChatConstants.MESSAGE_BEAN, messageBean);
        param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        TUICore.notifyEvent(
            TUIConstants.TUIVoiceToTextPlugin.EVENT_KEY_VOICE_TO_TEXT_EVENT, TUIConstants.TUIVoiceToTextPlugin.EVENT_SUB_KEY_VOICE_TO_TEXT_CHANGED, param);
    }

    private void onForwardConvertedTextClick(BaseFragment fragment, String themeStyle, TUIMessageBean messageBean) {
        if (fragment == null) {
            TUIVoiceToTextLog.e(TAG, "onForwardConvertedTextClick fragment is null!");
            return;
        }

        VoiceToTextPresenter voiceToTextPresenter = new VoiceToTextPresenter();
        if (themeStyle != null) {
            if (themeStyle.equals(TUIConstants.TUIChat.THEME_STYLE_CLASSIC) && fragment instanceof TUIBaseChatFragment) {
                ((TUIBaseChatFragment) fragment).getChatView().forwardText(voiceToTextPresenter.getConvertedText(messageBean.getV2TIMMessage()));
            } else if (themeStyle.equals(TUIConstants.TUIChat.THEME_STYLE_MINIMALIST) && fragment instanceof TUIBaseChatMinimalistFragment) {
                ((TUIBaseChatMinimalistFragment) fragment).getChatView().forwardText(voiceToTextPresenter.getConvertedText(messageBean.getV2TIMMessage()));
            }
        }
    }

    private void startConvertLoading(ImageView loadingImage) {
        loadingImage.setVisibility(View.VISIBLE);
        RotateAnimation convertRotateAnimation = new RotateAnimation(0, 360, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f);
        convertRotateAnimation.setRepeatCount(-1);
        convertRotateAnimation.setDuration(1000);
        convertRotateAnimation.setInterpolator(new LinearInterpolator());
        loadingImage.startAnimation(convertRotateAnimation);
    }

    private void stopConvertLoading(ImageView loadingImage) {
        loadingImage.clearAnimation();
        loadingImage.setVisibility(View.GONE);
    }
}
