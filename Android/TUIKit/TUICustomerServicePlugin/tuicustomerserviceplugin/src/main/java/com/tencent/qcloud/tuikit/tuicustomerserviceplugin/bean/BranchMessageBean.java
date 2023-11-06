package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIReplyQuoteBean;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.TUICustomerServicePluginService;
import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.util.TUICustomerServiceMessageParser;

public class BranchMessageBean extends TUIMessageBean {
    private BranchBean branchBean;

    public BranchBean getBranchBean() {
        return branchBean;
    }

    @Override
    public String onGetDisplayString() {
        return getExtra();
    }

    @Override
    public void onProcessMessage(V2TIMMessage v2TIMMessage) {
        branchBean = TUICustomerServiceMessageParser.getBranchInfo(v2TIMMessage);
        if (branchBean != null) {
            setExtra(branchBean.getHead());
        } else {
            String text = TUICustomerServicePluginService.getAppContext().getString(com.tencent.qcloud.tuikit.timcommon.R.string.timcommon_no_support_msg);
            setExtra(text);
        }
    }

    @Override
    public Class<? extends TUIReplyQuoteBean<?>> getReplyQuoteBeanClass() {
        return BranchMessageReplyQuoteBean.class;
    }
}
