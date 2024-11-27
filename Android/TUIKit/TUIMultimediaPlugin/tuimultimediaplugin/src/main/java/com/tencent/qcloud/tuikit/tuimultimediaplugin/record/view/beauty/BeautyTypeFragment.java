package com.tencent.qcloud.tuikit.tuimultimediaplugin.record.view.beauty;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIHorizontalScrollView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.record.data.BeautyType;
import org.jetbrains.annotations.Nullable;

public class BeautyTypeFragment extends Fragment {

    private final BeautyInfo mBeautyInfo;
    private final Context mContext;
    private final int mTypeIndex;

    private TUIHorizontalScrollView mScrollItemView;
    private final TUIMultimediaDataObserver<BeautyItem> mOnSelectedBeautyItemChanged = new TUIMultimediaDataObserver<BeautyItem>() {
        @Override
        public void onChanged(BeautyItem beautyItem) {
            BeautyType beautyType = mBeautyInfo.getBeautyType(mTypeIndex);
            if (beautyType != null) {
                mScrollItemView.setClicked(beautyType.getSelectedItemIndex());
            }
        }
    };

    public BeautyTypeFragment(Context context, BeautyInfo beautyInfo, int typeIndex) {
        mContext = context;
        mBeautyInfo = beautyInfo;
        mTypeIndex = typeIndex;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
            @Nullable Bundle savedInstanceState) {
        LiteavLog.i("BeautyTypeFragment", "onCreateView");
        View view = inflater.inflate(R.layout.multimedia_plugin_record_beauty_type_fragment, container, false);

        mScrollItemView = view.findViewById(R.id.beauty_scroll_view);
        BeautyItemAdapter itemAdapter = new BeautyItemAdapter(mContext, mBeautyInfo, mTypeIndex);
        BeautyType beautyType = mBeautyInfo.getBeautyType(mTypeIndex);
        itemAdapter.setSelectPosition(beautyType != null ? beautyType.getSelectedItemIndex() : 1);
        mScrollItemView.setAdapter(itemAdapter);
        mScrollItemView.setFocusable(true);
        mBeautyInfo.tuiDataSelectedBeautyItem.observe(mOnSelectedBeautyItemChanged);
        return view;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        mBeautyInfo.tuiDataSelectedBeautyItem.removeObserver(mOnSelectedBeautyItemChanged);
    }
}