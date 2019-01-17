package com.tencent.qcloud.uikit.api.contact;

import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;

import java.util.List;

/**
 * Created by valexhuang on 2018/6/22.
 */

public interface IContactDataProvider {

    public List<ContactInfoBean> getDataSource();

    public void addContact(ContactInfoBean contact);

    public void deleteContact(String contactName);

    public void updateContact(ContactInfoBean contact);
}
