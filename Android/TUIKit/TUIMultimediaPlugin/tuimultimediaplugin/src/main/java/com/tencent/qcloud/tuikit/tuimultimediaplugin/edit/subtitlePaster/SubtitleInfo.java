package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.subtitlePaster;

import java.util.LinkedList;
import java.util.List;

public class SubtitleInfo {

    public List<String> textList = new LinkedList<>();
    public int textColor;
    public int textSize;

    public String getText() {
        StringBuilder text = new StringBuilder();
        for (String textItem : textList) {
            text.append(textItem);
        }
        return text.toString();
    }

    public boolean equals(SubtitleInfo subtitleInfo) {
        if (subtitleInfo == null) {
            return false;
        }

        if (textColor != subtitleInfo.textColor) {
            return false;
        }

        if (textSize != subtitleInfo.textSize) {
            return false;
        }

        return textList.equals(subtitleInfo.textList);
    }
}
