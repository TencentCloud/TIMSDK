package com.tencent.qcloud.uikit.api.contact;

import com.tencent.qcloud.uikit.business.contact.model.ContactInfoBean;

import java.util.List;


public interface IContactDataProvider {

    List<ContactInfoBean> getDataSource();

    void addContact(ContactInfoBean contact);

    void deleteContact(String contactName);

    void updateContact(ContactInfoBean contact);
}
