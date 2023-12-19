package com.tencent.cloud.tuikit.roomkit.view.page.widget.BottomNavigationBar;

import android.content.Context;
import android.content.res.Configuration;
import android.graphics.drawable.StateListDrawable;
import android.text.TextUtils;
import android.view.View;
import android.view.ViewGroup;
import android.view.animation.AnimationUtils;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.appcompat.widget.AppCompatImageButton;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomItemData;
import com.tencent.cloud.tuikit.roomkit.model.entity.BottomSelectItemData;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.component.ConfirmDialog;
import com.tencent.cloud.tuikit.roomkit.viewmodel.BottomViewModel;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class BottomView extends LinearLayout {
    public static int MAINVIEW = 0;
    public static int EXTENSIONVIEW = 4;
    public static int TALK_FREEDOM = 5;
    public static int TALK_SEAT_MODE = 6;
    private Context                                        mContext;
    private BottomViewModel                                mViewModel;
    private List<BottomItemData>                           mDataList;
    private Map<BottomItemData.Type, AppCompatImageButton> mButtonMap;
    private Map<BottomItemData.Type, TextView>             mTextViewMap;
    private int                                            mType;

    public BottomView(Context context, int type) {
        super(context);
        mType = type;
        mContext = context;
        mButtonMap = new HashMap<>();
        mTextViewMap = new HashMap<>();
        mViewModel = new BottomViewModel(mContext, this);

        if (type == MAINVIEW) {
            createBottomMainViewModel();
        } else if (type == EXTENSIONVIEW) {
            createBottomExtensionViewModel();
        }
    }

    private void createBottomMainViewModel() {
        mDataList = mViewModel.getItemDataList();
        mViewModel.initMainData();
    }

    private void createBottomExtensionViewModel() {
        mDataList = mViewModel.getItemDataList();
        mViewModel.initExtensionItemData();
    }

    private void updateItemsPosition() {
        int seatCount = TALK_FREEDOM;
        int childCount = getChildCount();
        int parentWidth = (int) mContext.getResources().getDimension(R.dimen.tuiroomkit_bottom_main_view_width);
        int totalChildWidth = 0;
        for (int i = 0; i < childCount; i++) {
            int childWidth = mDataList.get(i).getWidth() == 0 ? getResources()
                    .getDimensionPixelSize(R.dimen.tuiroomkit_bottom_item_view_width) : mDataList.get(i).getWidth();
            totalChildWidth += childWidth;
        }
        totalChildWidth = (totalChildWidth / childCount) * seatCount;
        for (int i = 0; i < childCount; i++) {
            View childView = getChildAt(i);
            int padding = (parentWidth - totalChildWidth) / seatCount;
            LinearLayout.LayoutParams params = (LinearLayout.LayoutParams) childView.getLayoutParams();
            params.leftMargin = padding;
            params.width = mDataList.get(i).getWidth() == 0 ? getResources()
                    .getDimensionPixelSize(R.dimen.tuiroomkit_bottom_item_view_width) : mDataList.get(i).getWidth();
            params.height = mDataList.get(i).getHeight() == 0 ? getResources()
                    .getDimensionPixelSize(R.dimen.tuiroomkit_bottom_item_view_height) : mDataList.get(i).getHeight();
            childView.setLayoutParams(params);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        mViewModel.destroy();
    }

    @Override
    protected void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        updateItemsPosition();
    }

    @Override
    public void setVisibility(int visibility) {
        int animResId = visibility == VISIBLE
                ? R.anim.tuiroomkit_anim_bottom_view_show
                : R.anim.tuiroomkit_anim_bottom_view_dismiss;
        startAnimation(AnimationUtils.loadAnimation(getContext(), animResId));
        super.setVisibility(visibility);
    }

    public void addItem(int index, final BottomItemData itemData) {
        if (index < 0 || index > mDataList.size()) {
            return;
        }
        if (itemData == null) {
            return;
        }
        View layout = View.inflate(mContext, R.layout.tuiroomkit_bottom_button, null);
        final AppCompatImageButton button = layout.findViewById(R.id.image_button);
        final TextView textItemName = layout.findViewById(R.id.tv_item_name);
        if (TextUtils.isEmpty(itemData.getName())) {
            textItemName.setVisibility(GONE);
        } else {
            textItemName.setText(itemData.getName());
        }
        layout.setBackgroundResource(itemData.getBackground());

        int width = itemData.getWidth() == 0 ? getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_bottom_item_icon_width) : itemData.getWidth();
        int height = itemData.getHeight() == 0 ? getResources()
                .getDimensionPixelSize(R.dimen.tuiroomkit_bottom_item_icon_height) : itemData.getHeight();
        if (itemData.getView() != null) {
            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(width, height);
            params.bottomMargin = 15;
            params.addRule(RelativeLayout.CENTER_IN_PARENT);
            params.addRule(RelativeLayout.ABOVE, R.id.tv_item_name);
            ((ViewGroup) layout).removeView(button);
            ((ViewGroup) layout).addView(itemData.getView(), params);
            addView(layout);
            updateItemsPosition();
            return;
        }
        button.setScaleType(ImageView.ScaleType.FIT_XY);
        StateListDrawable stateListDrawable = createStateListDrawable(itemData);
        button.setBackground(stateListDrawable);
        button.setEnabled(itemData.isEnable());
        final BottomSelectItemData selectItemData = itemData.getSelectItemData();
        if (selectItemData != null) {
            button.setSelected(selectItemData.isSelected());
            layout.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    boolean changed = !selectItemData.isSelected();
                    BottomSelectItemData.OnItemSelectListener listener = selectItemData.getOnItemSelectListener();
                    listener.onItemSelected(changed);
                }
            });
            textItemName.setText(selectItemData.isSelected() ? selectItemData.getSelectedName() :
                    selectItemData.getUnSelectedName());
            int btnBackgroundId = selectItemData.isSelected() ? selectItemData.getSelectedIconId() :
                    selectItemData.getUnSelectedIconId();
            button.setBackground(getResources().getDrawable(btnBackgroundId));
        } else {
            layout.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    BottomItemData.OnItemClickListener listener = itemData.getOnItemClickListener();
                    listener.onItemClick();
                }
            });
        }
        addView(layout, index);
        mButtonMap.put(itemData.getType(), button);
        mTextViewMap.put(itemData.getType(), textItemName);
        updateItemsPosition();
    }

    public void replaceItem(BottomItemData.Type type, BottomItemData itemData) {
        TextView textItemName = mTextViewMap.get(type);
        AppCompatImageButton button = mButtonMap.get(type);
        if (textItemName == null || button == null) {
            return;
        }
        textItemName.setText(itemData.getName());
        mTextViewMap.remove(type);
        mTextViewMap.put(itemData.getType(), textItemName);

        StateListDrawable stateListDrawable = createStateListDrawable(itemData);
        button.setBackground(stateListDrawable);
        button.setEnabled(itemData.isEnable());
        mButtonMap.remove(type);
        mButtonMap.put(itemData.getType(), button);

        mDataList.set(mViewModel.indexOf(type), itemData);

        View layout = (View) button.getParent();
        final BottomSelectItemData selectItemData = itemData.getSelectItemData();
        layout.setOnClickListener(null);
        if (selectItemData != null) {
            button.setSelected(selectItemData.isSelected());
            layout.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    boolean changed = !selectItemData.isSelected();
                    BottomSelectItemData.OnItemSelectListener listener = selectItemData.getOnItemSelectListener();
                    listener.onItemSelected(changed);
                }
            });
        } else {
            layout.setOnClickListener(new OnClickListener() {
                @Override
                public void onClick(View v) {
                    BottomItemData.OnItemClickListener listener = itemData.getOnItemClickListener();
                    listener.onItemClick();
                }
            });
        }
    }

    public void stopScreenShareDialog() {
        ConfirmDialog confirmDialog = new ConfirmDialog(mContext);
        confirmDialog.setCancelable(true);
        confirmDialog.setMessage(mContext.getString(R.string.tuiroomkit_hint_stop_live_screen));
        confirmDialog.setPositiveText(mContext.getString(R.string.tuiroomkit_hint_stop_live_screen_stop));
        confirmDialog.setNegativeText(mContext.getString(R.string.tuiroomkit_hint_stop_live_screen_cancel));
        confirmDialog.setPositiveClickListener(new ConfirmDialog.PositiveClickListener() {
            @Override
            public void onClick() {
                RoomEngineManager.sharedInstance().stopScreenCapture();
                confirmDialog.dismiss();
            }
        });
        confirmDialog.setNegativeClickListener(new ConfirmDialog.NegativeClickListener() {
            @Override
            public void onClick() {
                confirmDialog.dismiss();
                return;
            }
        });
        confirmDialog.show();
    }

    private StateListDrawable createStateListDrawable(BottomItemData itemData) {
        StateListDrawable stateListDrawable = new StateListDrawable();
        int stateEnabled = android.R.attr.state_enabled;
        if (itemData.getDisableIconId() != 0) {
            stateListDrawable.addState(new int[]{-stateEnabled},
                    getResources().getDrawable(itemData.getDisableIconId()));
        }
        final BottomSelectItemData selectItemData = itemData.getSelectItemData();
        if (selectItemData != null) {
            int stateSelected = android.R.attr.state_selected;
            if (selectItemData.getSelectedIconId() != 0) {
                stateListDrawable.addState(new int[]{stateSelected},
                        getResources().getDrawable(selectItemData.getSelectedIconId()));
            }

            if (selectItemData.getUnSelectedIconId() != 0) {
                stateListDrawable.addState(new int[]{-stateSelected},
                        getResources().getDrawable(selectItemData.getUnSelectedIconId()));
            }

        } else {
            stateListDrawable.addState(new int[]{-stateEnabled},
                    getResources().getDrawable(itemData.getIconId()));
        }
        return stateListDrawable;
    }

    public void updateItemSelectStatus(BottomItemData.Type type, boolean isSelected) {
        BottomItemData itemData = mViewModel.findItemData(type);
        if (itemData == null || itemData.getSelectItemData() == null) {
            return;
        }
        BottomSelectItemData selectItemData = itemData.getSelectItemData();
        selectItemData.setSelected(isSelected);
        AppCompatImageButton button = mButtonMap.get(type);
        if (button != null) {
            button.setSelected(isSelected);
            int btnBackgroundId = isSelected ? selectItemData.getSelectedIconId() :
                    selectItemData.getUnSelectedIconId();
            button.setBackground(getResources().getDrawable(btnBackgroundId));
        }
        TextView textView = mTextViewMap.get(type);
        if (textView != null) {
            String name = isSelected ? selectItemData.getSelectedName() : selectItemData.getUnSelectedName();
            textView.setText(name);
        }
    }

    public void updateUserListText(int memberCount) {
        BottomItemData itemData = mViewModel.findItemData(BottomItemData.Type.MEMBER_LIST);
        TextView textView = mTextViewMap.get(BottomItemData.Type.MEMBER_LIST);
        if (textView != null && itemData != null) {
            String name = mContext.getString(R.string.tuiroomkit_item_member, memberCount);
            textView.setText(name);
        }
    }

    public void updateItemEnableStatus(BottomItemData.Type type, boolean enable) {
        BottomItemData itemData = mViewModel.findItemData(type);
        if (itemData == null) {
            return;
        }
        itemData.setEnable(enable);
        if (!enable) {
            BottomSelectItemData bottomSelectItemData = itemData.getSelectItemData();
            if (bottomSelectItemData != null) {
                bottomSelectItemData.setSelected(false);
            }
        }
        AppCompatImageButton button = mButtonMap.get(type);
        if (button != null) {
            button.setEnabled(enable);
            if (!enable) {
                button.setSelected(false);
            }
        }
    }
}
