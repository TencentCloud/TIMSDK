package com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.helper;

import android.text.TextUtils;
import com.github.promeg.pinyinhelper.Pinyin;
import com.tencent.qcloud.tuikit.tuicontact.component.indexlib.indexbar.bean.BaseIndexPinyinBean;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class IndexBarDataHelperImpl implements IIndexBarDataHelper {
    @Override
    public IIndexBarDataHelper convert(List<? extends BaseIndexPinyinBean> datas) {
        if (null == datas || datas.isEmpty()) {
            return this;
        }
        int size = datas.size();
        for (int i = 0; i < size; i++) {
            BaseIndexPinyinBean indexPinyinBean = datas.get(i);
            StringBuilder pySb = new StringBuilder();
            if (indexPinyinBean.isNeedToPinyin()) {
                String target = indexPinyinBean.getTarget();
                // 遍历target的每个char得到它的全拼音
                // Traverse each char of target to get its full pinyin
                if (target == null) {
                    continue;
                }
                for (int i1 = 0; i1 < target.length(); i1++) {
                    // 利用TinyPinyin将char转成拼音
                    // 查看源码，方法内 如果char为汉字，则返回大写拼音
                    // 如果c不是汉字，则返回String.valueOf(c)
                    //  Convert char to Pinyin using TinyPinyin
                    //  If char is Chinese characters, return uppercase pinyin. If c is not a Chinese character, return String.valueOf(c)
                    pySb.append(Pinyin.toPinyin(target.charAt(i1)).toUpperCase());
                }
                indexPinyinBean.setBaseIndexPinyin(pySb.toString());
            } else {
                // pySb.append(indexPinyinBean.getBaseIndexPinyin());
            }
        }
        return this;
    }

    @Override
    public IIndexBarDataHelper fillInexTag(List<? extends BaseIndexPinyinBean> datas) {
        if (null == datas || datas.isEmpty()) {
            return this;
        }
        int size = datas.size();
        for (int i = 0; i < size; i++) {
            BaseIndexPinyinBean indexPinyinBean = datas.get(i);
            if (indexPinyinBean.isNeedToPinyin()) {
                if (TextUtils.isEmpty(indexPinyinBean.getBaseIndexPinyin())) {
                    indexPinyinBean.setBaseIndexTag("#");
                    continue;
                }
                String tagString = indexPinyinBean.getBaseIndexPinyin().substring(0, 1);
                if (tagString.matches("[A-Z]")) {
                    indexPinyinBean.setBaseIndexTag(tagString);
                } else {
                    indexPinyinBean.setBaseIndexTag("#");
                }
            }
        }
        return this;
    }

    @Override
    public IIndexBarDataHelper sortSourceDatas(List<? extends BaseIndexPinyinBean> datas) {
        if (null == datas || datas.isEmpty()) {
            return this;
        }
        convert(datas);
        fillInexTag(datas);

        Collections.sort(datas, new Comparator<BaseIndexPinyinBean>() {
            @Override
            public int compare(BaseIndexPinyinBean lhs, BaseIndexPinyinBean rhs) {
                if (lhs.getBaseIndexPinyin() == null && rhs.getBaseIndexPinyin() == null) {
                    return 0;
                } else if (lhs.getBaseIndexPinyin() == null && rhs.getBaseIndexPinyin() != null) {
                    return -1;
                } else if (lhs.getBaseIndexPinyin() != null && rhs.getBaseIndexPinyin() == null) {
                    return 1;
                }
                if (!lhs.isNeedToPinyin()) {
                    return 0;
                } else if (!rhs.isNeedToPinyin()) {
                    return 0;
                } else if (lhs.getBaseIndexTag().equals("#") && !rhs.getBaseIndexTag().equals("#")) {
                    return 1;
                } else if (!lhs.getBaseIndexTag().equals("#") && rhs.getBaseIndexTag().equals("#")) {
                    return -1;
                } else {
                    return lhs.getBaseIndexPinyin().compareTo(rhs.getBaseIndexPinyin());
                }
            }
        });
        return this;
    }

    @Override
    public IIndexBarDataHelper getSortedIndexDatas(List<? extends BaseIndexPinyinBean> sourceDatas, List<String> indexDatas) {
        if (null == sourceDatas || sourceDatas.isEmpty()) {
            return this;
        }

        int size = sourceDatas.size();
        String baseIndexTag;
        for (int i = 0; i < size; i++) {
            baseIndexTag = sourceDatas.get(i).getBaseIndexTag();
            if (!indexDatas.contains(baseIndexTag)) {
                indexDatas.add(baseIndexTag);
            }
        }
        return this;
    }
}
