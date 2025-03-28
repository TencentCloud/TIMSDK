package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush;

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
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.brush.BrushToolView.BrushToolListener;
import com.tencent.ugc.TXVideoEditConstants.TXRect;

public class BrushControlView {

    public final TUIMultimediaData<Boolean> tuiDataIsDrawing = new TUIMultimediaData<>(false);
    private final String TAG = BrushControlView.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;
    private final RelativeLayout mBrushToolViewContainer;

    private BrushDrawView mBrushDrawView;
    private BrushToolView mBrushToolView;
    private Boolean mEnableDraw = false;
    private BrushMode mBrushMode = BrushMode.GRAFFITI;

    public enum BrushMode {
        GRAFFITI,
        MOSAIC
    }

    public BrushControlView(Context context,
            RelativeLayout brushToolViewContainer) {
        mBrushToolViewContainer = brushToolViewContainer;
        mContext = context;
        initView();
    }

    public void enableDraw(boolean enable) {
        LiteavLog.i(TAG, (enable ? " enable" : "disEnable") + " draw");
        mEnableDraw = enable;
        mBrushDrawView.enableDraw(enable);
    }

    public void showToolView(boolean show) {
        mBrushToolViewContainer.setVisibility(show ? View.VISIBLE : View.GONE);
    }

    public void showDrawView(boolean show) {
        mBrushDrawView.setVisibility(show ? View.VISIBLE : View.INVISIBLE);
    }

    public void setBrushMode(BrushMode brushMode) {
        mBrushMode = brushMode;
        mBrushDrawView.setBrushMode(mBrushMode);
        mBrushToolView.setBrushMode(mBrushMode);
        mBrushToolView.enableRedo(mBrushDrawView.canRedo());
        mBrushToolView.enableUndo(mBrushDrawView.canUndo());
    }

    public void setMosaicImage(Bitmap bitmap) {
        mBrushDrawView.setMosaicImage(bitmap);
    }

    public BrushMode getBrushMode() {
        return mBrushMode;
    }

    public boolean isEnableDraw() {
        return mEnableDraw;
    }

    public TUIMultimediaPasterInfo getPaster() {
        Bitmap image = mBrushDrawView.getDrawingBitmap();
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

    public void clean() {
        mBrushDrawView.clean();
    }

    public View getBrushDrawView() {
        return mBrushDrawView;
    }

    private void initView() {
        mBrushToolView = new BrushToolView(mContext);
        mBrushToolViewContainer.removeAllViews();
        mBrushToolViewContainer.addView(mBrushToolView, new LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));

        mBrushDrawView = new BrushDrawView(mContext, mBrushToolView.mTuiDataSelectedTextColor,
                tuiDataIsDrawing);

        tuiDataIsDrawing.observe(isDrawing -> updateToolStatus());

        mBrushToolView.setBrushToolListener(new BrushToolListener() {
            @Override
            public void redo() {
                mBrushDrawView.redo();
                updateToolStatus();
            }

            @Override
            public void undo() {
                mBrushDrawView.undo();
                updateToolStatus();
            }
        });
    }

    private void updateToolStatus() {
        mBrushToolView.enableRedo(mBrushDrawView.canRedo());
        mBrushToolView.enableUndo(mBrushDrawView.canUndo());
    }
}
