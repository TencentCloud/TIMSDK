package com.tencent.qcloud.tuikit.tuimultimediaplugin.edit;

import static android.view.ViewGroup.LayoutParams.MATCH_PARENT;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.Bitmap.CompressFormat;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import com.bumptech.glide.Glide;
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool;
import com.bumptech.glide.load.resource.bitmap.BitmapTransformation;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.liteav.base.util.LiteavLog;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.TUIMultimediaConstants;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaAuthorizationPrompter;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.common.TUIMultimediaFileUtil.MultimediaPluginFileType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultiMediaEditCommonCtrlView.CommonMediaEditListener;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultiMediaEditCommonCtrlView.EditType;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.edit.TUIMultiMediaEditCommonCtrlView.PictureCropListener;
import com.tencent.ugc.TXVideoEditConstants.TXPaster;
import com.tencent.ugc.videobase.utils.CollectionUtils;
import java.io.File;
import java.security.MessageDigest;
import java.util.List;

public class TUIMultimediaPictureEditFragment extends Fragment {

    private final String TAG = TUIMultimediaPictureEditFragment.class.getSimpleName() + "_" + hashCode();
    private final Context mContext;

    private TUIMultimediaPictureEditorCore mTuiMultimediaPictureEditorCore;
    private View mRootView;
    private String mPictureFilePath;
    private Bitmap mCurrentBitmap;
    private Bitmap mBeforeCropBitmap;
    private Bitmap mOriginBitmap;
    private ImageView mImageView;
    private boolean mIsRecordFile = true;

    public TUIMultimediaPictureEditFragment(Context context) {
        mContext = context;
    }

    public static class RotateTransformation extends BitmapTransformation {

        private final float rotateRotationAngle;

        public RotateTransformation(float rotateRotationAngle) {
            this.rotateRotationAngle = rotateRotationAngle;
        }

        @Override
        protected Bitmap transform(@NonNull BitmapPool pool, Bitmap toTransform, int outWidth, int outHeight) {
            Matrix matrix = new Matrix();
            matrix.postRotate(rotateRotationAngle, toTransform.getWidth() / 2.0f, toTransform.getHeight() / 2.0f);
            return Bitmap
                    .createBitmap(toTransform, 0, 0, toTransform.getWidth(), toTransform.getHeight(), matrix, true);
        }

        @Override
        public void updateDiskCacheKey(MessageDigest messageDigest) {
            messageDigest.update(("rotate" + rotateRotationAngle).getBytes(CHARSET));
        }
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        LiteavLog.i(TAG, "onCreate");
        super.onCreate(savedInstanceState);
        mTuiMultimediaPictureEditorCore = new TUIMultimediaPictureEditorCore(mContext);
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
        mTuiMultimediaPictureEditorCore.release();
    }

    public void initView() {
        initExternalParameters();

        TUIMultiMediaEditCommonCtrlView editCommonCtrlView = new TUIMultiMediaEditCommonCtrlView(mContext,
                EditType.PHOTO, mIsRecordFile);
        ((RelativeLayout) mRootView.findViewById(R.id.edit_common_ctrl_view_container))
                .addView(editCommonCtrlView, new RelativeLayout.LayoutParams(MATCH_PARENT, MATCH_PARENT));

        LiteavLog.i(TAG, "preview picture. file path = " + mPictureFilePath);
        mOriginBitmap = TUIMultimediaFileUtil.decodeBitmap(mPictureFilePath);
        mCurrentBitmap = mOriginBitmap;
        if (mCurrentBitmap == null) {
            LiteavLog.e(TAG, "decode bitmap fail");
            return;
        }

        mImageView = new ImageView(mContext);
        editCommonCtrlView.setMediaView(mImageView);
        editCommonCtrlView.setMediaAspectRatio(mCurrentBitmap.getWidth() * 1.0f / mCurrentBitmap.getHeight());
        editCommonCtrlView.setPicture(mCurrentBitmap);
        previewPicture(0);
        mTuiMultimediaPictureEditorCore.setSourcePicture(mCurrentBitmap);
        editCommonCtrlView.setCommonMediaEditListener(new CommonMediaEditListener() {
            @Override
            public void onGenerateMedia() {
                if (!TUIMultimediaAuthorizationPrompter.verifyPermissionGranted(mContext)) {
                    return;
                }

                List<TXPaster> pasterList = editCommonCtrlView.getNormalizedPaster();
                LiteavLog.i(TAG, "on generate media." + " is recordFile: " + mIsRecordFile + " pasterList size is:" + (
                        pasterList != null ? pasterList.size() : 0));
                if (CollectionUtils.isEmpty(pasterList)) {
                    Bitmap bitmap = mTuiMultimediaPictureEditorCore.getSourcePicture();
                    if (bitmap == mOriginBitmap && !mIsRecordFile) {
                        finishEdit(null);
                    } else {
                        finishEdit(savaBitmapToLocalFile(bitmap));
                    }
                } else {
                    mTuiMultimediaPictureEditorCore.setPasterList(pasterList);
                    mTuiMultimediaPictureEditorCore.processPicture(bitmap -> finishEdit(savaBitmapToLocalFile(bitmap)));
                }
            }

            @Override
            public void onCancelEdit() {
                cancelEdit();
            }
        });
        editCommonCtrlView.setPictureCropListener(new PictureCropListener() {
            @Override
            public void onConfirmCrop(RectF rectF, int rotation) {

                mTuiMultimediaPictureEditorCore.setCropRectF(rectF);
                mTuiMultimediaPictureEditorCore.setOutputRotation(rotation);

                mTuiMultimediaPictureEditorCore.processPicture(bitmap -> {
                    mCurrentBitmap = bitmap;
                    previewPicture(0);
                    mTuiMultimediaPictureEditorCore.resetEditor();
                    mTuiMultimediaPictureEditorCore.setSourcePicture(mCurrentBitmap);
                    editCommonCtrlView.setMediaAspectRatio(mCurrentBitmap.getWidth() * 1.0f / mCurrentBitmap.getHeight());
                    editCommonCtrlView.setPicture(mCurrentBitmap);
                });
            }

            @Override
            public void onRotation(int rotation) {
                LiteavLog.i(TAG, "onRotation rotation:" + rotation);
                previewPicture(rotation);
            }

            @Override
            public void onStartCrop() {
                TUIMultimediaAuthorizationPrompter.verifyPermissionGranted(mContext);
                mTuiMultimediaPictureEditorCore
                        .setPasterList(editCommonCtrlView.getNormalizedPaster());
                mBeforeCropBitmap = mCurrentBitmap;
                mTuiMultimediaPictureEditorCore.processPicture(bitmap -> {
                    mCurrentBitmap = bitmap;
                    previewPicture(0);
                    mTuiMultimediaPictureEditorCore.setSourcePicture(mCurrentBitmap);
                });
            }

            @Override
            public void onCancelCrop() {
                mCurrentBitmap = mBeforeCropBitmap;
                previewPicture(0);
                mTuiMultimediaPictureEditorCore.setSourcePicture(mCurrentBitmap);
            }
        });
    }

    private String savaBitmapToLocalFile(Bitmap bitmap) {
        String outVideoPath = TUIMultimediaFileUtil.generateFilePath(MultimediaPluginFileType.PICTURE_FILE);
        TUIMultimediaFileUtil.saveBmpToFile(bitmap, new File(outVideoPath), CompressFormat.JPEG);
        return outVideoPath;
    }

    private void previewPicture(float rotation) {
        if (mImageView == null || mCurrentBitmap == null) {
            return;
        }
        LiteavLog.i(TAG, "previewPicture rotation : " + rotation);
        Glide.with(mContext)
                .load(mCurrentBitmap).apply(RequestOptions.bitmapTransform(new RotateTransformation(rotation)))
                .into(mImageView);
    }

    private void cancelEdit() {
        if (mIsRecordFile) {
            ((AppCompatActivity) mContext).getSupportFragmentManager().popBackStack();
        } else {
            finishEdit(null);
        }
    }

    private void finishEdit(String editedFilePath) {
        LiteavLog.i(TAG, "finish edit. path = " + editedFilePath);
        Intent resultIntent = new Intent();
        if (editedFilePath != null) {
            resultIntent.putExtra(TUIMultimediaConstants.PARAM_NAME_EDITED_FILE_PATH, editedFilePath);
            resultIntent.putExtra(TUIMultimediaConstants.RECORD_TYPE_KEY, TUIMultimediaConstants.RECORD_TYPE_PHOTO);
        }
        ((Activity) mContext).setResult(Activity.RESULT_OK, resultIntent);
        ((Activity) mContext).finish();
    }

    private void initExternalParameters() {
        Bundle bundle = getArguments();
        if (bundle == null) {
            return;
        }
        mPictureFilePath = bundle.getString(TUIMultimediaConstants.PARAM_NAME_EDIT_FILE_PATH);
        mIsRecordFile = bundle.getBoolean(TUIMultimediaConstants.PARAM_NAME_IS_RECODE_FILE, false);
    }
}
