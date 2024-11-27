package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaIConfig;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaResourceUtils;
import java.io.FileInputStream;
import java.io.FileNotFoundException;

public class TUIMultimediaPictureEditFragment extends Fragment {

    private final String TAG = TUIMultimediaPictureEditFragment.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;

    private View mRootView;
    private String mRecordFilePath;

    public TUIMultimediaPictureEditFragment(Context context) {
        mContext = context;
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreateView");
        mRootView = inflater.inflate(R.layout.multimedia_plugin_edit_picture_fragment, container, false);
        initView();
        return mRootView;
    }

    @Override
    public void onDestroyView() {
        LiteavLog.i(TAG, "onDestroyView");
        super.onDestroyView();
    }

    @Override
    public void onDestroy() {
        LiteavLog.i(TAG, "onDestroy");
        super.onDestroy();
    }

    public void initView() {
        initSendBtn();

        mRootView.findViewById(R.id.edit_return_back).setOnClickListener(
                v -> ((AppCompatActivity) mContext).getSupportFragmentManager().popBackStack());

        Bundle bundle = getArguments();
        if (bundle == null) {
            return;
        }
        mRecordFilePath = bundle.getString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH);
        previewPicture(mRecordFilePath);
    }

    private void initSendBtn() {
        Button imageButton = mRootView.findViewById(R.id.send_btn);
        imageButton.setBackground(TUIMultimediaResourceUtils
                .getDrawable(mContext, R.drawable.multimedia_plugin_edit_send_button, TUIMultimediaIConfig
                .getInstance().getThemeColor()));
        imageButton.setGravity(Gravity.CENTER);
        imageButton.setOnClickListener(v -> finishEdit());
    }

    private void previewPicture(String photoFilePath) {
        LiteavLog.i(TAG, "preview picture. file path = " + photoFilePath);
        ImageView imageView = new ImageView(mContext);
        RelativeLayout relativeLayoutContainer = mRootView.findViewById(R.id.fl_media_preview_picture_view_container);
        relativeLayoutContainer.removeAllViews();
        relativeLayoutContainer.addView(imageView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));
        try {
            FileInputStream fis = new FileInputStream(photoFilePath);
            Bitmap bitmap = BitmapFactory.decodeStream(fis);
            imageView.setBackground(TUIMultimediaResourceUtils.getColorDrawable(R.color.multimedia_plugin_black));
            imageView.setImageBitmap(bitmap);
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }
    }

    private void finishEdit() {
        LiteavLog.i(TAG, "finish record. path = " + mRecordFilePath);
        Intent resultIntent = new Intent();
        resultIntent.putExtra(TUIMultimediaConstants.PARAM_NAME_EDITED_FILE_PATH, mRecordFilePath);
        resultIntent.putExtra(TUIMultimediaConstants.RECORD_TYPE_KEY, TUIMultimediaConstants.RECORD_TYPE_PHOTO);
        ((Activity) mContext).setResult(Activity.RESULT_OK, resultIntent);
        ((Activity) mContext).finish();
    }
}
