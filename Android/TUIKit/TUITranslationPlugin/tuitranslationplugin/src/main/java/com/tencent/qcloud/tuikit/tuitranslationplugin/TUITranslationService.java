package com.tencent.qcloud.tuikit.tuitranslationplugin;

import android.content.Context;
import android.os.Bundle;
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
import com.tencent.qcloud.tuikit.timcommon.component.LineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.MinimalistLineControllerView;
import com.tencent.qcloud.tuikit.timcommon.component.activities.SelectionActivity;
import com.tencent.qcloud.tuikit.timcommon.component.fragments.BaseFragment;
import com.tencent.qcloud.tuikit.tuichat.bean.message.QuoteMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TextMessageBean;
import com.tencent.qcloud.tuikit.tuitranslationplugin.model.TranslationProvider;
import com.tencent.qcloud.tuikit.tuitranslationplugin.presenter.TranslationPresenter;
import com.tencent.qcloud.tuikit.tuitranslationplugin.widget.TranslationMessageLayoutProxy;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUITranslationService extends ServiceInitializer implements ITUIExtension {
    public static final String TAG = TUITranslationService.class.getSimpleName();
    private static TUITranslationService instance;

    public static TUITranslationService getInstance() {
        return instance;
    }

    private Context appContext;
    private TranslationMessageLayoutProxy translationMessageLayoutProxy;

    @Override
    public void init(Context context) {
        appContext = context;
        instance = this;
        initExtension();
        translationMessageLayoutProxy = new TranslationMessageLayoutProxy();
    }

    private void initExtension() {
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessagePopMenu.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessageBottom.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TUIChat.Extension.MessageBottom.MINIMALIST_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TIMAppKit.Extension.ProfileSettings.CLASSIC_EXTENSION_ID, this);
        TUICore.registerExtension(TUIConstants.TIMAppKit.Extension.ProfileSettings.MINIMALIST_EXTENSION_ID, this);
    }

    @Override
    public List<TUIExtensionInfo> onGetExtension(String extensionID, Map<String, Object> param) {
        if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID)
            || TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenu.MINIMALIST_EXTENSION_ID)) {
            if (param == null || param.isEmpty()) {
                return null;
            }

            TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIConstants.TUIChat.Extension.MessagePopMenu.MESSAGE_BEAN);
            TranslationPresenter presenter = new TranslationPresenter();
            if ((messageBean instanceof TextMessageBean || messageBean instanceof QuoteMessageBean)
                && presenter.getTranslationStatus(messageBean.getV2TIMMessage()) != TranslationProvider.MSG_TRANSLATE_STATUS_SHOWN) {
                // only select-all-text can be translated
                String selectText = messageBean.getSelectText();
                if (!TextUtils.isEmpty(selectText)) {
                    String text = messageBean.getExtra();
                    if (!text.equals(selectText)) {
                        return null;
                    }
                }

                TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
                extensionInfo.setWeight(3000);
                extensionInfo.setText(appContext.getString(R.string.translate_action));
                if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessagePopMenu.CLASSIC_EXTENSION_ID)) {
                    extensionInfo.setIcon(R.drawable.pop_menu_translate);
                } else {
                    extensionInfo.setIcon(R.drawable.minimalist_pop_menu_translation);
                }

                extensionInfo.setExtensionListener(new TUIExtensionEventListener() {
                    @Override
                    public void onClicked(Map<String, Object> param) {
                        translationMessageLayoutProxy.translateMessage(messageBean);
                    }
                });
                return Collections.singletonList(extensionInfo);
            }
        } else if (TextUtils.equals(extensionID, TUIConstants.TIMAppKit.Extension.ProfileSettings.CLASSIC_EXTENSION_ID)
            || TextUtils.equals(extensionID, TUIConstants.TIMAppKit.Extension.ProfileSettings.MINIMALIST_EXTENSION_ID)) {
            TUIExtensionInfo extensionInfo = new TUIExtensionInfo();
            View translationSelectorView = null;
            if (TextUtils.equals(extensionID, TUIConstants.TIMAppKit.Extension.ProfileSettings.CLASSIC_EXTENSION_ID)) {
                translationSelectorView = View.inflate(appContext, R.layout.profile_settings_translation, null);
                LineControllerView modifyTranslationTargetLanguageView = translationSelectorView.findViewById(R.id.modify_translation_target_language);
                modifyTranslationTargetLanguageView.setCanNav(true);
                modifyTranslationTargetLanguageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        selectLanguage(TUIConstants.TUIChat.THEME_STYLE_CLASSIC, modifyTranslationTargetLanguageView);
                    }
                });
                modifyTranslationTargetLanguageView.setContent(TUITranslationConfigs.getInstance().getTargetLanguageName());
            } else {
                translationSelectorView = View.inflate(appContext, R.layout.minimalist_profile_settings_translation, null);
                MinimalistLineControllerView modifyTranslationTargetLanguageView =
                    translationSelectorView.findViewById(R.id.modify_translation_target_language);
                modifyTranslationTargetLanguageView.setCanNav(true);
                modifyTranslationTargetLanguageView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        selectLanguage(TUIConstants.TUIChat.THEME_STYLE_MINIMALIST, modifyTranslationTargetLanguageView);
                    }
                });
                modifyTranslationTargetLanguageView.setContent(TUITranslationConfigs.getInstance().getTargetLanguageName());
            }

            HashMap<String, Object> paramMap = new HashMap<>();
            paramMap.put(TUIConstants.TIMAppKit.Extension.ProfileSettings.KEY_VIEW, translationSelectorView);
            extensionInfo.setData(paramMap);
            extensionInfo.setWeight(500);
            return Collections.singletonList(extensionInfo);
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

            if (v2TIMMessage.getElemType() != V2TIMMessage.V2TIM_ELEM_TYPE_TEXT) {
                return false;
            }

            RecyclerView recyclerView = (RecyclerView) param.get(TUIConstants.TUIChat.CHAT_RECYCLER_VIEW);
            BaseFragment fragment = null;
            Object fragmentObject = param.get(TUIConstants.TUIChat.FRAGMENT);
            if (fragmentObject != null && fragmentObject instanceof BaseFragment) {
                fragment = (BaseFragment) fragmentObject;
            }

            if (TextUtils.equals(extensionID, TUIConstants.TUIChat.Extension.MessageBottom.CLASSIC_EXTENSION_ID)) {
                translationMessageLayoutProxy.showTranslationView(fragment, TUIConstants.TUIChat.THEME_STYLE_CLASSIC, recyclerView, viewGroup, messageBean);
            } else {
                translationMessageLayoutProxy.showTranslationView(fragment, TUIConstants.TUIChat.THEME_STYLE_MINIMALIST, recyclerView, viewGroup, messageBean);
            }

            return true;
        }

        return false;
    }

    private void selectLanguage(String theme, View modifyTranslationTargetLanguageView) {
        Bundle bundle = new Bundle();
        bundle.putString(SelectionActivity.Selection.TITLE, appContext.getResources().getString(R.string.translation_target_language));
        bundle.putStringArrayList(SelectionActivity.Selection.LIST, TUITranslationConfigs.getInstance().getTargetLanguageNameList());
        String languageName = TUITranslationConfigs.getInstance().getTargetLanguageName();
        int languageIndex = TUITranslationConfigs.getInstance().getTargetLanguageNameList().indexOf(languageName);
        bundle.putInt(SelectionActivity.Selection.DEFAULT_SELECT_ITEM_INDEX, languageIndex);
        SelectionActivity.startListSelection(getContext(), bundle, new SelectionActivity.OnResultReturnListener() {
            @Override
            public void onReturn(Object text) {
                int index = (Integer) text;
                String languageName = TUITranslationConfigs.getInstance().getTargetLanguageNameList().get(index);
                TUITranslationConfigs.getInstance().setTargetLanguageName(languageName);
                if (TextUtils.equals(theme, TUIConstants.TUIChat.THEME_STYLE_CLASSIC)) {
                    ((LineControllerView) modifyTranslationTargetLanguageView).setContent(languageName);
                } else if (TextUtils.equals(theme, TUIConstants.TUIChat.THEME_STYLE_MINIMALIST)) {
                    ((MinimalistLineControllerView) modifyTranslationTargetLanguageView).setContent(languageName);
                }
            }
        });
    }

    private Object getOrDefault(Object value, Object defaultValue) {
        if (value != null) {
            return value;
        }
        return defaultValue;
    }
}
