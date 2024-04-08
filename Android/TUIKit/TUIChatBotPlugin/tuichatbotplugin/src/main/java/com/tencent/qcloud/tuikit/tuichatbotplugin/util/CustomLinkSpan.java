package com.tencent.qcloud.tuikit.tuichatbotplugin.util;

import android.text.TextPaint;
import androidx.annotation.NonNull;
import io.noties.markwon.LinkResolver;
import io.noties.markwon.core.MarkwonTheme;
import io.noties.markwon.core.spans.LinkSpan;

public class CustomLinkSpan extends LinkSpan {
    public CustomLinkSpan(@NonNull MarkwonTheme theme, @NonNull String link, @NonNull LinkResolver resolver) {
        super(theme, link, resolver);
    }

    @Override
    public void updateDrawState(@NonNull TextPaint ds) {
        super.updateDrawState(ds);
        ds.setUnderlineText(false);
    }
}
