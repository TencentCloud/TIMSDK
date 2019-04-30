package com.tencent.qcloud.uikit.business.contact.model;

import com.tencent.qcloud.uikit.api.contact.IContactDataProvider;

import java.util.ArrayList;
import java.util.List;


public class ContactProvider implements IContactDataProvider {
    public List<ContactInfoBean> dataSource = new ArrayList<>();

    @Override
    public List<ContactInfoBean> getDataSource() {
        return dataSource;
    }

    @Override
    public void addContact(ContactInfoBean contact) {
        dataSource.add(contact);
    }

    @Override
    public void deleteContact(String identifier) {

    }

    @Override
    public void updateContact(ContactInfoBean contact) {

    }
}
