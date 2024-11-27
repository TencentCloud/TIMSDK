package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Typeface;
import android.net.Uri;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.TextView;
import androidx.activity.result.ActivityResultCaller;
import androidx.annotation.NonNull;
import androidx.viewpager2.widget.ViewPager2;
import com.google.android.material.tabs.TabLayout;
import com.google.android.material.tabs.TabLayout.OnTabSelectedListener;
import com.google.android.material.tabs.TabLayout.Tab;
import com.google.android.material.tabs.TabLayoutMediator;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ActivityResultResolver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData.TUIMultimediaDataObserver;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterInfo.ItemPosition;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterItem;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.picturePaster.data.PicturePasterType;

@SuppressLint("ViewConstructor")
public class PicturePasterPanelView extends RelativeLayout {

    private final String TAG = PicturePasterPanelView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final PicturePasterManager mPicturePasterManager;
    private final TUIMultimediaData<ItemPosition> mTuiDataSelectedItem = new TUIMultimediaData<>(null);
    private final OnTabSelectedListener onTabSelectedListener = new OnTabSelectedListener() {
        @Override
        public void onTabSelected(Tab tab) {
            configTabSelectedStatus(tab, true);
        }

        @Override
        public void onTabUnselected(Tab tab) {
            configTabSelectedStatus(tab, false);
        }

        @Override
        public void onTabReselected(Tab tab) {
        }
    };
    private PicturePasterTypeAdapter mPasterTypeAdapter;
    private PicturePasterInfo mPicturePasterInfo;
    private PicturePasterSelectListener mPicturePasterSelectListener;
    private final TUIMultimediaDataObserver<ItemPosition> mOnSelectItemChanged = new TUIMultimediaDataObserver<ItemPosition>() {
        @Override
        public void onChanged(ItemPosition itemPosition) {
            PicturePasterItem pasterItem = mPicturePasterManager.getPasterItem(itemPosition);
            if (pasterItem == null) {
                return;
            }

            if (pasterItem.isFileSelector()) {
                selectPicturePasterFromLocalFile(itemPosition);
            } else {
                if (mPicturePasterSelectListener != null) {
                    mPicturePasterSelectListener
                            .PicturePasterSelectCompeted(mPicturePasterManager.getPaster(itemPosition));
                }

            }
        }
    };

    public PicturePasterPanelView(@NonNull Context context,
            @NonNull PicturePasterManager picturePasterManager) {
        super(context);
        mContext = context;
        mPicturePasterManager = picturePasterManager;
    }

    @Override
    public void onAttachedToWindow() {
        LiteavLog.i(TAG, "onAttachedToWindow");
        super.onAttachedToWindow();
        initView();
        mTuiDataSelectedItem.observe(mOnSelectItemChanged);
    }

    @Override
    public void onDetachedFromWindow() {
        LiteavLog.i(TAG, "onDetachedFromWindow");
        removeAllViews();
        super.onDetachedFromWindow();
        mTuiDataSelectedItem.removeObserver(mOnSelectItemChanged);
    }

    public void selectPaster(PicturePasterSelectListener picturePasterSelectListener) {
        mPicturePasterSelectListener = picturePasterSelectListener;
    }

    private void initView() {
        LayoutInflater.from(mContext).inflate(R.layout.multimedia_plugin_edit_picture_paster_panel_view, this);
        mPicturePasterInfo = mPicturePasterManager.getPicturePasterSetInfo();
        if (mPicturePasterInfo == null) {
            LiteavLog.i(TAG, "get picture paster set info null");
            return;
        }

        ViewPager2 beautyPager = findViewById(R.id.picture_paster_panel_view_pager);
        mPasterTypeAdapter = new PicturePasterTypeAdapter(mContext, mPicturePasterInfo,
                mTuiDataSelectedItem);
        beautyPager.setAdapter(mPasterTypeAdapter);

        TabLayout tabLayout = findViewById(R.id.picture_paster_panel_tab_layout);
        tabLayout.addOnTabSelectedListener(onTabSelectedListener);
        tabLayout.setTabMode(TabLayout.MODE_SCROLLABLE);
        new TabLayoutMediator(tabLayout, beautyPager, this::configTab).attach();
    }

    private void configTab(@NonNull Tab tab, int position) {
        if (mPicturePasterInfo == null) {
            return;
        }

        PicturePasterType typeInfo = mPicturePasterInfo.getPasterType(position);
        Bitmap pasterIcon = typeInfo != null ? typeInfo.getPasterIcon() : null;
        if (pasterIcon != null) {
            configTabImage(tab, pasterIcon);
            return;
        }

        configTabText(tab, typeInfo != null ? typeInfo.getTypeName() : "");
    }

    private void configTabText(Tab tab, String text) {
        TextView customTextView = new TextView(getContext());
        customTextView.setGravity(Gravity.CENTER);

        customTextView.setText(text);
        customTextView.setMaxLines(1);
        customTextView.setTextColor(
                TUIMultimediaResourceUtils.getResources().getColor(R.color.multimedia_plugin_record_beauty_type_text_color_normal));

        float textSize = TUIMultimediaResourceUtils.getResources().getDimension(R.dimen.multimedia_plugin_common_text_size);
        customTextView.setTextSize(TypedValue.COMPLEX_UNIT_PX, textSize);

        String fontName = TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_common_font);
        customTextView.setTypeface(Typeface.create(fontName, Typeface.NORMAL));
        tab.setCustomView(customTextView);
    }

    private void configTabImage(Tab tab, Bitmap image) {
        View tabView = LayoutInflater.from(getContext())
                .inflate(R.layout.multimedia_plugin_edit_picture_paster_type_image_item, null);
        ImageView imageView = tabView.findViewById(R.id.paster_type_icon);
        imageView.setImageBitmap(image);
        tab.setCustomView(tabView);
    }

    private void configTabSelectedStatus(Tab tab, boolean isSelected) {
        View customView = tab.getCustomView();
        if (customView instanceof TextView) {
            configTabSelectedText((TextView) customView, isSelected);
        } else {
            configTabSelectedImage(customView, isSelected);
        }
    }

    private void configTabSelectedText(TextView tabTextView, boolean isSelected) {
        if (tabTextView == null) {
            return;
        }

        int textColorResourceId = R.color.multimedia_plugin_record_beauty_type_text_color_normal;
        int textColorFontStyle = Typeface.NORMAL;
        if (isSelected) {
            textColorResourceId = R.color.multimedia_plugin_record_beauty_type_text_color_selected;
            textColorFontStyle = Typeface.BOLD;
        }

        tabTextView.setTextColor(
                TUIMultimediaResourceUtils.getResources().getColor(textColorResourceId));
        String fontName = TUIMultimediaResourceUtils.getString(R.string.multimedia_plugin_common_font);
        tabTextView.setTypeface(Typeface.create(fontName, textColorFontStyle));
    }

    private void configTabSelectedImage(View tabView, boolean isSelected) {
        if (tabView == null) {
            return;
        }

        ImageView backgroundImage = tabView.findViewById(R.id.paster_type_icon_background);
        if (isSelected) {
            backgroundImage.setVisibility(VISIBLE);
        } else {
            backgroundImage.setVisibility(INVISIBLE);
        }
    }

    private void selectPicturePasterFromLocalFile(ItemPosition itemPosition) {
        ActivityResultResolver.getSingleContent((ActivityResultCaller) mContext,
                new String[]{ActivityResultResolver.CONTENT_TYPE_IMAGE, ActivityResultResolver.CONTENT_TYPE_ALL},
                new TUIValueCallback<Uri>() {
                    @Override
                    public void onSuccess(Uri uri) {
                        if (mPicturePasterManager.addUserPasterFromUri(uri, itemPosition)) {
                            mPasterTypeAdapter.notifySubDataSetChanged(itemPosition.pasterTypeIndex);
                        }
                    }

                    @Override
                    public void onError(int errorCode, String errorMessage) {
                    }
                });
    }

    public interface PicturePasterSelectListener {

        void PicturePasterSelectCompeted(Bitmap bitmap);
    }
}
