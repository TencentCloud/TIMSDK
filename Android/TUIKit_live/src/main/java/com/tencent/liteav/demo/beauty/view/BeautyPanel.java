package com.tencent.liteav.demo.beauty.view;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.widget.RelativeLayout;
import android.widget.SeekBar;
import android.widget.TextView;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.tencent.liteav.beauty.TXBeautyManager;
import com.tencent.liteav.demo.beauty.Beauty;
import com.tencent.liteav.demo.beauty.BeautyImpl;
import com.tencent.liteav.demo.beauty.adapter.ItemAdapter;
import com.tencent.liteav.demo.beauty.adapter.TabAdapter;
import com.tencent.liteav.demo.beauty.constant.BeautyConstants;
import com.tencent.liteav.demo.beauty.model.BeautyInfo;
import com.tencent.liteav.demo.beauty.model.ItemInfo;
import com.tencent.liteav.demo.beauty.model.TabInfo;
import com.tencent.liteav.demo.beauty.utils.BeautyUtils;
import com.tencent.liteav.demo.beauty.utils.ResourceUtils;
import com.tencent.qcloud.tim.tuikit.live.R;

/**
 * 美颜面板控件 View
 * <p>
 * -引用，在 xml 中引用该布局，设置其大小
 * -外部可通过 getDefaultBeautyInfo 获取默认美颜面板的属性
 * -外部可通过 setBeautyInfo 设置美颜面板内部属性
 * -外部可通过 setOnBeautyListener 监听美颜面板的行为动作
 */
public class BeautyPanel extends BottomSheetDialog implements SeekBar.OnSeekBarChangeListener, View.OnClickListener {

    private static final String TAG = "BeautyPanel";

    private Context mContext;

    private TCHorizontalScrollView mScrollTabView;
    private TCHorizontalScrollView mScrollItemView;
    private RelativeLayout         mRelativeSeekBarLayout;
    private SeekBar                mSeekBarLevel;
    private TextView               mTextLevelHint;
    private TextView               mTextLevelValue;
    private TextView               mTextTitle;
    private TextView               mTextClose;
    private RelativeLayout         mLayoutRoot;

    private BeautyInfo       mBeautyInfo;
    private OnBeautyListener mOnBeautyListener;
    private Beauty           mBeauty;

    private TabInfo    mCurrentTabInfo;
    private ItemInfo[] mCurrentItemInfo;
    private int        mCurrentTabPosition = 0;
    private int[]      mCurrentItemPosition;

    public interface OnBeautyListener {
        void onTabChange(TabInfo tabInfo, int position);

        boolean onClose();

        boolean onClick(TabInfo tabInfo, int tabPosition, ItemInfo itemInfo, int itemPosition);

        boolean onLevelChanged(TabInfo tabInfo, int tabPosition, ItemInfo itemInfo, int itemPosition, int beautyLevel);
    }

    public BeautyPanel(@NonNull Context context) {
        super(context);
        initialize(context);
    }

    @Override
    public void onProgressChanged(SeekBar seekBar, int progress, boolean fromUser) {
        mCurrentItemInfo[mCurrentTabPosition].setItemLevel(progress);
        mTextLevelValue.setText(String.valueOf(progress));
        if (mOnBeautyListener == null
                || !mOnBeautyListener.onLevelChanged(mCurrentTabInfo, mCurrentTabPosition, mCurrentItemInfo[mCurrentTabPosition], mCurrentItemPosition[mCurrentTabPosition], progress)) {
            mBeauty.setBeautySpecialEffects(mCurrentTabInfo, mCurrentTabPosition, mCurrentItemInfo[mCurrentTabPosition], mCurrentItemPosition[mCurrentTabPosition]);
        }
    }

    @Override
    public void onStartTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onStopTrackingTouch(SeekBar seekBar) {

    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == mTextClose.getId()) {
            if (mOnBeautyListener == null || !mOnBeautyListener.onClose()) {
                dismiss();
            }
        }
    }

    /**
     * 设置 BeautyPanel 绘制所要使用的数据
     *
     * @param beautyInfo
     */
    public void setBeautyInfo(@NonNull BeautyInfo beautyInfo) {
        mBeautyInfo = beautyInfo;
        int tabSize = beautyInfo.getBeautyTabList().size();
        mCurrentItemPosition = new int[tabSize];
        mCurrentItemInfo = new ItemInfo[tabSize];
        mBeauty.fillingMaterialPath(beautyInfo);
        mLayoutRoot.setBackground(ResourceUtils.getLinearDrawable(ResourceUtils.getColor(beautyInfo.getBeautyBg())));
        refresh();
    }

    /**
     * 设置 特效点击回调
     *
     * @param onBeautyListener
     */
    public void setOnBeautyListener(@NonNull OnBeautyListener onBeautyListener) {
        mOnBeautyListener = onBeautyListener;
    }

    public void setOnFilterChangeListener(Beauty.OnFilterChangeListener listener) {
        mBeauty.setOnFilterChangeListener(listener);
    }

    public int getFilterProgress(int index) {
        return mBeauty.getFilterProgress(mBeautyInfo, index);
    }

    public BeautyInfo getDefaultBeautyInfo() {
        return mBeauty.getDefaultBeauty();
    }

    public void setBeautyManager(TXBeautyManager beautyManager) {
        mBeauty.setBeautyManager(beautyManager);
        clear();
        // 滤镜默认选中白皙
        setCurrentFilterIndex(1);
        setCurrentBeautyIndex(2);
    }

    public void setMotionTmplEnable(boolean enable) {
        mBeauty.setMotionTmplEnable(enable);
    }

    public ItemInfo getItemInfo(int tabIndex, int itemIndex) {
        return mBeautyInfo.getBeautyTabList().get(tabIndex).getTabItemList().get(itemIndex);
    }

    public void setCurrentFilterIndex(int index) {
        mCurrentItemPosition[1] = index;
        mBeauty.setCurrentFilterIndex(mBeautyInfo, index);
    }

    public void setCurrentBeautyIndex(int index) {
        mCurrentItemPosition[0] = index;
        mBeauty.setCurrentBeautyIndex(mBeautyInfo, index);
    }

    public ItemInfo getFilterItemInfo(int index) {
        return mBeauty.getFilterItemInfo(mBeautyInfo, index);
    }

    public int getFilterSize() {
        return mBeauty.getFilterSize(mBeautyInfo);
    }

    public Bitmap getFilterResource(int index) {
        return mBeauty.getFilterResource(mBeautyInfo, index);
    }

    public void clear() {
        mBeauty.clear();
    }

    private void initialize(Context context) {
        mContext = context;
        setContentView(R.layout.beauty_view_layout);
        getWindow().findViewById(R.id.design_bottom_sheet)
                .setBackgroundResource(android.R.color.transparent);
        getWindow().setDimAmount(0f);
        mBeauty = new BeautyImpl(mContext);
        initView();
        initData();
    }

    private void initView() {
        mRelativeSeekBarLayout = (RelativeLayout) findViewById(R.id.beauty_rl_seek_bar);
        mSeekBarLevel = (SeekBar) findViewById(R.id.beauty_seek_bar_third);
        mTextLevelHint = (TextView) findViewById(R.id.beauty_tv_seek_bar_hint);
        mTextLevelValue = (TextView) findViewById(R.id.beauty_tv_seek_bar_value);
        mTextTitle = (TextView) findViewById(R.id.beauty_tv_title);
        mTextClose = (TextView) findViewById(R.id.beauty_tv_close);
        mTextClose.setOnClickListener(this);
        mSeekBarLevel.setOnSeekBarChangeListener(this);
        mLayoutRoot = findViewById(R.id.layout_root);
        mScrollTabView = (TCHorizontalScrollView) findViewById(R.id.beauty_horizontal_picker_view_first);
        mScrollItemView = (TCHorizontalScrollView) findViewById(R.id.beauty_horizontal_picker_second);
    }

    private void initData() {
        setBeautyInfo(getDefaultBeautyInfo());
    }

    private void refresh() {
        createTabList();
    }

    private void createTabList() {
        TabAdapter tabAdapter = new TabAdapter(mContext, mBeautyInfo);
        mScrollTabView.setAdapter(tabAdapter);
        tabAdapter.setOnTabClickListener(new TabAdapter.OnTabChangeListener() {
            @Override
            public void onTabChange(TabInfo tabInfo, int position) {
                mCurrentTabInfo = tabInfo;
                mCurrentTabPosition = position;
                createItemList(tabInfo, position);
                if (mOnBeautyListener != null) {
                    mOnBeautyListener.onTabChange(tabInfo, position);
                }
            }
        });
        TabInfo tabInfo = mBeautyInfo.getBeautyTabList().get(0);
        mCurrentTabInfo = tabInfo;
        mCurrentTabPosition = 0;
        createItemList(tabInfo, 0);
    }

    private void createItemList(@NonNull final TabInfo tabInfo, @NonNull final int tabPosition) {
        setBeautyTitle(tabInfo.getTabName());
        ItemAdapter itemAdapter = new ItemAdapter(mContext);
        if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_FILTER) {
            // 滤镜默认选中白皙
            itemAdapter.setData(tabInfo, mCurrentItemPosition[tabPosition]);
        } else if (tabInfo.getTabType() == BeautyConstants.TAB_TYPE_BEAUTY) {
            // 美颜默认选中P图
            itemAdapter.setData(tabInfo, mCurrentItemPosition[tabPosition]);
        } else {
            itemAdapter.setData(tabInfo);
        }
        mScrollItemView.setAdapter(itemAdapter);
        mScrollItemView.setClicked(mCurrentItemPosition[tabPosition]);
        itemAdapter.setOnItemClickListener(new ItemAdapter.OnItemClickListener() {
            @Override
            public void onItemClick(ItemInfo itemInfo, int position) {
                mCurrentItemPosition[tabPosition] = position;
                mCurrentItemInfo[tabPosition] = itemInfo;
                createSeekBar(tabInfo, itemInfo);
                if (mOnBeautyListener == null
                        || !mOnBeautyListener.onClick(tabInfo, tabPosition, itemInfo, position)) {
                    mBeauty.setBeautySpecialEffects(tabInfo, tabPosition, itemInfo, position);
                }
            }
        });
        ItemInfo itemInfo = tabInfo.getTabItemList().get(mCurrentItemPosition[tabPosition]);
        mCurrentItemInfo[tabPosition] = itemInfo;
        createSeekBar(tabInfo, itemInfo);
    }

    private void createSeekBar(@NonNull TabInfo tabInfo, @NonNull ItemInfo itemInfo) {
        int visibility;
        if (itemInfo.getItemLevel() == -1) {
            visibility = View.GONE;
        } else {
            visibility = View.VISIBLE;
            mTextLevelValue.setText(String.valueOf(itemInfo.getItemLevel()));
            mSeekBarLevel.setProgress(itemInfo.getItemLevel());
            BeautyUtils.setTextViewSize(mTextLevelHint, tabInfo.getTabItemLevelHintSize());
            BeautyUtils.setTextViewColor(mTextLevelHint, tabInfo.getTabItemLevelHintColor());
            BeautyUtils.setTextViewSize(mTextLevelValue, tabInfo.getTabItemLevelValueSize());
            BeautyUtils.setTextViewColor(mTextLevelValue, tabInfo.getTabItemLevelValueColor());
        }
        mRelativeSeekBarLayout.setVisibility(visibility);
    }

    private void setBeautyTitle(String title) {
        mTextTitle.setText(ResourceUtils.getString(title) + ResourceUtils.getString(R.string.beauty_setup));
    }
}
