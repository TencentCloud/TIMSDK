package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data;

import com.google.gson.annotations.SerializedName;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import java.util.LinkedList;
import java.util.List;

public class BGMType {

    @SerializedName("bgm_type_name")
    private String mTypeName;

    @SerializedName("bgm_item_list")
    private List<BGMItem> mBGMItemList;

    public void addBGMItem(int itemIndex, BGMItem bgmItem) {
        if (itemIndex < 0) {
            return;
        }

        if (mBGMItemList == null) {
            mBGMItemList = new LinkedList<>();
        }

        mBGMItemList.add(itemIndex, bgmItem);
    }

    public boolean isContainSameBGM(BGMItem bgmItem) {
        if (bgmItem == null) {
            return true;
        }

        if (mBGMItemList == null) {
            return false;
        }

        for (BGMItem item : mBGMItemList) {
            if (bgmItem.isSameBGM(item)) {
                return true;
            }
        }

        return false;
    }

    public BGMItem getBGMItem(int itemIndex) {
        if (itemIndex < 0 || itemIndex >= mBGMItemList.size()) {
            return null;
        }
        return mBGMItemList.get(itemIndex);
    }

    public List<BGMItem> getBGMItemList() {
        return mBGMItemList;
    }

    public int getItemSize() {
        return mBGMItemList.size();
    }

    public String getTypeName() {
        if (mTypeName.startsWith(TUIMultimediaResourceUtils.STRING_RESOURCE_PREFIX)) {
            return TUIMultimediaResourceUtils.getString(mTypeName);
        }
        return mTypeName;
    }

    public void setTypeName(String typeName) {
        mTypeName = typeName;
    }
}
