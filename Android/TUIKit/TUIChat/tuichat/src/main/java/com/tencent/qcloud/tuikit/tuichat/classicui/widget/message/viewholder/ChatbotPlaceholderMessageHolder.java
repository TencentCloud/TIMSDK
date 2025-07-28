package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.graphics.drawable.Animatable;
import android.graphics.drawable.Drawable;
import android.view.View;
import android.widget.ImageView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ChatbotPlaceholderMessageBean;

public class ChatbotPlaceholderMessageHolder extends MessageContentHolder {
    ImageView imageView;

    public ChatbotPlaceholderMessageHolder(View itemView) {
        super(itemView);
        imageView = itemView.findViewById(R.id.content_image_iv);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_content_chatbot_placeholder;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        if (!(msg instanceof ChatbotPlaceholderMessageBean)) {
            return;
        }
        Drawable drawable = imageView.getDrawable();
        if (drawable instanceof Animatable) {
            ((Animatable) drawable).start();
        }
        setOnItemClickListener(null);
    }
}
