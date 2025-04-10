package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import android.content.ActivityNotFoundException;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.net.Uri;
import android.text.SpannableString;
import android.text.Spanned;
import android.text.TextPaint;
import android.text.method.LinkMovementMethod;
import android.text.style.ClickableSpan;
import android.text.style.ForegroundColorSpan;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AlertDialog;
import com.google.android.material.dialog.MaterialAlertDialogBuilder;
import com.tencent.imsdk.BuildConfig;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaSignatureChecker;
import com.tencent.qcloud.tuikit.tuimultimediacore.utils.TUIMultimediaLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import java.util.Objects;

public class TUIMultimediaAuthorizationPrompter {

    private static final String IM_MULTIMEDIA_PLUGIN_DOCUMENT_URL = "https://cloud.tencent.com/document/product/269/113290";

    public static boolean verifyPermissionGranted(Context context) {
        if (TUIMultimediaSignatureChecker.getInstance().isSupportFunction()) {
            return true;
        }

        TUIMultimediaLog.e("AuthorizationPrompter", "Signature checker do not support function");
        if (context != null) {
            showPrompterDialog(context);
        }
        return false;
    }

    private static void showPrompterDialog(Context context) {
        if (!BuildConfig.DEBUG) {
            return;
        }

        View dialogView = LayoutInflater.from(context).inflate(R.layout.multimedia_plugin_authorization_prompter, null);

        TextView linkText = dialogView.findViewById(R.id.authorization_prompter_accessing_documents_tv);
        setHyperlink(linkText,TUIMultimediaResourceUtils.getString(R.string.authorization_prompter_accessing_documents),
                TUIMultimediaResourceUtils.getString(R.string.authorization_prompter_documents_title),
                IM_MULTIMEDIA_PLUGIN_DOCUMENT_URL);

        MaterialAlertDialogBuilder builder = new MaterialAlertDialogBuilder(context, R.style.AuthorizationPrompterDialog)
                .setView(dialogView)
                .setPositiveButton(TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_confirm), null)
                .setOnDismissListener(dialog -> {
                });

        AlertDialog dialog = builder.create();

        Window window = dialog.getWindow();
        if (window != null) {
            WindowManager.LayoutParams params = window.getAttributes();
            params.width = WindowManager.LayoutParams.WRAP_CONTENT;
            params.height = WindowManager.LayoutParams.WRAP_CONTENT;
            window.setAttributes(params);
        }

        Objects.requireNonNull(dialog.getWindow())
                .setBackgroundDrawableResource(R.drawable.multimedia_plugin_bg_dialog_rounded);

        dialog.show();

        Button positiveButton = dialog.getButton(AlertDialog.BUTTON_POSITIVE);
        if (positiveButton != null) {
            ViewGroup.MarginLayoutParams params = (ViewGroup.MarginLayoutParams) positiveButton.getLayoutParams();
            params.leftMargin = TUIMultimediaResourceUtils.dip2px(context, 24);
        }
    }

    private static void setHyperlink(TextView textView, String fullText,
            String linkText, String url) {
        SpannableString spannable = new SpannableString(fullText);

        int start = fullText.indexOf(linkText);
        int end = start + linkText.length();

        if (start == -1) {
            return;
        }

        ClickableSpan clickableSpan = new ClickableSpan() {
            @Override
            public void onClick(@NonNull View widget) {
                openUrl(widget.getContext(), url);
            }

            @Override
            public void updateDrawState(@NonNull TextPaint ds) {
                super.updateDrawState(ds);
                ds.setUnderlineText(true);
            }
        };

        spannable.setSpan(clickableSpan, start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);
        spannable.setSpan(new ForegroundColorSpan(Color.parseColor("#007AFF")),
                start, end, Spanned.SPAN_EXCLUSIVE_EXCLUSIVE);

        textView.setText(spannable);
        textView.setMovementMethod(LinkMovementMethod.getInstance());
        textView.setHighlightColor(Color.TRANSPARENT);
    }

    private static void openUrl(Context context, String url) {
        try {
            Intent intent = new Intent(Intent.ACTION_VIEW, Uri.parse(url));
            context.startActivity(intent);
        } catch (ActivityNotFoundException e) {
            Toast.makeText(context,TUIMultimediaResourceUtils.getString(R.string.link_error), Toast.LENGTH_SHORT).show();
        }
    }
}