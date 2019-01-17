package com.tencent.qcloud.uikit.api.infos;

import com.tencent.qcloud.uikit.common.component.info.InfoItemAction;
import com.tencent.qcloud.uikit.business.chat.c2c.model.PersonalInfoBean;
import com.tencent.qcloud.uikit.common.component.titlebar.PageTitleBar;

import java.util.List;

/**
 * Created by valxehuang on 2018/7/17.
 */

public interface IPersonalInfoPanel {
    void initPersonalInfo(PersonalInfoBean info);

    void setPersonalInfoPanelEvent(PersonalInfoPanelEvent event);

    void initDefault();

    public void addInfoItem(List<InfoItemAction> items, int group, int index);

    PageTitleBar getTitleBar();

}
