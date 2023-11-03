package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.OrientationHelper;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.ArrayList;
import java.util.List;

public class ImageVideoScanActivity extends AppCompatActivity {
    private static final String TAG = ImageVideoScanActivity.class.getSimpleName();

    private RecyclerView mRecyclerView;
    private ImageVideoScanAdapter mAdapter;
    private ViewPagerLayoutManager mLayoutManager;
    private ImageVideoScanPresenter mImageVideoScanPresenter;
    private ImageView mDownloadView;

    private TUIMessageBean mCurrentMessageBean = null;
    private List<TUIMessageBean> mForwardDataSource = new ArrayList<>();
    private boolean mIsForwardMode = false;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN, WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.tuichat_image_video_scan_layout);

        mIsForwardMode = getIntent().getBooleanExtra(TUIChatConstants.FORWARD_MODE, false);
        if (mIsForwardMode) {
            mForwardDataSource = (List<TUIMessageBean>) getIntent().getSerializableExtra(TUIChatConstants.OPEN_MESSAGES_SCAN_FORWARD);
            if (mForwardDataSource == null || mForwardDataSource.isEmpty()) {
                TUIChatLog.e(TAG, "mForwardDataSource is null");
                return;
            }
        }

        mCurrentMessageBean = (TUIMessageBean) getIntent().getSerializableExtra(TUIChatConstants.OPEN_MESSAGE_SCAN);
        if (mCurrentMessageBean == null) {
            TUIChatLog.e(TAG, "mCurrentMessageBean is null");
            return;
        }
        initView();
        initData();
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        setContentView(R.layout.tuichat_image_video_scan_layout);
        initView();
        initData();
    }

    private void initView() {
        mRecyclerView = findViewById(R.id.recycler);
        mDownloadView = findViewById(R.id.download_button);
        mDownloadView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                TUIChatLog.d(TAG, "onClick");
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    mImageVideoScanPresenter.saveLocal(ImageVideoScanActivity.this);
                } else {
                    PermissionHelper.requestPermission(PermissionHelper.PERMISSION_STORAGE, new PermissionHelper.PermissionCallback() {
                        @Override
                        public void onGranted() {
                            mImageVideoScanPresenter.saveLocal(ImageVideoScanActivity.this);
                        }

                        @Override
                        public void onDenied() {
                            ToastUtil.toastShortMessage(getString(R.string.save_failed));
                        }
                    });
                }
            }
        });

        mLayoutManager = new ViewPagerLayoutManager(this, OrientationHelper.HORIZONTAL);
        mAdapter = new ImageVideoScanAdapter();
        mRecyclerView.setLayoutManager(mLayoutManager);
        mRecyclerView.setAdapter(mAdapter);

        mImageVideoScanPresenter = new ImageVideoScanPresenter();
        mImageVideoScanPresenter.initChatEventListener();
        mImageVideoScanPresenter.setAdapter(mAdapter);
        mImageVideoScanPresenter.setRecyclerView(mRecyclerView);
        mImageVideoScanPresenter.setViewPagerLayoutManager(mLayoutManager);

        mAdapter.setOnItemClickListener(new OnItemClickListener() {
            @Override
            public void onClickItem() {
                finish();
            }
        });
    }

    public void initData() {
        if (getIntent() == null) {
            return;
        }
        mImageVideoScanPresenter.setActivity(this);
        mImageVideoScanPresenter.init(mCurrentMessageBean, mForwardDataSource, mIsForwardMode);
    }

    public void onItemSelected(TUIMessageBean messageBean) {
        if (messageBean != null) {
            mCurrentMessageBean = messageBean;
            if (mCurrentMessageBean.hasRiskContent()) {
                mDownloadView.setVisibility(View.GONE);
            } else {
                mDownloadView.setVisibility(View.VISIBLE);
            }
        }
    }

    public void onCurrentMessageHasRiskContent(TUIMessageBean messageBean) {
        mDownloadView.setVisibility(View.GONE);
        TUIKitDialog dialog = new TUIKitDialog(this).builder();
        String title = getString(R.string.chat_risk_image_message_alert);
        if (messageBean instanceof ImageMessageBean) {
            title = getString(R.string.chat_scan_risk_image_message_alert);
        } else if (messageBean instanceof VideoMessageBean) {
            title = getString(R.string.chat_scan_risk_video_message_alert);
        }
        dialog.setTitle(title)
            .setCancelOutside(false)
            .setPositiveButton(getString(R.string.chat_i_know),
                new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        if (mAdapter != null) {
                            mAdapter.onDataChanged(messageBean);
                        }
                        dialog.dismiss();
                    }
                })
            .show();
    }

    public TUIMessageBean getCurrentMessageBean() {
        return mCurrentMessageBean;
    }

    @Override
    protected void onPause() {
        TUIChatLog.i(TAG, "onPause");
        super.onPause();
        if (mImageVideoScanPresenter != null) {
            mImageVideoScanPresenter.releaseUI();
        }
    }

    public interface OnItemClickListener {
        void onClickItem();
    }
}