package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.graffiti;

import android.content.Context;
import android.graphics.Bitmap;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewGroup.LayoutParams;
import android.widget.RelativeLayout;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaData;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultimediaPasterInfo.PasterType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.graffiti.GraffitiOperationView.GraffitiOperationListener;
import com.tencent.ugc.TXVideoEditConstants.TXRect;

public class GraffitiPanelView {

    public final TUIMultimediaData<Boolean> tuiDataIsDrawing = new TUIMultimediaData<>(false);
    private final String TAG = GraffitiPanelView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final RelativeLayout mGraffitiDrawViewContainer;
    private final RelativeLayout mGraffitiOperationViewContainer;

    private GraffitiDrawView mGraffitiDrawView;
    private GraffitiOperationView mGraffitiOperationView;
    private Boolean mEnable = false;

    public GraffitiPanelView(Context context, RelativeLayout graffitiDrawViewContainer,
            RelativeLayout graffitiOperationViewContainer) {
        mGraffitiDrawViewContainer = graffitiDrawViewContainer;
        mGraffitiOperationViewContainer = graffitiOperationViewContainer;
        mContext = context;
        initView();
    }

    public void enableGraffiti(boolean enable) {
        LiteavLog.i(TAG, (enable ? " enable" : "disEnable") + " Graffiti");
        mEnable = enable;
        if (mGraffitiDrawView != null) {
            mGraffitiDrawView.enableGraffiti(enable);
        }
    }

    public void showOperationView(boolean show) {
        mGraffitiOperationViewContainer.setVisibility(show ? View.VISIBLE : View.GONE);
    }

    public boolean isEnableGraffiti() {
        return mEnable;
    }

    public TUIMultimediaPasterInfo getGraffitiPaster() {
        Bitmap image = mGraffitiDrawView.getDrawingBitmap();
        if (image == null) {
            return null;
        }

        TUIMultimediaPasterInfo pasterInfo = new TUIMultimediaPasterInfo();
        TXRect frame = new TXRect();
        frame.width = image.getWidth();
        frame.x = 0;
        frame.y = 0;
        pasterInfo.frame = frame;
        pasterInfo.image = image;
        pasterInfo.pasterType = PasterType.STATIC_PICTURE_PASTER;
        return pasterInfo;
    }

    private void initView() {
        mGraffitiOperationView = new GraffitiOperationView(mContext);
        mGraffitiOperationViewContainer.removeAllViews();
        mGraffitiOperationViewContainer.addView(mGraffitiOperationView, new LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));

        mGraffitiDrawView = new GraffitiDrawView(mContext, mGraffitiOperationView.mTuiDataSelectedTextColor,
                tuiDataIsDrawing);
        mGraffitiDrawViewContainer.removeAllViews();
        mGraffitiDrawViewContainer.addView(mGraffitiDrawView, new LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));

        tuiDataIsDrawing.observe(isDrawing -> setForwardAndBackButtonStatus());

        mGraffitiOperationView.setGraffitiOperationListener(new GraffitiOperationListener() {
            @Override
            public void forward() {
                mGraffitiDrawView.front();
                setForwardAndBackButtonStatus();
            }

            @Override
            public void back() {
                mGraffitiDrawView.back();
                setForwardAndBackButtonStatus();
            }
        });
    }

    private void setForwardAndBackButtonStatus() {
        mGraffitiOperationView.enableForward(mGraffitiDrawView.canForward());
        mGraffitiOperationView.enableBack(mGraffitiDrawView.canBack());
    }
}
