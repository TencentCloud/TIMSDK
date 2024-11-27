package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data;

import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import java.util.List;

public class BeautyInfo {

    private static final String DEFAULT_BEAUTY_DATA = "file:///asset/config/beauty_info_default_data.json";
    public final TUIMultimediaData<BeautyItem> tuiDataSelectedBeautyItem = new TUIMultimediaData<>(null);
    private final String TAG = BeautyInfo.class.getSimpleName() + "_" + hashCode();
    @SerializedName("beauty_type_list")
    private List<BeautyType> mBeautyTypeList;

    public static BeautyInfo CreateDefaultBeautyInfo() {
        LiteavLog.i("BeautyInfo", "create default beautyInfo");
        String json = TUIMultimediaFileUtil.readTextFromFile(DEFAULT_BEAUTY_DATA);
        Gson gson = new Gson();
        return gson.fromJson(json, BeautyInfo.class);
    }

    public BeautyType getBeautyType(int typeIndex) {
        if (mBeautyTypeList == null || typeIndex >= mBeautyTypeList.size()) {
            return null;
        }

        return mBeautyTypeList.get(typeIndex);
    }

    public void setSelectedItemIndex(int typeIndex, int itemIndex) {
        LiteavLog.i(TAG, "set selected item index.type index = " + typeIndex + " item index = " + itemIndex);
        BeautyType BeautyType = getBeautyType(typeIndex);
        if (BeautyType == null) {
            return;
        }

        BeautyType.setSelectedItemIndex(itemIndex);
        BeautyItem beautyItem = BeautyType.getSelectBeautyItem();
        if (beautyItem != tuiDataSelectedBeautyItem.get()) {
            tuiDataSelectedBeautyItem.set(beautyItem);
        }
    }

    public int getItemTypeIndex(BeautyItem beautyItem) {
        for (int i = 0; i < mBeautyTypeList.size(); i++) {
            if (mBeautyTypeList.get(i).isContainItem(beautyItem)) {
                return i;
            }
        }
        return 0;
    }

    public int getBeautyTypeSize() {
        return mBeautyTypeList != null ? mBeautyTypeList.size() : 0;
    }

    public int getItemSize(int typeIndex) {
        BeautyType beautyType = getBeautyType(typeIndex);
        return beautyType != null ? beautyType.getItemSize() : 0;
    }

    public int getTypeIndexWithType(BeautyInnerType beautyType) {
        if (beautyType == BeautyInnerType.BEAUTY_FILTER) {
            return 1;
        } else {
            return 0;
        }
    }
}
