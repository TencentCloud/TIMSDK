package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import androidx.fragment.app.Fragment;
import com.tencent.qcloud.tuikit.timcommon.interfaces.OnFaceInputListener;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceView;

public class FaceFragment extends Fragment {
    private boolean showCustomFace = true;
    private FaceView faceView;
    private OnFaceInputListener onFaceInputListener;
    private int backgroundColor;
    private int indicatorColor;
    private Drawable indicator;

    public void setShowCustomFace(boolean showCustomFace) {
        this.showCustomFace = showCustomFace;
    }

    public void setTabIndicatorColor(int indicatorColor) {
        this.indicatorColor = indicatorColor;
    }

    public void setTabIndicator(Drawable indicator) {
        this.indicator = indicator;
    }

    public void setBackgroundColor(int backgroundColor) {
        this.backgroundColor = backgroundColor;
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        faceView = new FaceView(getContext(), showCustomFace);
        FrameLayout.LayoutParams params = new FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT, getContext().getResources().getDimensionPixelSize(R.dimen.chat_face_input_fragment_height));
        params.bottomMargin = getContext().getResources().getDimensionPixelSize(R.dimen.chat_face_input_bottom_margin);
        faceView.setLayoutParams(params);
        if (indicator != null) {
            faceView.setTabIndicator(indicator);
        }
        if (indicatorColor != Color.WHITE) {
            faceView.setTabIndicatorColor(indicatorColor);
        }
        faceView.setBackgroundColor(backgroundColor);
        faceView.setOnFaceInputListener(onFaceInputListener);
        return faceView;
    }

    public void setListener(OnFaceInputListener listener) {
        this.onFaceInputListener = listener;
    }
}
