package com.tencent.qcloud.tim.uikit.component.picture.internal.ui;

import android.os.Bundle;
import android.support.annotation.Nullable;

import com.tencent.qcloud.tim.uikit.component.picture.internal.entity.Item;
import com.tencent.qcloud.tim.uikit.component.picture.internal.entity.SelectionSpec;
import com.tencent.qcloud.tim.uikit.component.picture.internal.model.SelectedItemCollection;

import java.util.List;

public class SelectedPreviewActivity extends BasePreviewActivity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!SelectionSpec.getInstance().hasInited) {
            setResult(RESULT_CANCELED);
            finish();
            return;
        }

        Bundle bundle = getIntent().getBundleExtra(EXTRA_DEFAULT_BUNDLE);
        List<Item> selected = bundle.getParcelableArrayList(SelectedItemCollection.STATE_SELECTION);
        mAdapter.addAll(selected);
        mAdapter.notifyDataSetChanged();
        if (mSpec.countable) {
            mCheckView.setCheckedNum(1);
        } else {
            mCheckView.setChecked(true);
        }
        mPreviousPos = 0;
        updateSize(selected.get(0));
    }

}
