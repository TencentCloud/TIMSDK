package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget;

import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.TextView;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.R;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean.CollectionMessageBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.presenter.TUICustomerServicePresenter;

public class CollectionHolder extends MessageContentHolder {
    private ViewGroup vgCollectionForm;
    private ViewGroup vgCollectionSuggest;
    private TextView tvTitle;
    private CollectionListLayout listLayout;
    private EditText etSuggest;
    private TextView tvSendSuggest;

    public CollectionHolder(View itemView) {
        super(itemView);
        vgCollectionForm = itemView.findViewById(R.id.ll_collection_form);
        vgCollectionSuggest = itemView.findViewById(R.id.rl_collection_suggest);
        tvTitle = itemView.findViewById(R.id.tv_collection_title);
        listLayout = itemView.findViewById(R.id.collection_item_list);
        etSuggest = itemView.findViewById(R.id.et_suggest);
        tvSendSuggest = itemView.findViewById(R.id.tv_send_suggest);
    }

    @Override
    public int getVariableLayout() {
        return R.layout.message_adapter_collection;
    }

    @Override
    public void layoutVariableViews(TUIMessageBean msg, int position) {
        CollectionMessageBean collectionMessageBean = (CollectionMessageBean) msg;
        TUICustomerServicePresenter presenter = new TUICustomerServicePresenter();
        presenter.setMessage(collectionMessageBean);
        CollectionBean collectionBean = collectionMessageBean.getCollectionBean();
        if (collectionBean == null) {
            return;
        }

        CollectionBean.FormItem selectedItem = collectionBean.getSelectedItem();
        if (collectionBean.getType() == CollectionBean.COLLECTION_TYPE_FORM) {
            vgCollectionForm.setVisibility(View.VISIBLE);
            vgCollectionSuggest.setVisibility(View.GONE);
            if (TextUtils.isEmpty(collectionBean.getHead())) {
                tvTitle.setText("");
                tvTitle.setVisibility(View.GONE);
            } else {
                tvTitle.setVisibility(View.VISIBLE);
                tvTitle.setText(collectionBean.getHead());
            }
            listLayout.setPresenter(presenter);
            listLayout.setCollectionItemList(collectionBean.getItemList());
        } else if (collectionBean.getType() == CollectionBean.COLLECTION_TYPE_SUGGEST) {
            vgCollectionForm.setVisibility(View.GONE);
            vgCollectionSuggest.setVisibility(View.VISIBLE);
            if (selectedItem != null) {
                tvSendSuggest.setOnClickListener(null);
                etSuggest.setText(selectedItem.getContent());
                etSuggest.setEnabled(false);
            } else {
                etSuggest.setEnabled(true);
                tvSendSuggest.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        String suggestContent = etSuggest.getText().toString();
                        if (!TextUtils.isEmpty(suggestContent)) {
                            presenter.sendTextMessage(msg.getUserId(), suggestContent);
                        }
                    }
                });
            }
        }
    }
}
