package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.config;

import com.tencent.qcloud.tuikit.tuicustomerserviceplugin.classicui.widget.InputViewFloatLayerProxy;

public class TUIInputViewFloatLayerData {
    private String content;
    private InputViewFloatLayerProxy.OnItemClickListener OnItemClickListener;

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public InputViewFloatLayerProxy.OnItemClickListener getOnItemClickListener() {
        return OnItemClickListener;
    }

    public void setOnItemClickListener(InputViewFloatLayerProxy.OnItemClickListener onItemClickListener) {
        OnItemClickListener = onItemClickListener;
    }
}
