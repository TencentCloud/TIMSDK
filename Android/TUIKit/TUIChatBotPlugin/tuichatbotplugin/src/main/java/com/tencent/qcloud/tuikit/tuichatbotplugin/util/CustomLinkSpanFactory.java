package com.tencent.qcloud.tuikit.tuichatbotplugin.util;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.noties.markwon.MarkwonConfiguration;
import io.noties.markwon.RenderProps;
import io.noties.markwon.core.CoreProps;
import io.noties.markwon.core.factory.LinkSpanFactory;

public class CustomLinkSpanFactory extends LinkSpanFactory {
    @Nullable
    @Override
    public Object getSpans(@NonNull MarkwonConfiguration configuration, @NonNull RenderProps props) {
        return new CustomLinkSpan(configuration.theme(), CoreProps.LINK_DESTINATION.require(props), configuration.linkResolver());
    }
}
