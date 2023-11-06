package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.content.Intent;
import android.net.Uri;
import android.text.TextUtils;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.component.impl.GlideEngine;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CardBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CardMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;

public class CardHolder extends MessageContentHolder {
    private ImageView ivPic;
    private TextView tvHeader;
    private TextView tvDesc;
    public CardHolder(View itemView) {
        super(itemView);
        ivPic = itemView.findViewById(R.id.iv_card_pic);
        tvHeader = itemView.findViewById(R.id.tv_card_header);
        tvDesc = itemView.findViewById(R.id.tv_card_desc);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_card;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        CardMessageBean cardMessageBean = (CardMessageBean) msg;
        TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
        presenter.setMessage(cardMessageBean);
        CardBean cardBean = cardMessageBean.getCardBean();
        if (cardBean == null) {
            return;
        }

        tvHeader.setText(cardBean.getHeader());
        tvDesc.setText(cardBean.getDesc());
        GlideEngine.loadImageSetDefault(ivPic, cardBean.getPic(), R.drawable.product_picture_fail);
        msgContentFrame.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (!TextUtils.isEmpty(cardBean.getUrl())) {
                    Intent intent = new Intent();
                    intent.setAction("android.intent.action.VIEW");
                    Uri contentUrl = Uri.parse(cardBean.getUrl());
                    intent.setData(contentUrl);
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
                    TUIChatService.getAppContext().startActivity(intent);
                }
            }
        });
    }
}
