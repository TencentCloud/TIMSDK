package com.tencent.qcloud.tuikit.tuitranslationplugin.widget;

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
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMTextElem;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.MessageProperties;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.classicui.component.popmenu.ChatPopMenu;
import com.tencent.qcloud.tuikit.tuichat.classicui.page.TUIBaseChatFragment;
import com.tencent.qcloud.tuikit.tuichat.interfaces.IMessageRecyclerView;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.page.TUIBaseChatMinimalistFragment;
import com.tencent.qcloud.tuikit.tuitranslationplugin.R;
import com.tencent.qcloud.tuikit.tuitranslationplugin.model.TranslationProvider;
import com.tencent.qcloud.tuikit.tuitranslationplugin.presenter.TranslationPresenter;
import com.tencent.qcloud.tuikit.tuitranslationplugin.util.TUITranslationLog;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TranslationMessageLayoutProxy {
    private static final String TAG = "PollMessageLayoutProxy";

    protected List<ChatPopMenu.ChatPopMenuAction> mTranslationPopActions = new ArrayList<>();
    private ChatPopMenu mTranslationChatPopMenu;

    public TranslationMessageLayoutProxy() {}

    public void showTranslationView(BaseFragment fragment, String themeStyle, RecyclerView recyclerView, ViewGroup viewGroup, TUIMessageBean tuiMessageBean) {
        if (viewGroup == null || tuiMessageBean == null) {
            return;
        }

        setTranslationContent(fragment, themeStyle, recyclerView, viewGroup, tuiMessageBean);
    }

    public void translateMessage(TUIMessageBean tuiMessageBean) {
        TranslationPresenter translationPresenter = new TranslationPresenter();
        translationPresenter.translateMessage(tuiMessageBean, null);
    }

    protected void setTranslationContent(BaseFragment fragment, String themeStyle, RecyclerView recyclerView, ViewGroup viewGroup, TUIMessageBean msg) {
        LayoutInflater.from(viewGroup.getContext()).inflate(R.layout.translation_contant_layout, viewGroup);
        ImageView translationLoadingImage = viewGroup.findViewById(R.id.translate_loading_iv);
        LinearLayout translationResultLayout = viewGroup.findViewById(R.id.translate_result_ll);

        TranslationPresenter presenter = new TranslationPresenter();
        int translationStatus = presenter.getTranslationStatus(msg.getV2TIMMessage());
        if (translationStatus == TranslationProvider.MSG_TRANSLATE_STATUS_SHOWN) {
            ViewGroup parentViewGroup = (ViewGroup) viewGroup.getParent();
            parentViewGroup.setVisibility(View.VISIBLE);
            viewGroup.setVisibility(View.VISIBLE);
            stopTranslationLoading(translationLoadingImage);
            translationResultLayout.setVisibility(View.VISIBLE);
            TextView translationText = viewGroup.findViewById(R.id.translate_tv);
            if (TextUtils.equals(themeStyle, TUIConstants.TUIChat.THEME_STYLE_MINIMALIST)) {
                translationText.setTextSize(TypedValue.COMPLEX_UNIT_PX,
                    translationText.getResources().getDimension(com.tencent.qcloud.tuikit.timcommon.R.dimen.chat_minimalist_message_text_size));
            }
            if (MessageProperties.getInstance().getChatContextFontSize() != 0) {
                translationText.setTextSize(MessageProperties.getInstance().getChatContextFontSize());
            }

            FaceManager.handlerEmojiText(translationText, presenter.getTranslationText(msg.getV2TIMMessage()), false);
            if (fragment != null) {
                viewGroup.setOnLongClickListener(new View.OnLongClickListener() {
                    @Override
                    public boolean onLongClick(View view) {
                        showTranslationItemPopMenu(fragment, themeStyle, recyclerView, view, msg);
                        return true;
                    }
                });
            }
        } else if (translationStatus == TranslationProvider.MSG_TRANSLATE_STATUS_LOADING) {
            ViewGroup parentViewGroup = (ViewGroup) viewGroup.getParent();
            parentViewGroup.setVisibility(View.VISIBLE);
            viewGroup.setVisibility(View.VISIBLE);
            startTranslationLoading(translationLoadingImage);
            translationResultLayout.setVisibility(View.GONE);
            viewGroup.setOnLongClickListener(null);
        } else {
            stopTranslationLoading(translationLoadingImage);
            viewGroup.setVisibility(View.GONE);
            viewGroup.setOnLongClickListener(null);
        }
    }

    private void showTranslationItemPopMenu(BaseFragment fragment, String themeStyle, RecyclerView recyclerView, View view, TUIMessageBean messageInfo) {
        initTranslationPopActions(fragment, themeStyle, messageInfo);
        if (mTranslationPopActions.size() == 0) {
            return;
        }

        if (mTranslationChatPopMenu != null) {
            mTranslationChatPopMenu.hide();
            mTranslationChatPopMenu = null;
        }
        mTranslationChatPopMenu = new ChatPopMenu(view.getContext());
        mTranslationChatPopMenu.setShowFaces(false);
        mTranslationChatPopMenu.setChatPopMenuActionList(mTranslationPopActions);

        int[] location = new int[2];
        recyclerView.getLocationOnScreen(location);
        mTranslationChatPopMenu.show(view, location[1]);
    }

    private void initTranslationPopActions(BaseFragment fragment, String themeStyle, TUIMessageBean msg) {
        if (msg == null) {
            return;
        }

        TranslationPresenter presenter = new TranslationPresenter();
        ChatPopMenu.ChatPopMenuAction copyAction = new ChatPopMenu.ChatPopMenuAction();
        copyAction.setActionName(fragment.getContext().getString(R.string.copy_action));
        copyAction.setActionIcon(com.tencent.qcloud.tuikit.tuichat.R.drawable.pop_menu_copy);
        copyAction.setActionClickListener(() -> onCopyTranslationClick(presenter.getTranslationText(msg.getV2TIMMessage())));
        ChatPopMenu.ChatPopMenuAction forwardAction = null;
        if (msg.getStatus() != TUIMessageBean.MSG_STATUS_SEND_FAIL) {
            forwardAction = new ChatPopMenu.ChatPopMenuAction();
            forwardAction.setActionName(fragment.getContext().getString(R.string.forward_action));
            forwardAction.setActionIcon(R.drawable.pop_menu_forward);
            forwardAction.setActionClickListener(() -> onForwardTranslationClick(fragment, themeStyle, msg));
        }
        ChatPopMenu.ChatPopMenuAction hiddenAction = new ChatPopMenu.ChatPopMenuAction();
        hiddenAction.setActionName(fragment.getContext().getString(R.string.hide_action));
        hiddenAction.setActionIcon(R.drawable.pop_menu_hide);
        hiddenAction.setActionClickListener(() -> onHideTranslationClick(msg));

        mTranslationPopActions.clear();
        mTranslationPopActions.add(copyAction);
        if (forwardAction != null) {
            mTranslationPopActions.add(forwardAction);
        }
        mTranslationPopActions.add(hiddenAction);
    }

    private void onCopyTranslationClick(String translationContent) {
        ClipboardManager clipboard = (ClipboardManager) TUIChatService.getAppContext().getSystemService(Context.CLIPBOARD_SERVICE);
        if (clipboard == null || TextUtils.isEmpty(translationContent)) {
            return;
        }
        ClipData clip = ClipData.newPlainText("message", translationContent);
        clipboard.setPrimaryClip(clip);
        String copySuccess = TUIChatService.getAppContext().getResources().getString(R.string.copy_success_tip);
        ToastUtil.toastShortMessage(copySuccess);
    }

    private void onHideTranslationClick(TUIMessageBean messageBean) {
        TranslationPresenter presenter = new TranslationPresenter();
        presenter.setTranslationStatus(messageBean.getV2TIMMessage(), TranslationProvider.MSG_TRANSLATE_STATUS_HIDDEN);
        Map<String, Object> param = new HashMap<>();
        param.put(TUIChatConstants.MESSAGE_BEAN, messageBean);
        param.put(TUIChatConstants.DATA_CHANGE_TYPE, IMessageRecyclerView.DATA_CHANGE_TYPE_UPDATE);
        TUICore.notifyEvent(TUIConstants.TUITranslationPlugin.EVENT_KEY_TRANSLATION_EVENT, TUIConstants.TUITranslationPlugin.EVENT_SUB_KEY_TRANSLATION_CHANGED, param);
    }

    private void onForwardTranslationClick(BaseFragment fragment, String themeStyle, TUIMessageBean messageBean) {
        if (fragment == null) {
            TUITranslationLog.e(TAG, "onForwardTranslationClick fragment is null!");
            return;
        }
        TranslationPresenter presenter = new TranslationPresenter();
        if (themeStyle != null) {
            if (themeStyle.equals(TUIConstants.TUIChat.THEME_STYLE_CLASSIC) && fragment instanceof TUIBaseChatFragment) {
                ((TUIBaseChatFragment) fragment).getChatView().forwardText(presenter.getTranslationText(messageBean.getV2TIMMessage()));
            } else if (themeStyle.equals(TUIConstants.TUIChat.THEME_STYLE_MINIMALIST) && fragment instanceof TUIBaseChatMinimalistFragment) {
                ((TUIBaseChatMinimalistFragment) fragment).getChatView().forwardText(presenter.getTranslationText(messageBean.getV2TIMMessage()));
            }
        }
    }

    private void startTranslationLoading(ImageView translationLoadingImage) {
        translationLoadingImage.setVisibility(View.VISIBLE);
        RotateAnimation translationRotateAnimation =
            new RotateAnimation(0, 360, RotateAnimation.RELATIVE_TO_SELF, 0.5f, RotateAnimation.RELATIVE_TO_SELF, 0.5f);
        translationRotateAnimation.setRepeatCount(-1);
        translationRotateAnimation.setDuration(1000);
        translationRotateAnimation.setInterpolator(new LinearInterpolator());
        translationLoadingImage.startAnimation(translationRotateAnimation);
    }

    private void stopTranslationLoading(ImageView translationLoadingImage) {
        translationLoadingImage.clearAnimation();
        translationLoadingImage.setVisibility(View.GONE);
    }
}
