package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import android.app.Activity;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import android.widget.RelativeLayout;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.OrientationHelper;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
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
        //去除标题栏
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        //去除状态栏
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
                String[] PERMISSIONS = {
                                "android.permission.READ_EXTERNAL_STORAGE",
                                "android.permission.WRITE_EXTERNAL_STORAGE" };
                //检测是否有写的权限
                int permission = ContextCompat.checkSelfPermission(ImageVideoScanActivity.this,
                                "android.permission.WRITE_EXTERNAL_STORAGE");
                if (permission != PackageManager.PERMISSION_GRANTED) {
                        // 没有写的权限，去申请写的权限，会弹出对话框
                    ActivityCompat.requestPermissions(ImageVideoScanActivity.this, PERMISSIONS,1);
                }
                mImageVideoScanPresenter.saveLocal(ImageVideoScanActivity.this);
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