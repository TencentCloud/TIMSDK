package com.tencent.qcloud.uikit.api.contact;

import com.tencent.qcloud.uikit.business.contact.view.event.ContactPanelEvent;
import com.tencent.qcloud.uikit.common.component.action.PopMenuAction;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

import java.util.List;


public interface IContactPanel {

    PageTitleBar getTitleBar();

    void setContactPanelEvent(ContactPanelEvent event);

    void addPopActions(List<PopMenuAction> actions);

    void setDataProvider(IContactDataProvider provider);

    IContactDataProvider setProxyDataProvider(IContactDataProvider provider);

    void refreshData();

    void initDefault();
}

