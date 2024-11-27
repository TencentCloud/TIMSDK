package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer;

import android.content.Context;
import android.graphics.Bitmap;
import android.util.AttributeSet;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer.FloatLayerView.Status;
import com.tencent.ugc.TXVideoEditConstants.TXRect;
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class FloatLayerViewGroup extends FrameLayout {

    private final String TAG = FloatLayerViewGroup.class.getSimpleName() + "_" + hashCode();

    private final List<FloatLayerView> mFloatLayerViewList = new ArrayList<>();
    private FloatLayerView mSelectedFloatLayerView;

    public FloatLayerViewGroup(@NonNull Context context) {
        super(context);
    }

    public FloatLayerViewGroup(@NonNull Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public FloatLayerViewGroup(@NonNull Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public void addOperationView(FloatLayerView view) {
        if (view == null) {
            return;
        }
        mFloatLayerViewList.add(view);
        addView(view);
        view.tuiDataGetStatus().observe(status -> {
            if (status == Status.STATUS_SELECTED) {
                if (mSelectedFloatLayerView != null && view != mSelectedFloatLayerView) {
                    mSelectedFloatLayerView.unSelect();
                }
                mSelectedFloatLayerView = view;
            }
        });
    }

    public void removeOperationView(FloatLayerView view) {
        if (view == null) {
            return;
        }
        mFloatLayerViewList.remove(view);
        removeView(view);
    }

    @NonNull
    public List<TUIMultimediaPasterInfo> getAllPaster() {
        List<TUIMultimediaPasterInfo> pasterInfoList = new LinkedList<>();

        for (FloatLayerView view : mFloatLayerViewList) {
            Bitmap image = view.getRotateBitmap();
            if (image == null) {
                continue;
            }

            TUIMultimediaPasterInfo pasterInfo = new TUIMultimediaPasterInfo();
            TXRect frame = new TXRect();
            frame.width = view.getImageWidth();
            frame.x = view.getImageLeft();
            frame.y = view.getImageTop();
            pasterInfo.frame = frame;
            pasterInfo.image = image;
            pasterInfo.pasterType = view.getPasterType();

            pasterInfoList.add(pasterInfo);
        }

        return pasterInfoList;
    }

    public void unSelectOperationView() {
        if (mSelectedFloatLayerView != null) {
            mSelectedFloatLayerView.unSelect();
        }
    }

    public void setCanTouch(boolean touch) {
        for (FloatLayerView floatLayerView : mFloatLayerViewList) {
            if (floatLayerView != null) {
                floatLayerView.setCanTouch(touch);
            }
        }
    }

    @Override
    public int getChildCount() {
        return mFloatLayerViewList.size();
    }

}
