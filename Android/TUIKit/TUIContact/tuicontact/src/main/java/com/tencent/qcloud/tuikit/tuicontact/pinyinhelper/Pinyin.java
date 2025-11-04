package com.tencent.qcloud.tuikit.tuicontact.pinyinhelper;

import org.ahocorasick.trie.Trie;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by guyacong on 2015/9/28.
 */
public final class Pinyin {

    static Trie mTrieDict = null;
    static SegmentationSelector mSelector = null;
    static List<PinyinDict> mPinyinDicts = null;

    private Pinyin() {
    }

    public static void init(Config config) {
        if (config == null) {
            mPinyinDicts = null;
            mTrieDict = null;
            mSelector = null;
            return;
        }

        if (!config.valid()) {
            return;
        }
        mPinyinDicts = Collections.unmodifiableList(config.getPinyinDicts());
        mTrieDict = Utils.dictsToTrie(config.getPinyinDicts());
        mSelector = config.getSelector();
    }

    public static void add(PinyinDict dict) {
        if (dict == null || dict.words() == null || dict.words().size() == 0) {
            return;
        }
        init(new Config(mPinyinDicts).with(dict));
    }

    public static Config newConfig() {
        return new Config(null);
    }

    public static String toPinyin(String str, String separator) {
        return Engine.toPinyin(str, mTrieDict, mPinyinDicts, separator, mSelector);
    }

    public static String toPinyin(String str, String separator, PinyinRules rules) {
        if (rules != null) {
            List<PinyinDict> dicts = new ArrayList();
            dicts.add(rules.toPinyinMapDict());
            if (mPinyinDicts != null) {
                dicts.addAll(mPinyinDicts);
            }
            Config config = new Config(dicts);

            return Engine.toPinyin(str, config, separator);
        } else {
            return toPinyin(str, separator);
        }
    }

    public static String toPinyin(char c) {
        if (isChinese(c)) {
            if (c == PinyinData.CHAR_12295) {
                return PinyinData.PINYIN_12295;
            } else {
                return PinyinData.PINYIN_TABLE[getPinyinCode(c)];
            }
        } else {
            return String.valueOf(c);
        }
    }

    public static String toPinyin(char c, PinyinRules rules) {
        if (rules != null && rules.toPinyin(c) != null) {
            return rules.toPinyin(c);
        } else {
            return toPinyin(c);
        }
    }

    public static boolean isChinese(char c) {
        return (PinyinData.MIN_VALUE <= c && c <= PinyinData.MAX_VALUE
                && getPinyinCode(c) > 0)
                || PinyinData.CHAR_12295 == c;
    }

    private static int getPinyinCode(char c) {
        int offset = c - PinyinData.MIN_VALUE;
        if (0 <= offset && offset < PinyinData.PINYIN_CODE_1_OFFSET) {
            return decodeIndex(PinyinCode1.PINYIN_CODE_PADDING, PinyinCode1.PINYIN_CODE, offset);
        } else if (PinyinData.PINYIN_CODE_1_OFFSET <= offset
                && offset < PinyinData.PINYIN_CODE_2_OFFSET) {
            return decodeIndex(PinyinCode2.PINYIN_CODE_PADDING, PinyinCode2.PINYIN_CODE,
                    offset - PinyinData.PINYIN_CODE_1_OFFSET);
        } else {
            return decodeIndex(PinyinCode3.PINYIN_CODE_PADDING, PinyinCode3.PINYIN_CODE,
                    offset - PinyinData.PINYIN_CODE_2_OFFSET);
        }
    }

    private static short decodeIndex(byte[] paddings, byte[] indexes, int offset) {
        //CHECKSTYLE:OFF
        int index1 = offset / 8;
        int index2 = offset % 8;
        short realIndex;
        realIndex = (short) (indexes[offset] & 0xff);
        //CHECKSTYLE:ON
        if ((paddings[index1] & PinyinData.BIT_MASKS[index2]) != 0) {
            realIndex = (short) (realIndex | PinyinData.PADDING_MASK);
        }
        return realIndex;
    }

    public static final class Config {

        SegmentationSelector mSelector;

        List<PinyinDict> mPinyinDicts;

        private Config(List<PinyinDict> dicts) {
            if (dicts != null) {
                mPinyinDicts = new ArrayList<PinyinDict>(dicts);
            }

            mSelector = new ForwardLongestSelector();
        }

        public Config with(PinyinDict dict) {
            if (dict != null) {
                if (mPinyinDicts == null) {
                    mPinyinDicts = new ArrayList<PinyinDict>();
                    mPinyinDicts.add(dict);
                } else if (!mPinyinDicts.contains(dict)) {
                    mPinyinDicts.add(dict);
                }
            }
            return this;
        }

        boolean valid() {
            return getPinyinDicts() != null && getSelector() != null;
        }

        SegmentationSelector getSelector() {
            return mSelector;
        }

        List<PinyinDict> getPinyinDicts() {
            return mPinyinDicts;
        }
    }
}
