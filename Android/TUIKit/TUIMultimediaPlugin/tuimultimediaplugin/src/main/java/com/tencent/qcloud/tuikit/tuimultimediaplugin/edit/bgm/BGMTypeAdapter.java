package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ListView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.bgm.data.BGMInfo.ItemPosition;
import java.util.LinkedList;
import java.util.List;
import org.jetbrains.annotations.Nullable;

public class BGMTypeAdapter extends FragmentStateAdapter {

    private final Context mContext;
    private final BGMInfo mBGMInfo;
    private final TUIMultimediaData<ItemPosition> mTuiDataSelectedPosition;
    private final TUIMultimediaData<Boolean> mTuiDataBGMEnable;
    private final List<BGMTypeItemFragment> mBGMTypeItemFragmentList = new LinkedList<>();

    public BGMTypeAdapter(@NonNull Context context, @NonNull BGMInfo bgmInfo,
            @NonNull TUIMultimediaData<ItemPosition> tuiDataSelectedPosition, TUIMultimediaData<Boolean> tuiDataBGMEnable) {
        super((FragmentActivity) context);
        mBGMInfo = bgmInfo;
        mContext = context;
        mTuiDataSelectedPosition = tuiDataSelectedPosition;
        mTuiDataBGMEnable = tuiDataBGMEnable;
    }

    @NonNull
    @Override
    public Fragment createFragment(int bgmTypeIndex) {
        BGMTypeItemFragment fragment = new BGMTypeItemFragment(mContext, mBGMInfo, bgmTypeIndex,
                mTuiDataSelectedPosition, mTuiDataBGMEnable);
        if (!mBGMTypeItemFragmentList.contains(fragment)) {
            mBGMTypeItemFragmentList.add(bgmTypeIndex, fragment);
        }
        return fragment;
    }

    @Override
    public int getItemCount() {
        return mBGMInfo != null ? mBGMInfo.getBGMTypeSize() : 0;
    }

    public void setSelectedBGMItemView(ItemPosition position) {
        if (position == null) {
            return;
        }
        if (position.bgmTypeIndex >= 0 && position.bgmTypeIndex < mBGMTypeItemFragmentList.size()) {
            BGMTypeItemFragment fragment = mBGMTypeItemFragmentList.get(position.bgmTypeIndex);
            fragment.setSelectedBGMItemView(position.bgmItemIndex);
        }
    }

    public static class BGMTypeItemFragment extends Fragment {

        private final BGMInfo mBGMInfo;
        private final Context mContext;
        private final int mBGMTypeIndex;
        private final TUIMultimediaData<ItemPosition> mTuiDataSelectedPosition;
        private final TUIMultimediaData<Boolean> mTuiDataBGMEnable;

        private BGMItemAdapter mAdapter;
        private ListView mListView;

        public BGMTypeItemFragment(Context context, BGMInfo BGMInfo, int typeIndex,
                TUIMultimediaData<ItemPosition> tuiDataSelectedPosition, TUIMultimediaData<Boolean> tuiDataBGMEnable) {
            mContext = context;
            mBGMInfo = BGMInfo;
            mBGMTypeIndex = typeIndex;
            mTuiDataSelectedPosition = tuiDataSelectedPosition;
            mTuiDataBGMEnable = tuiDataBGMEnable;
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                @Nullable Bundle savedInstanceState) {
            View view = inflater.inflate(R.layout.multimedia_plugin_edit_bgm_type_fragment, container, false);
            mListView = view.findViewById(R.id.bgm_list_view);
            mAdapter = new BGMItemAdapter(mContext, mBGMInfo, mBGMTypeIndex, mTuiDataSelectedPosition,
                    mTuiDataBGMEnable);
            mListView.setAdapter(mAdapter);
            return view;
        }

        public void setSelectedBGMItemView(int position) {
            mListView.setSelection(position);
        }
    }
}
