package com.tencent.qcloud.tuikit.tuivoicetotextplugin;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.ServiceInitializer;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUIExtension;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionEventListener;
import com.tencent.qcloud.tuicore.interfaces.TUIExtensionInfo;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.tuichat.bean.message.SoundMessageBean;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.model.VoiceToTextProvider;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.presenter.VoiceToTextPresenter;
import com.tencent.qcloud.tuikit.tuivoicetotextplugin.widget.VoiceToTextMessageLayoutProxy;

import java.util.Collections;
import java.util.List;
import java.util.Map;

public class TUIVoiceToTextService extends ServiceInitializer implements ITUIExtension {
    public static final String TAG = TUIVoiceToTextService.class.getSimpleName();
    private static TUIVoiceToTextService instance;

    public static TUIVoiceToTextService getInstance() {
        return instance;
    }

    private Context appContext;
    private VoiceToTextMessageLayoutProxy voiceToTextMessageLayoutProxy;

    @Override
    public void init(Context context) {
        appContext = context;
        instance = this;
        initExtension();
        voiceToTextMessageLayoutProxy = new VoiceToTextMessageLayoutProxy();
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessagePopMenu.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessageBottom.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessageBottom.MINIMALIST_EXTENSION_ID, this);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID)
            || TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenu.MINIMALIST_EXTENSION_ID)) {
            if (param == null || param.isEmpty()) {
                return null;
            }

            TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIConstants.TUIChat.Extension.MessagePopMenu.MESSAGE_BEAN);
            VoiceToTextPresenter presenter = new VoiceToTextPresenter();
            V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
            if (v2TIMMessage == null) {
                return null;
            }

            if ((V2TIMMessage.V2TIM_MSG_STATUS_SEND_SUCC == v2TIMMessage.getStatus() && messageBean instanceof SoundMessageBean)
                && presenter.getConvertedTextStatus(messageBean.getV2TIMMessage()) != VoiceToTextProvider.MSG_VOICE_TO_TEXT_STATUS_SHOWN) {
                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setWeight(2900);
                extensionInfo.setText(appContext.getString(R.string.convert_to_text));
                if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID)) {
                    extensionInfo.setIcon(R.drawable.pop_menu_voice_to_text);
                } else {
                    extensionInfo.setIcon(R.drawable.pop_menu_voice_to_text);
                }

                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        voiceToTextMessageLayoutProxy.convertMessage(messageBean);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        }

        return null;
    }

    @Override
    public boolean onRaiseExtension(String extensionID, View parentView, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessageBottom.CLASSIC_EXTENSION_ID)
            || TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessageBottom.MINIMALIST_EXTENSION_ID)) {
            if (param == null) {
                return false;
            }

            ViewGroup viewGroup = null;
            if (parentView instanceof ViewGroup) {
                viewGroup = (ViewGroup) parentView;
            }
            if (viewGroup == null) {
                return false;
            }

            TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIConstants.TUIChat.MESSAGE_BEAN);
            if (messageBean == null) {
                return false;
            }
            V2TIMMessage v2TIMMessage = messageBean.getV2TIMMessage();
            if (v2TIMMessage == null) {
                return false;
            }

            if (v2TIMMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_SOUND) {
                return false;
            }

            RecyclerView recyclerView = (RecyclerView) param.get(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW);
            BaseFragment fragment = null;
            Object fragmentObject = param.get(TUIConstants.TUIChat.FRAGMENT);
            if (fragmentObject != null && fragmentObject instanceof BaseFragment) {
                fragment = (BaseFragment) fragmentObject;
            }

            if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessageBottom.CLASSIC_EXTENSION_ID)) {
                voiceToTextMessageLayoutProxy.showVoiceToTextView(fragment, TUIConstants.TUIChat.THEME_STYLE_CLASSIC, recyclerView, viewGroup, messageBean);
            } else {
                voiceToTextMessageLayoutProxy.showVoiceToTextView(fragment, TUIConstants.TUIChat.THEME_STYLE_MINIMALIST, recyclerView, viewGroup, messageBean);
            }

            return true;
        }

        return false;
    }

    private Object getOrDefault(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }
}
