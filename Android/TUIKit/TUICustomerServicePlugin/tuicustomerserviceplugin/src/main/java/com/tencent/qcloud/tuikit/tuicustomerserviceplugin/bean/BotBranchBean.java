package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import java.io.Serializable;
import java.util.List;

public class BotBranchBean implements Serializable {
    private String subType;
    private String title;
    private String content;
    private List<Item> itemList;

    public String getSubType() {
        return subType;
    }

    public void setSubType(String subType) {
        this.subType = subType;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public List<Item> getItemList() {
        return itemList;
    }

    public void setItemList(List<Item> itemList) {
        this.itemList = itemList;
    }

    public static class Item implements Serializable {
        private String content;

        public String getContent() {
            return content;
        }

        public void setContent(String content) {
            this.content = content;
        }

    }
}
