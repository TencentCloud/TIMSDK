package com.tencent.qcloud.tuikit.tuichat.component.imagevideobrowse;

import android.content.res.Configuration;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;
import com.tencent.qcloud.tuicore.interfaces.TUIValueCallback;
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

public class ImageVideoBrowseActivity extends AppCompatActivity implements ImageVideoBrowseListener {
    private static final String TAG = ImageVideoBrowseActivity.class.getSimpleName();

    private ViewPager2 viewPager;
    private ImageVideoBrowseAdapter mAdapter;
    private ImageVideoBrowsePresenter presenter;
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
        viewPager = findViewById(R.id.view_pager);
        mDownloadView = findViewById(R.id.download_button);
        mDownloadView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                TUIChatLog.d(TAG, "onClick");
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    presenter.saveLocal(ImageVideoBrowseActivity.this);
                } else {
                    PermissionHelper.requestPermission(PermissionHelper.PERMISSION_STORAGE, new PermissionHelper.PermissionCallback() {
                        @Override
                        public void onGranted() {
                            presenter.saveLocal(ImageVideoBrowseActivity.this);
                        }

                        @Override
                        public void onDenied() {
                            ToastUtil.toastShortMessage(getString(R.string.save_failed));
                        }
                    });
                }
            }
        });

        presenter = new ImageVideoBrowsePresenter();
        presenter.initChatEventListener();

        mAdapter = new ImageVideoBrowseAdapter();
        viewPager.setAdapter(mAdapter);
        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                TUIMessageBean tuiMessageBean = mAdapter.getItem(position);
                onItemSelected(tuiMessageBean);
                presenter.setCurrentMessageBean(tuiMessageBean);
                if (mIsForwardMode) {
                    return;
                }
                if (position == 0) {
                    presenter.loadLocalMediaMessageForward(tuiMessageBean);
                }
                if (position == mAdapter.getItemCount() - 1) {
                    presenter.loadLocalMediaMessageBackward(tuiMessageBean);
                }
            }
        });

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
        presenter.setBrowseListener(this);
        presenter.init(mCurrentMessageBean, mForwardDataSource, mIsForwardMode);
    }

    private void onItemSelected(TUIMessageBean messageBean) {
        if (messageBean != null) {
            mCurrentMessageBean = messageBean;
            if (mCurrentMessageBean.hasRiskContent()) {
                mDownloadView.setVisibility(View.GONE);
            } else {
                mDownloadView.setVisibility(View.VISIBLE);
            }
        }
    }

    @Override
    public void onMessageHasRiskContent(TUIMessageBean messageBean) {
        mAdapter.onMessageHasRiskContent(messageBean);
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

    @Override
    public void onDataChanged(TUIMessageBean messageBean) {
        mAdapter.onDataChanged(messageBean);
    }

    @Override
    public void setDataSource(List<TUIMessageBean> messageBeans) {
        mAdapter.setDataSource(messageBeans);
    }

    public void onDataSourceInserted(int position, int count) {
        mAdapter.notifyItemRangeInserted(position, count);
    }

    public void onDataSourceChanged() {
        mAdapter.notifyDataSetChanged();
    }

    @Override
    public void setCurrentItem(int position) {
        viewPager.setCurrentItem(position, false);
    }

    public interface OnItemClickListener {
        void onClickItem();
    }
}