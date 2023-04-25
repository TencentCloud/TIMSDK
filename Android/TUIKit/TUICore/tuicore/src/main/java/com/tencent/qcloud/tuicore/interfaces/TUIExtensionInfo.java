package com.tencent.qcloud.tuicore.interfaces;

import java.util.Map;

public class TUIExtensionInfo implements Comparable<TUIExtensionInfo> {
    private int weight;
    private String text;
    private Object icon;

    private Map<String, Object> data;

    private TUIExtensionEventListener extensionListener;

    public int getWeight() {
        return weight;
    }

    public void setWeight(int weight) {
        this.weight = weight;
    }

    public String getText() {
        return text;
    }

    public void setText(String text) {
        this.text = text;
    }

    public Object getIcon() {
        return icon;
    }

    public void setIcon(Object icon) {
        this.icon = icon;
    }

    public Map<String, Object> getData() {
        return data;
    }

    public void setData(Map<String, Object> data) {
        this.data = data;
    }

    public void setExtensionListener(TUIExtensionEventListener extensionListener) {
        this.extensionListener = extensionListener;
    }

    public TUIExtensionEventListener getExtensionListener() {
        return extensionListener;
    }

    @Override
    public int compareTo(TUIExtensionInfo o) {
        return o.getWeight() - this.weight;
    }
}
