package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.content.Intent;
import android.net.Uri;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bumptech.glide.load.DataSource;
import com.bumptech.glide.load.engine.GlideException;
import com.bumptech.glide.request.RequestListener;
import com.bumptech.glide.request.target.Target;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.CustomOrderMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

public class CustomOrderMessageHolder extends MessageContentHolder {
    private ImageView imageView;
    private TextView titleView;
    private TextView contentView;
    private TextView priceView;

    public CustomOrderMessageHolder(View itemView) {
        super(itemView);
        imageView = itemView.findViewById(R.id.content_image_iv);
        titleView = itemView.findViewById(R.id.order_title);
        contentView = itemView.findViewById(R.id.order_description);
        priceView = itemView.findViewById(R.id.order_price);
    }

    public static final String TAG = CustomOrderMessageHolder.class.getSimpleName();

    @Override
    public int getVariableLayout() {
        return R.layout.custom_order_message_layout;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        String title = "";
        String content = "";
        String price = "";
        String link = "";
        String imageUrl = "";
        if (msg instanceof CustomOrderMessageBean) {
            title = ((CustomOrderMessageBean) msg).getTitle();
            content = ((CustomOrderMessageBean) msg).getDescription();
            price = ((CustomOrderMessageBean) msg).getPrice();
            link = ((CustomOrderMessageBean) msg).getLink();
            imageUrl = ((CustomOrderMessageBean) msg).getImageUrl();
        }

        GlideEngine.loadCornerImageWithoutPlaceHolder(imageView, imageUrl, new RequestListener() {
            @Override
            public boolean onLoadFailed(@Nullable GlideException e, Object model, Target target, boolean isFirstResource) {
                TUIChatLog.e(TAG, "onLoadFailed e=" + e);
                return false;
            }

            @Override
            public boolean onResourceReady(Object resource, Object model, Target target, DataSource dataSource, boolean isFirstResource) {
                return false;
            }
        }, ScreenUtil.dip2px(4));

        titleView.setText(title);
        contentView.setText(content);
        priceView.setText(price);
        msgContentFrame.setClickable(true);
        String finalLink = link;
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent();
                intent.setAction("android.intent.action.VIEW");
                Uri contentUrl = Uri.parse(finalLink);
                intent.setData(contentUrl);
                intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                TUIChatService.getAppContext().startActivity(intent);
            }
        });
    }
}
