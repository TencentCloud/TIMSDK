package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.floatlayer;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Rect;
import android.util.AttributeSet;
import android.view.View;
import android.widget.FrameLayout;
import androidx.annotation.NonNull;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.liteav.base.util.Size;
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

    public void addFloatLayerView(FloatLayerView view) {
        if (view == null) {
            return;
        }
        mFloatLayerViewList.add(view);
        addView(view, MATCH_PARENT, MATCH_PARENT);
        view.tuiDataGetStatus().observe(status -> {
            if (status == Status.STATUS_SELECTED) {
                if (mSelectedFloatLayerView != null && view != mSelectedFloatLayerView) {
                    mSelectedFloatLayerView.unSelect();
                }
                mSelectedFloatLayerView = view;
            }
        });
    }

    public void removeFloatLayerView(FloatLayerView view) {
        if (view == null) {
            return;
        }
        mFloatLayerViewList.remove(view);
        removeView(view);
    }

    public void removeAllFloatLayerView() {
        for(FloatLayerView view : mFloatLayerViewList) {
            removeView(view);
        }
        mFloatLayerViewList.clear();
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

    @SuppressLint("DrawAllocation")
    @Override
    protected void onLayout(boolean changed, int l, int t, int r, int b) {
        for (int i = 0; i < getChildCount(); i++) {
            View view = getChildAt(i);
            if (view instanceof FloatLayerView) {
                ((FloatLayerView)view).onParentSizeChange(new Size(r - l, b - t));
            }
            view.invalidate();
        }
    }
}
