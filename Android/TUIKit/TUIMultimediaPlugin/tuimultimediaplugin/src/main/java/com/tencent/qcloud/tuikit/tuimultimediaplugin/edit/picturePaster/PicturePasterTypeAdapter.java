package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster;

import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.GridView;
import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo.ItemPosition;
import org.jetbrains.annotations.Nullable;

public class PicturePasterTypeAdapter extends FragmentStateAdapter {

    private final Context mContext;
    private final PicturePasterInfo mPasterInfo;
    private final TUIMultimediaData<ItemPosition> mTuiDataSelectedBeautyItem;
    private final PasterTypeItemFragment[] mPasterTypeFragmentList;

    public PicturePasterTypeAdapter(@NonNull Context context, @NonNull PicturePasterInfo pasterInfo,
            @NonNull TUIMultimediaData<ItemPosition> tuiDataSelectItem) {
        super((FragmentActivity) context);
        mPasterInfo = pasterInfo;
        mContext = context;
        mTuiDataSelectedBeautyItem = tuiDataSelectItem;
        mPasterTypeFragmentList = new PasterTypeItemFragment[pasterInfo.getPasterTypeSize()];
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        PasterTypeItemFragment fragment = new PasterTypeItemFragment(mContext, mPasterInfo, position,
                mTuiDataSelectedBeautyItem);
        if (position >= 0 && position < mPasterInfo.getPasterTypeSize()) {
            mPasterTypeFragmentList[position] = fragment;
        }
        return fragment;
    }

    @Override
    public int getItemCount() {
        return mPasterInfo.getPasterTypeSize();
    }

    public void notifySubDataSetChanged(int position) {
        if (mPasterTypeFragmentList[position] != null) {
            mPasterTypeFragmentList[position].notifyDataSetChanged();
        }
    }

    public static class PasterTypeItemFragment extends Fragment {

        private final PicturePasterInfo mPasterInfo;
        private final Context mContext;
        private final int mPasterTypeIndex;
        private final TUIMultimediaData<ItemPosition> mTuiDataSelectedBeautyItem;

        private BaseAdapter mAdapter;

        public PasterTypeItemFragment(Context context, PicturePasterInfo pasterInfo, int typeIndex,
                TUIMultimediaData<ItemPosition> tuiDataSelectedBeautyItem) {
            mContext = context;
            mPasterInfo = pasterInfo;
            mPasterTypeIndex = typeIndex;
            mTuiDataSelectedBeautyItem = tuiDataSelectedBeautyItem;
        }

        @Nullable
        @Override
        public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                @Nullable Bundle savedInstanceState) {
            View view = inflater.inflate(R.layout.multimedia_plugin_edit_picture_paster_type_fragment, container, false);
            GridView gridView = view.findViewById(R.id.grid_view);
            mAdapter = new PicturePasterItemAdapter(mContext, mPasterInfo, mPasterTypeIndex,
                    mTuiDataSelectedBeautyItem);
            gridView.setAdapter(mAdapter);
            return view;
        }

        public void notifyDataSetChanged() {
            if (mAdapter != null) {
                mAdapter.notifyDataSetChanged();
            }
        }
    }
}
