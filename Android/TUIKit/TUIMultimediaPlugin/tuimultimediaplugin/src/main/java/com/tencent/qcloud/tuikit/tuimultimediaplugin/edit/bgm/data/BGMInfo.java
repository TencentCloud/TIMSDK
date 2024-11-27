package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.tencent.liteav.base.util.LiteavLog;
import java.io.FileWriter;
import java.util.LinkedList;
import java.util.List;

public class BGMInfo {

    @SerializedName("bgm_list")
    private List<BGMType> mBGMTypeItemList;

    public int getSize() {
        return mBGMTypeItemList.size();
    }

    public void addBGMItem(BGMInfo.ItemPosition position, BGMItem bgmItem) {
        if (position.bgmTypeIndex < 0) {
            return;
        }

        if (mBGMTypeItemList == null) {
            mBGMTypeItemList = new LinkedList<>();
        }

        while (position.bgmTypeIndex + 1 - mBGMTypeItemList.size() > 0) {
            mBGMTypeItemList.add(new BGMType());
        }
        mBGMTypeItemList.get(position.bgmTypeIndex).addBGMItem(position.bgmItemIndex, bgmItem);
    }

    public int getBGMTypeSize() {
        return mBGMTypeItemList.size();
    }

    public BGMType getBGMType(int BGMTypeIndex) {
        if (mBGMTypeItemList == null) {
            return null;
        }

        if (BGMTypeIndex < 0 || BGMTypeIndex >= mBGMTypeItemList.size()) {
            return null;
        }
        return mBGMTypeItemList.get(BGMTypeIndex);
    }

    public BGMItem getBGMItem(BGMInfo.ItemPosition itemPosition) {
        BGMType typeInfo = getBGMType(itemPosition.bgmTypeIndex);
        return typeInfo != null ? typeInfo.getBGMItem(itemPosition.bgmItemIndex) : null;
    }

    public void addBGMType(BGMType bgmType) {
        if (mBGMTypeItemList == null) {
            mBGMTypeItemList = new LinkedList<>();
        }

        mBGMTypeItemList.add(bgmType);
    }

    public void append(BGMInfo otherSetInfo) {
        if (otherSetInfo == null) {
            return;
        }

        List<BGMType> otherBGMTypeItemList = otherSetInfo.mBGMTypeItemList;
        if (otherBGMTypeItemList == null) {
            return;
        }

        for (int i = 0; i < otherBGMTypeItemList.size(); i++) {
            BGMType typeItemInfo = otherBGMTypeItemList.get(i);
            if (typeItemInfo == null) {
                continue;
            }

            List<BGMItem> itemInfoList = typeItemInfo.getBGMItemList();
            if (itemInfoList == null) {
                continue;
            }
            for (BGMItem itemInfo : itemInfoList) {
                addBGMItem(new ItemPosition(i, 0), itemInfo);
            }
        }
    }

    public void saveToJsonFile(String filePath) {
        Gson gson = new Gson();
        try {
            FileWriter fileWriter = new FileWriter(filePath);
            gson.toJson(this, fileWriter);
            fileWriter.flush();
            fileWriter.close();
        } catch (Exception e) {
            LiteavLog.e("save json file error", e.toString());
        }
    }

    public static class ItemPosition {

        public final int bgmTypeIndex;
        public final int bgmItemIndex;

        public ItemPosition(int bgmTypeIndex, int bgmItemIndex) {
            this.bgmTypeIndex = bgmTypeIndex;
            this.bgmItemIndex = bgmItemIndex;
        }

        public boolean equals(BGMInfo.ItemPosition other) {
            if (other == null) {
                return false;
            }
            return bgmTypeIndex == other.bgmTypeIndex && bgmItemIndex == other.bgmItemIndex;
        }
    }
}
