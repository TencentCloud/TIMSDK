package com.tencent.qcloud.tuikit.tuichatbotplugin.classicui.widget;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.TextView;
import androidx.annotation.NonNull;
import com.bumptech.glide.Glide;
import com.bumptech.glide.RequestBuilder;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichatbotplugin.R;
import com.tencent.qcloud.tuikit.tuichatbotplugin.bean.RichTextMessageBean;
import com.tencent.qcloud.tuikit.tuichatbotplugin.util.CustomLinkSpanFactory;
import io.noties.markwon.AbstractMarkwonPlugin;
import io.noties.markwon.Markwon;
import io.noties.markwon.MarkwonSpansFactory;
import io.noties.markwon.image.AsyncDrawable;
import io.noties.markwon.image.glide.GlideImagesPlugin;
import io.noties.markwon.movement.MovementMethodPlugin;
import org.commonmark.node.Link;

public class RichTextHolder extends MessageContentHolder {
    private TextView markdownTextView;
    private Markwon markwon;
    public RichTextHolder(View itemView) {
        super(itemView);
        markdownTextView = itemView.findViewById(R.id.rich_text_view);
        Context context = itemView.getContext();
        markwon = Markwon
                      .builder(context)
                      // automatically create Glide instance
                      .usePlugin(GlideImagesPlugin.create(context))
                      // use supplied Glide instance
                      .usePlugin(GlideImagesPlugin.create(Glide.with(context)))
                      // if you need more control
                      .usePlugin(GlideImagesPlugin.create(new GlideImagesPlugin.GlideStore() {
                          @NonNull
                          @Override
                          public RequestBuilder<Drawable> load(@NonNull AsyncDrawable drawable) {
                              return Glide.with(context).load(drawable.getDestination());
                          }

                          @Override
                          public void cancel(@NonNull Target<?> target) {
                              Glide.with(context).clear(target);
                          }
                      }))
                      .usePlugin(MovementMethodPlugin.link())
                      .usePlugin(new AbstractMarkwonPlugin() {
                          @Override
                          public void configureSpansFactory(@NonNull MarkwonSpansFactory.Builder builder) {
                              builder.setFactory(Link.class, new CustomLinkSpanFactory());
                          }
                      })
                      .build();
    }

    @Override
    public int getVariableLayout() {
        return R.layout.chat_bot_rich_text_layout;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        int paddingHorizontal = itemView.getResources().getDimensionPixelSize(com.tencent.qcloud.tuikit.timcommon.R.dimen.chat_message_area_padding_left_right);
        int paddingVertical = itemView.getResources().getDimensionPixelSize(com.tencent.qcloud.tuikit.timcommon.R.dimen.chat_message_area_padding_top_bottom);
        msgArea.setPaddingRelative(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical);

        RichTextMessageBean richTextMessageBean = (RichTextMessageBean) msg;
        markwon.setMarkdown(markdownTextView, richTextMessageBean.getExtra());
    }
}
