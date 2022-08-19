package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;

import androidx.recyclerview.widget.OrientationHelper;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.PermissionHelper;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.List;


public class ImageVideoScanActivity extends Activity {
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
        setContentView(R.layout.image_video_scan_layout);

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

        mImageVideoScanPresenter.init(mCurrentMessageBean, mForwardDataSource, mIsForwardMode);
    }

    public interface OnItemClickListener {
        void onClickItem();
    }

    @Override
    protected void onPause() {
        TUIChatLog.i(TAG, "onPause");
        super.onPause();
        if (mImageVideoScanPresenter != null) {
            mImageVideoScanPresenter.releaseUI();
        }
    }

}