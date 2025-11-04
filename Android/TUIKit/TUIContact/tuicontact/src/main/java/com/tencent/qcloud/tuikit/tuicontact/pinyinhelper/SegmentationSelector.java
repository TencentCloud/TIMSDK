package com.tencent.qcloud.tuikit.tuicontact.pinyinhelper;

import org.ahocorasick.trie.Emit;

import java.util.Collection;
import java.util.List;

/**
 *
 * Created by guyacong on 2016/12/28.
 */

interface SegmentationSelector {

    List<Emit> select(Collection<Emit> emits);
}
