package com.tencent.qcloud.tuikit.tuicontact.pinyinhelper;


import org.ahocorasick.trie.Emit;
import org.ahocorasick.trie.Trie;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 *
 * Created by guyacong on 2016/12/23.
 */

final class Engine {

    static final EmitComparator EMIT_COMPARATOR = new EmitComparator();

    private Engine() {
        //no instance
    }

    static String toPinyin(final String inputStr, Pinyin.Config config, String separator) {
        List<PinyinDict> pinyinDicts = Collections.unmodifiableList(config.getPinyinDicts());
        Trie trie = Utils.dictsToTrie(config.getPinyinDicts());
        SegmentationSelector selector = config.getSelector();

        return toPinyin(inputStr, trie, pinyinDicts, separator, selector);
    }

    static String toPinyin(final String inputStr, final Trie trie, final  List<PinyinDict> pinyinDictList,
            final String separator, final SegmentationSelector selector) {
        if (inputStr == null || inputStr.length() == 0) {
            return inputStr;
        }


        if (trie == null || selector == null) {
            StringBuffer resultPinyinStrBuf = new StringBuffer();
            for (int i = 0; i < inputStr.length(); i++) {
                resultPinyinStrBuf.append(Pinyin.toPinyin(inputStr.charAt(i)));
                if (i != inputStr.length() - 1) {
                    resultPinyinStrBuf.append(separator);
                }
            }
            return resultPinyinStrBuf.toString();
        }

        List<Emit> selectedEmits = selector.select(trie.parseText(inputStr));

        Collections.sort(selectedEmits, EMIT_COMPARATOR);

        StringBuffer resultPinyinStrBuf = new StringBuffer();

        int nextHitIndex = 0;

        for (int i = 0; i < inputStr.length();) {
            if (nextHitIndex < selectedEmits.size() && i == selectedEmits.get(nextHitIndex).getStart()) {
                String[] fromDicts = pinyinFromDict(selectedEmits.get(nextHitIndex).getKeyword(), pinyinDictList);
                for (int j = 0; j < fromDicts.length; j++) {
                    resultPinyinStrBuf.append(fromDicts[j].toUpperCase());
                    if (j != fromDicts.length - 1) {
                        resultPinyinStrBuf.append(separator);
                    }
                }

                i = i + selectedEmits.get(nextHitIndex).size();
                nextHitIndex++;
            } else {
                resultPinyinStrBuf.append(Pinyin.toPinyin(inputStr.charAt(i)));
                i++;
            }

            if (i != inputStr.length()) {
                resultPinyinStrBuf.append(separator);
            }
        }

        return resultPinyinStrBuf.toString();
    }

    static String[] pinyinFromDict(String wordInDict, List<PinyinDict> pinyinDictSet) {
        if (pinyinDictSet != null) {
            for (PinyinDict dict : pinyinDictSet) {
                if (dict != null && dict.words() != null
                        && dict.words().contains(wordInDict)) {
                    return dict.toPinyin(wordInDict);
                }
            }
        }
        throw new IllegalArgumentException("No pinyin dict contains word: " + wordInDict);
    }

    static final class EmitComparator implements Comparator<Emit> {

        @Override
        public int compare(Emit o1, Emit o2) {
            if (o1.getStart() == o2.getStart()) {
                return (o1.size() < o2.size()) ? 1 : ((o1.size() == o2.size()) ? 0 : -1);
            } else {
                return (o1.getStart() < o2.getStart()) ? -1 : ((o1.getStart() == o2.getStart()) ? 0 : 1);
            }
        }
    }

}
