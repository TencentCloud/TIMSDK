package com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.ui.picker;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Intent;
import android.content.res.Configuration;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
import com.tencent.qcloud.tuicore.permission.PermissionCallback;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuimultimediacore.TUIMultimediaCore;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.BaseBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.BucketBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.beans.VideoBean;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.interfaces.AlbumClickListener;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.interfaces.OnSelectedBucketChangedListener;
import com.tencent.qcloud.tuikit.tuimultimediacore.pick.ui.picker.AlbumGridView;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.R;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.permission.ImageVideoPermissionRequester;
import com.tencent.qcloud.tuikit.tuimultimediaplugin.pick.ui.previewer.AlbumPreviewFragment;
import java.util.ArrayList;
import java.util.List;

public class AlbumPickerActivity extends AppCompatActivity {
    private static final String TAG = "AlbumSelectorActivity";
    private static final int DEFAULT_ANIM_DURATION = 200;

    private View closeButton;

    private AlbumGridView albumGridView;

    private BucketListPop bucketListPop;
    private View bucketView;
    private TextView bucketNameTv;
    private ImageView bucketNameIv;
    private TextView fullImageTv;
    private ImageView fullImageCheckbox;
    private TextView previewButton;
    private TextView sendTv;

    private boolean inAnimation = false;
    private boolean isFullImage = false;
    private BucketBean currentBucket;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        checkPermissionAndLoad();

        setContentView(R.layout.multimedia_plugin_picker_selector_layout);

        setNavigationBar();

        closeButton = findViewById(R.id.close_button);
        albumGridView = findViewById(R.id.album_grid_view);
        bucketView = findViewById(R.id.bucket_name_layout);
        bucketNameTv = findViewById(R.id.bucket_name_tv);
        bucketNameIv = findViewById(R.id.bucket_name_iv);
        bucketListPop = findViewById(R.id.bucket_list_pop);
        fullImageTv = findViewById(R.id.full_image_text);
        fullImageCheckbox = findViewById(R.id.full_image_check_box);
        previewButton = findViewById(R.id.preview_button);
        sendTv = findViewById(R.id.send_button);

        setOnClickListener();
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
    }

    private void checkPermissionAndLoad() {
        if (ImageVideoPermissionRequester.checkPermission()) {
            loadImages();
        } else {
            ImageVideoPermissionRequester.requestPermissions(new PermissionCallback() {
                @Override
                public void onGranted() {
                    loadImages();
                }
            });
        }
    }

    private void setNavigationBar() {
        int color = getResources().getColor(R.color.multimedia_plugin_picker_dark_color);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(color);
            getWindow().setNavigationBarColor(color);
        }
    }

    private void setOnClickListener() {
        albumGridView.setClickListener(new AlbumClickListener() {
            @Override
            public void onClick(BaseBean bean) {
                startPreview(bean);
            }

            @Override
            public void onSelectChanged(BaseBean bean) {
                setFooterButtonState();
            }
        });

        bucketListPop.setOnSelectedBucketChangedListener(new OnSelectedBucketChangedListener() {
            @Override
            public void onSelectedBucketChanged(BucketBean bucketBean) {
                currentBucket = bucketBean;
                bucketNameTv.setText(bucketBean.bucketName);
                albumGridView.setBucket(bucketBean);
            }
        });
        closeButton.setOnClickListener((v) -> {
            if (bucketListPop.isShowing()) {
                hideBucketList();
                return;
            }
            finish();
        });

        bucketView.setOnClickListener((v) -> {
            if (inAnimation) {
                return;
            }
            if (bucketListPop.isShowing()) {
                hideBucketList();
            } else {
                showBucketList();
            }
        });
        previewButton.setOnClickListener((v) -> {
            if (albumGridView.getSelectedPhotoList().isEmpty()) {
                return;
            }
            startPreview(null);
        });

        fullImageTv.setOnClickListener((v) -> toggleFullImage());
        fullImageCheckbox.setOnClickListener((v) -> toggleFullImage());
        sendTv.setOnClickListener((v) -> setSelectionResult());
    }

    private void setFooterButtonState() {
        List<BaseBean> selectedSet = albumGridView.getSelectedPhotoList();
        if (!selectedSet.isEmpty()) {
            previewButton.setTextColor(getResources().getColor(R.color.multimedia_plugin_picker_white_color));
            sendTv.setEnabled(true);
            sendTv.setText(getResources().getString(R.string.multimedia_plugin_picker_send) + "(" + selectedSet.size() + ")");
            previewButton.setText(getResources().getString(R.string.multimedia_plugin_picker_preview) + "(" + selectedSet.size() + ")");
        } else {
            previewButton.setTextColor(getResources().getColor(R.color.multimedia_plugin_picker_light_gray));
            sendTv.setEnabled(false);
            sendTv.setText(R.string.multimedia_plugin_picker_send);
            previewButton.setText(R.string.multimedia_plugin_picker_preview);
        }
    }

    private void startPreview(BaseBean previewBean) {
        AlbumPreviewFragment fragment = new AlbumPreviewFragment();
        fragment.setAlbumGridView(albumGridView);
        fragment.setFullImage(this.isFullImage);
        fragment.setPreviewBean(previewBean);
        fragment.setBucketBean(currentBucket);
        fragment.setOnSelectClickListener((v) -> setFooterButtonState());
        fragment.setOnSendClickListener((v) -> setSelectionResult());
        fragment.setOnFullImageClickListener((v) -> toggleFullImage());
        fragment.show(getSupportFragmentManager(), "AlbumPreview");
    }

    private void toggleFullImage() {
        this.isFullImage = !this.isFullImage;
        if (isFullImage) {
            fullImageCheckbox.setSelected(true);
        } else {
            fullImageCheckbox.setSelected(false);
        }
    }

    private void showBucketList() {
        bucketListPop.show();
        startAnim();
    }

    private void hideBucketList() {
        bucketListPop.dismiss();
        startAnim();
    }

    private void startAnim() {
        inAnimation = true;
        bucketNameIv.animate().rotationBy(180).setDuration(DEFAULT_ANIM_DURATION).setListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationPause(Animator animation) {
                inAnimation = false;
            }

            @Override
            public void onAnimationEnd(Animator animation) {
                inAnimation = false;
            }

            @Override
            public void onAnimationCancel(Animator animation) {
                inAnimation = false;
            }
        });
    }

    private void loadImages() {

        TUIMultimediaCore.getBucketBeanList(new TUIValueCallback<List<BucketBean>>() {
            @Override
            public void onSuccess(List<BucketBean> bucketBeanList) {
                if (bucketBeanList.isEmpty()) {
                    return;
                }
                currentBucket = bucketBeanList.get(0);
                bucketListPop.setSelectedBucketBean(currentBucket);
                bucketListPop.setData(bucketBeanList);
                albumGridView.setBucket(currentBucket);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIChatLog.e(TAG, "getBucketBeanList error: " + errorMessage);
            }
        });
    }

    private void setSelectionResult() {
        boolean isFullImage = this.isFullImage;
        List<BaseBean> selectedList = albumGridView.getSelectedPhotoList();
        if (isFullImage) {
            ArrayList<Uri> originalUris = new ArrayList<>(selectedList.size());
            for (BaseBean baseBean : selectedList) {
                originalUris.add(baseBean.getFinalUri());
            }

            Intent intent = new Intent();
            intent.putParcelableArrayListExtra("data", originalUris);
            setResult(RESULT_OK, intent);
            finish();
        } else {
            ArrayList<Uri> transcodeList = new ArrayList<>();
            ArrayList<Uri> originalUris = new ArrayList<>();
            for (BaseBean baseBean : selectedList) {
                if (baseBean instanceof VideoBean) {
                    if (baseBean.editedUri == null) {
                        transcodeList.add(baseBean.uri);
                    } else {
                        originalUris.add(baseBean.editedUri);
                    }
                } else {
                    originalUris.add(baseBean.getFinalUri());
                }
            }

            Intent intent = new Intent();
            intent.putParcelableArrayListExtra("data", originalUris);
            intent.putParcelableArrayListExtra("transcodeData", transcodeList);
            setResult(RESULT_OK, intent);
            finish();
        }
    }
}
