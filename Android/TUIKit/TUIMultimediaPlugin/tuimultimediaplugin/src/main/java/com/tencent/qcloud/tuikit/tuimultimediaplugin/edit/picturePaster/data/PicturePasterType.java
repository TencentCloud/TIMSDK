package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data;

import android.graphics.Bitmap;
import com.google.gson.annotations.SerializedName;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import java.util.LinkedList;
import java.util.List;

public class PicturePasterType {

    @SerializedName("type_name")
    private String mTypeName;
    @SerializedName("type_icon_path")
    private String mTypeIconPath;
    @SerializedName("paster_item_list")
    private List<PicturePasterItem> mPasterItemList;

    transient private Bitmap mIcon;

    public void addPasterItem(int itemIndex, PicturePasterItem pasterItemInfo) {
        if (itemIndex < 0) {
            return;
        }

        if (mPasterItemList == null) {
            mPasterItemList = new LinkedList<>();
        }

        mPasterItemList.add(itemIndex, pasterItemInfo);
    }

    public PicturePasterItem getPasterItem(int itemIndex) {
        if (itemIndex < 0 || itemIndex >= mPasterItemList.size()) {
            return null;
        }
        return mPasterItemList.get(itemIndex);
    }

    public List<PicturePasterItem> getPasterItemList() {
        return mPasterItemList;
    }

    public int getFirstFileSelectorIndex() {
        for (int i = 0; i < mPasterItemList.size(); i++) {
            PicturePasterItem pasterItemInfo = mPasterItemList.get(i);
            if (pasterItemInfo != null && pasterItemInfo.isFileSelector()) {
                return i;
            }
        }
        return -1;
    }

    public int getItemSize() {
        return mPasterItemList.size();
    }

    public String getTypeName() {
        if (mTypeName.startsWith(TUIMultimediaResourceUtils.STRING_RESOURCE_PREFIX)) {
            return TUIMultimediaResourceUtils.getString(mTypeName);
        }
        return mTypeName;
    }

    public Object getPasterIcon() {
        if (mIcon != null) {
            return mIcon;
        }

        if (TUIMultimediaFileUtil.isHttpPath(mTypeIconPath)) {
            return mTypeIconPath;
        }
        mIcon = TUIMultimediaFileUtil.decodeBitmap(mTypeIconPath);
        return mIcon;
    }

    public void release() {
        if (mPasterItemList == null) {
            return;
        }

        for (PicturePasterItem pasterItemInfo : mPasterItemList) {
            if (pasterItemInfo != null) {
                pasterItemInfo.recycleBitmap();
            }
        }
    }
}
