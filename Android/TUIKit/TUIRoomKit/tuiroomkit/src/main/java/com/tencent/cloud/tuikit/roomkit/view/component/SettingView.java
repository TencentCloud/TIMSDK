package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;

import com.google.android.material.tabs.TabLayout;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.model.manager.RoomEngineManager;
import com.tencent.cloud.tuikit.roomkit.view.base.BaseBottomDialog;
import com.tencent.cloud.tuikit.roomkit.view.settingview.AudioSettingView;
import com.tencent.cloud.tuikit.roomkit.view.settingview.ShareSettingView;
import com.tencent.cloud.tuikit.roomkit.view.settingview.VideoSettingView;
import com.tencent.cloud.tuikit.roomkit.viewmodel.SettingViewModel;

import java.util.ArrayList;
import java.util.List;

public class SettingView extends BaseBottomDialog {
    private boolean                mEnableShare = true;
    private TabLayout              mLayoutTop;
    private ViewPager              mViewPagerContent;
    private SettingViewPageAdapter mPagerAdapter;
    private VideoSettingView       mVideoSettingView;
    private AudioSettingView       mAudioSettingView;
    private ShareSettingView       mShareSettingView;
    private List<View>             mFragmentList;
    private List<String>           mTitleList;
    private SettingViewModel       mViewModel;

    public SettingView(@NonNull Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId() {
        return R.layout.tuiroomkit_view_setting;
    }

    @Override
    protected void intiView() {
        mViewModel = new SettingViewModel(getContext(), this);
        mLayoutTop = findViewById(R.id.tl_top);
        mViewPagerContent = findViewById(R.id.vp_content);

        mTitleList = new ArrayList<>();
        mTitleList.add(getContext().getString(R.string.tuiroomkit_title_video));
        mTitleList.add(getContext().getString(R.string.tuiroomkit_title_audio));
        mTitleList.add(getContext().getString(R.string.tuiroomkit_title_sharing));
        initFragment();

        mPagerAdapter = new SettingViewPageAdapter(mFragmentList);
        mLayoutTop.setupWithViewPager(mViewPagerContent, false);

        mViewPagerContent.setAdapter(mPagerAdapter);
        for (int i = 0; i < mTitleList.size(); i++) {
            TabLayout.Tab tab = mLayoutTop.getTabAt(i);
            if (tab != null) {
                tab.setText(mTitleList.get(i));
            }
        }
    }

    private void initFragment() {
        if (mFragmentList == null) {
            mFragmentList = new ArrayList<>();
            mVideoSettingView = new VideoSettingView(getContext(), new VideoSettingView.OnItemChangeListener() {
                @Override
                public void onVideoBitrateChange(int bitrate) {
                    mViewModel.setVideoBitrate(bitrate);
                }

                @Override
                public void onVideoResolutionChange(int resolution) {
                    mViewModel.setVideoResolution(resolution);
                }

                @Override
                public void onVideoFpsChange(int fps) {
                    mViewModel.setVideoFps(fps);
                }

                @Override
                public void onVideoLocalMirrorChange(boolean mirror) {
                    mViewModel.setVideoLocalMirror(mirror);
                }
            });
            mAudioSettingView = new AudioSettingView(getContext(), new AudioSettingView.OnItemChangeListener() {
                @Override
                public void onAudioCaptureVolumeChange(int volume) {
                    mViewModel.setAudioCaptureVolume(volume);
                }

                @Override
                public void onAudioPlayVolumeChange(int volume) {
                    mViewModel.setAudioPlayVolume(volume);
                }

                @Override
                public void onAudioEvaluationEnableChange(boolean enable) {
                    mViewModel.enableAudioEvaluation(enable);
                }

                @Override
                public void onStartFileDumping(String path) {
                    mViewModel.startFileDumping(path);
                }

                @Override
                public void onStopFileDumping() {
                    mViewModel.stopFileDumping();
                }
            });
            mShareSettingView = new ShareSettingView(getContext());
            mFragmentList.add(mVideoSettingView);
            mFragmentList.add(mAudioSettingView);
            mFragmentList.add(mShareSettingView);
            mShareSettingView.setShareButtonClickListener(new ShareSettingView.OnShareButtonClickListener() {
                @Override
                public void onClick() {
                    if (RoomEngineManager.sharedInstance().getRoomStore().videoModel.isScreenSharing()) {
                        mViewModel.stopScreenShare();
                    } else {
                        mViewModel.startScreenShare();
                    }
                    dismiss();
                }
            });
            mShareSettingView.enableShareButton(mEnableShare);
        }
    }

    @Override
    public void onDetachedFromWindow() {
        mViewModel.destroy();
        super.onDetachedFromWindow();
    }

    public void enableShareButton(boolean enable) {
        mEnableShare = enable;
        if (mShareSettingView != null) {
            mShareSettingView.enableShareButton(enable);
        }
    }

    static class SettingViewPageAdapter extends PagerAdapter {
        private List<View> viewLists;

        public SettingViewPageAdapter(List<View> viewLists) {
            super();
            this.viewLists = viewLists;
        }

        @Override
        public int getCount() {
            return viewLists.size();
        }

        @Override
        public boolean isViewFromObject(View view, Object object) {
            return view == object;
        }

        @NonNull
        @Override
        public Object instantiateItem(ViewGroup container, int position) {
            container.addView(viewLists.get(position));
            return viewLists.get(position);
        }

        @Override
        public void destroyItem(ViewGroup container, int position, Object object) {
            container.removeView(viewLists.get(position));
        }
    }
}


