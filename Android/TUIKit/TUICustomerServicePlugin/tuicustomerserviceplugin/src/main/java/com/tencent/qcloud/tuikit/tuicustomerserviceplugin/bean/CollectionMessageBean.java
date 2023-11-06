package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServicePluginService;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util.TUICustomerServiceMessageParser;

public class CollectionMessageBean extends TUIMessageBean {
    private CollectionBean collectionBean;

    public CollectionBean getCollectionBean() {
        return collectionBean;
    }

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        collectionBean = TUICustomerServiceMessageParser.getCollectionInfo(v2TIMMessage);
        if (collectionBean != null) {
            setExtra(collectionBean.getHead());
        } else {
            String text = TUICustomerServicePluginService.getAppContext().getString(com.tencent.qcloud.tuikit.timcommon.R.string.timcommon_no_support_msg);
            setExtra(text);
        }
    }

    @Override
    public Class<? extends TUIReplyQuoteBean<?>> getReplyQuoteBeanClass() {
        return CollectionMessageReplyQuoteBean.class;
    }
}
