package com.tencent.qcloud.tuikit.tuicustomerserviceplugin.bean;

import java.io.Serializable;

public class CardBean implements Serializable {
    private String header;
    private String desc;
    private String pic;
    private String url;

    public String getHeader() {
        return header;
    }

    public void setHeader(String header) {
        this.header = header;
    }

    public String getDesc() {
        return desc;
    }

    public void setDesc(String desc) {
        this.desc = desc;
    }

    public String getPic() {
        return pic;
    }

    public void setPic(String pic) {
        this.pic = pic;
    }

    public String getUrl() {
        return url;
    }

    public void setUrl(String url) {
        this.url = url;
    }
}
