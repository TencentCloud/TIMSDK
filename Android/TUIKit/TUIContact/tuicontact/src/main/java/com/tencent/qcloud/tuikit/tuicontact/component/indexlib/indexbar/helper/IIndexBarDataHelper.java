package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.helper;

import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.bean.BaseIndexPinyinBean;

import java.util.List;

/**
 * 介绍：IndexBar 的 数据相关帮助类
 * 1 将汉语转成拼音
 * 2 填充indexTag
 * 3 排序源数据源
 * 4 根据排序后的源数据源->indexBar的数据源
 *
 *
 * Introduction: Data-related helper classes for IndexBar
 * 1 Convert Chinese to Pinyin
 * 2 filling indexTag
 * 3 Sort source data
 * 4 According to the sorted source data -> source data of indexBar
 */

public interface IIndexBarDataHelper {
    // 汉语-》拼音
    // Chinese to Pinyin
    IIndexBarDataHelper convert(List<? extends BaseIndexPinyinBean> data);

    // 拼音->tag
    // Pinyin to tag
    IIndexBarDataHelper fillInexTag(List<? extends BaseIndexPinyinBean> data);

    // 对源数据进行排序（RecyclerView）
    // Sort source data
    IIndexBarDataHelper sortSourceDatas(List<? extends BaseIndexPinyinBean> datas);

    // 对IndexBar的数据源进行排序(右侧栏),在 sortSourceDatas 方法后调用
    // sort source data of indexBar, call after the method of sortSourceDatas
    IIndexBarDataHelper getSortedIndexDatas(List<? extends BaseIndexPinyinBean> sourceDatas, List<String> datas);
}
