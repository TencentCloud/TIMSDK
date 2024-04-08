package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.helper;

import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.bean.BaseIndexPinyinBean;

import java.util.List;

/**
 * Introduction: Data-related helper classes for IndexBar
 * 1 Convert Chinese to Pinyin
 * 2 filling indexTag
 * 3 Sort source data
 * 4 According to the sorted source data -> source data of indexBar
 */

public interface IIndexBarDataHelper {
    
    // Chinese to Pinyin
    IIndexBarDataHelper convert(List<? extends BaseIndexPinyinBean> data);

    // Pinyin to tag
    IIndexBarDataHelper fillInexTag(List<? extends BaseIndexPinyinBean> data);

    // Sort source data
    IIndexBarDataHelper sortSourceDatas(List<? extends BaseIndexPinyinBean> datas);

    // sort source data of indexBar, call after the method of sortSourceDatas
    IIndexBarDataHelper getSortedIndexDatas(List<? extends BaseIndexPinyinBean> sourceDatas, List<String> datas);
}
