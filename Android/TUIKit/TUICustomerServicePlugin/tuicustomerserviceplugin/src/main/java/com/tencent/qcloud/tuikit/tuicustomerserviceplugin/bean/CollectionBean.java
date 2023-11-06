package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import java.io.Serializable;
import java.util.List;

public class CollectionBean implements Serializable {
    public static final int COLLECTION_TYPE_SUGGEST = 0;
    public static final int COLLECTION_TYPE_FORM = 1;
    private String head;
    private List<FormItem> itemList;
    private FormItem selectedItem;
    private int type;

    public String getHead() {
        return head;
    }

    public void setHead(String head) {
        this.head = head;
    }

    public List<FormItem> getItemList() {
        return itemList;
    }

    public void setItemList(List<FormItem> itemList) {
        this.itemList = itemList;
    }

    public FormItem getSelectedItem() {
        return selectedItem;
    }

    public void setSelectedItem(FormItem selectedItem) {
        this.selectedItem = selectedItem;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public static class FormItem {
        private String content;
        private String description;

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }
    }
}
