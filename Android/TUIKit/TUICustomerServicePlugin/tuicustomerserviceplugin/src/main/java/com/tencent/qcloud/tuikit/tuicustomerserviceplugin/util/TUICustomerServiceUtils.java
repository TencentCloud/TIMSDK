package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util;

import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.text.Spannable;
import android.text.SpannableString;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.View;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.imsdk.v2.V2TIMValueCallback;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUIThemeManager;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServiceConstants;

public class TUICustomerServiceUtils {

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, String module, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(module, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnError(IUIKitCallback<T> callBack, int errCode, String desc) {
        if (callBack != null) {
            callBack.onError(null, errCode, ErrorMessageConverter.convertIMError(errCode, desc));
        }
    }

    public static <T> void callbackOnSuccess(IUIKitCallback<T> callBack, T data) {
        if (callBack != null) {
            callBack.onSuccess(data);
        }
    }

    public static void checkCustomerServiceAbility(long param, IUIKitCallback<Boolean> callback) {
        V2TIMManager.getInstance().callExperimentalAPI("isCommercialAbilityEnabled", param, new V2TIMValueCallback<Object>() {
            @Override
            public void onError(int code, String desc) {
                callbackOnError(callback, code, desc);
            }

            @Override
            public void onSuccess(Object object) {
                boolean enabled = ((Integer) object > 0);

                if (callback != null) {
                    callback.onSuccess(enabled);
                }
            }
        });
    }

    public static void showNotSupportDialog(Context context) {
        String content = context.getResources().getString(R.string.customer_service_unsupport_tips);
        String buyingGuidelines = context.getResources().getString(R.string.customer_service_buying_guidelines);
        int buyingGuidelinesIndex = content.lastIndexOf(buyingGuidelines);
        final int foregroundColor = context.getResources().getColor(TUIThemeManager.getAttrResId(context, com.tencent.qcloud.tuicore.R.attr.core_primary_color));
        SpannableString spannedString = new SpannableString(content);
        ForegroundColorSpan colorSpan = new ForegroundColorSpan(foregroundColor);
        spannedString.setSpan(colorSpan, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);
        ClickableSpan clickableSpan = new ClickableSpan() {
            @Override
            public void onClick(View view) {
                openWebUrl(context, TUIConstants.BuyingFeature.BUYING_GROUP_CHAT);
            }

            @Override
            public void updateDrawState(TextPaint ds) {
                ds.setUnderlineText(false);
            }
        };
        spannedString.setSpan(clickableSpan, buyingGuidelinesIndex, buyingGuidelinesIndex + buyingGuidelines.length(), Spannable.SPAN_EXCLUSIVE_INCLUSIVE);

        TUIKitDialog.TUIIMUpdateDialog.getInstance()
                .createDialog(context)
                .setShowOnlyDebug(true)
                .setMovementMethod(LinkMovementMethod.getInstance())
                .setHighlightColor(Color.TRANSPARENT)
                .setCancelable(true)
                .setCancelOutside(true)
                .setTitle(spannedString)
                .setDialogWidth(0.75f)
                .setDialogFeatureName(TUIConstants.BuyingFeature.BUYING_FEATURE_MESSAGE_RECEIPT)
                .setPositiveButton(context.getResources().getString(R.string.customer_service_i_know),
                        new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                TUIKitDialog.TUIIMUpdateDialog.getInstance().dismiss();
                            }
                        })
                .show();
    }

    private static void openWebUrl(Context context, String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        context.startActivity(intent);
    }
}
