package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.tencent.liteav.base.util.LiteavLog;
import java.io.FileWriter;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class PicturePasterInfo {

    @SerializedName("paster_type_list")
    private List<PicturePasterType> mPasterTypeItemList;

    public void addPasterItem(ItemPosition position, PicturePasterItem pasterItemInfo) {
        if (position.pasterTypeIndex < 0) {
            return;
        }

        if (mPasterTypeItemList == null) {
            mPasterTypeItemList = new LinkedList<>();
        }

        while (position.pasterTypeIndex + 1 - mPasterTypeItemList.size() > 0) {
            mPasterTypeItemList.add(new PicturePasterType());
        }
        mPasterTypeItemList.get(position.pasterTypeIndex).addPasterItem(position.pasterItemIndex, pasterItemInfo);
    }

    public int getPasterTypeSize() {
        return mPasterTypeItemList != null ? mPasterTypeItemList.size() : 0;
    }

    public PicturePasterType getPasterType(int pasterTypeIndex) {
        if (pasterTypeIndex < 0 || pasterTypeIndex >= getPasterTypeSize()) {
            return null;
        }
        return mPasterTypeItemList.get(pasterTypeIndex);
    }

    public PicturePasterItem getPasterItem(ItemPosition itemPosition) {
        PicturePasterType typeInfo = getPasterType(itemPosition.pasterTypeIndex);
        return typeInfo != null ? typeInfo.getPasterItem(itemPosition.pasterItemIndex) : null;
    }

    public void append(PicturePasterInfo otherSetInfo) {
        if (otherSetInfo == null) {
            return;
        }

        List<PicturePasterType> otherPasterTypeItemList = otherSetInfo.mPasterTypeItemList;
        if (otherPasterTypeItemList == null) {
            return;
        }

        for (int i = 0; i < otherPasterTypeItemList.size(); i++) {
            PicturePasterType typeItemInfo = otherPasterTypeItemList.get(i);
            if (typeItemInfo == null) {
                continue;
            }

            List<PicturePasterItem> itemInfoList = typeItemInfo.getPasterItemList();
            if (itemInfoList == null) {
                continue;
            }

            PicturePasterType pasterType = getPasterType(i);
            int firstFileSelectorIndex = pasterType != null ? pasterType.getFirstFileSelectorIndex() : 0;
            ItemPosition position = new ItemPosition(i, firstFileSelectorIndex + 1);
            Collections.reverse(itemInfoList);
            for (PicturePasterItem itemInfo : itemInfoList) {
                addPasterItem(position, itemInfo);
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

    public void release() {
        if (mPasterTypeItemList == null) {
            return;
        }

        for (PicturePasterType pasterTypeItemInfo : mPasterTypeItemList) {
            if (pasterTypeItemInfo != null) {
                pasterTypeItemInfo.release();
            }
        }
    }

    public static class ItemPosition {

        public int pasterTypeIndex;
        public int pasterItemIndex;

        public ItemPosition(int pasterTypeIndex, int pasterItemIndex) {
            this.pasterTypeIndex = pasterTypeIndex;
            this.pasterItemIndex = pasterItemIndex;
        }

        public boolean equals(ItemPosition other) {
            return pasterTypeIndex == other.pasterTypeIndex && pasterItemIndex == other.pasterItemIndex;
        }
    }
}