package com.tencent.cloud.tuikit.roomkit;

import android.app.Activity;
import android.content.res.Configuration;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;

import androidx.activity.OnBackPressedCallback;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;

import com.tencent.cloud.tuikit.roomkit.model.ConferenceEventCenter;
import com.tencent.cloud.tuikit.roomkit.viewmodel.ConferenceMainViewModel;

public class ConferenceMainFragment extends Fragment {
    private static final String TAG = "ConferenceMainFm";

    private final ConferenceParams mConferenceParams = new ConferenceParams();

    private FragmentActivity        mActivity;
    private OnBackPressedCallback   mBackPressedCallback;
    private ConferenceMainViewModel mViewModel;

    public ConferenceMainFragment() {
        mViewModel = new ConferenceMainViewModel(this);
    }

    public void quickStartConference(String conferenceId) {
        Log.i(TAG, "quickStartConference conferenceId=" + conferenceId);
        mViewModel.quickStartConference(conferenceId, mConferenceParams);
    }

    public void joinConference(String conferenceId) {
        Log.i(TAG, "joinConference conferenceId=" + conferenceId);
        mViewModel.joinConference(conferenceId, mConferenceParams);
    }

    public ConferenceMainFragment setConferenceParams(ConferenceParams params) {
        if (params == null) {
            Log.e(TAG, "setConferenceParams params is null");
            return this;
        }
        Log.i(TAG, "setConferenceParams : " + params.toString());
        updateConferenceParams(params);
        return this;
    }

    public ConferenceMainFragment setConferenceObserver(ConferenceObserver observer) {
        Log.i(TAG, "setConferenceObserver : " + observer);
        mViewModel.cacheConferenceObserver(observer);
        return this;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        super.onCreateView(inflater, container, savedInstanceState);
        Log.d(TAG, "onCreateView : " + this);
        View view = inflater.inflate(R.layout.tuiroomkit_fragment_main_conference, container, false);

        Activity activity = getActivity();
        if (!(activity instanceof FragmentActivity)) {
            Log.e(TAG, "A FragmentActivity or its subclass should be used to add the ConferenceMainFragment");
            return view;
        }
        mActivity = (FragmentActivity) activity;
        cacheCurrentActivity();

        initStatusBar();
        interceptBackPressed();
        keepScreenOn(true);
        return view;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);
        mViewModel.init();
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        Log.d(TAG, "onDestroyView : " + this);
        release();
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        Window window = getActivity().getWindow();
        if (Configuration.ORIENTATION_PORTRAIT == newConfig.orientation) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN);
        }
    }

    public void onDismiss() {
        mActivity.finish();
        release();
    }

    private void keepScreenOn(boolean keep) {
        Window window = getActivity().getWindow();
        if (keep) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        }
    }

    private void initStatusBar() {
        Window window = getActivity().getWindow();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
            window.getDecorView()
                    .setSystemUiVisibility(View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN | View.SYSTEM_UI_FLAG_LAYOUT_STABLE);
            window.addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            window.setStatusBarColor(Color.TRANSPARENT);
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    private void cacheCurrentActivity() {
        Activity activity = getActivity();
        if (activity == null) {
            Log.e(TAG, "cacheCurrentActivity activity is null");
            return;
        }
        mViewModel.cacheCurrentActivity(activity);
    }

    private void interceptBackPressed() {
        mBackPressedCallback = new OnBackPressedCallback(true) {
            @Override
            public void handleOnBackPressed() {
                Log.e(TAG, "handleOnBackPressed");
                ConferenceEventCenter.getInstance().notifyUIEvent(ConferenceEventCenter.RoomKitUIEvent.SHOW_EXIT_ROOM_VIEW, null);
            }
        };
        requireActivity().getOnBackPressedDispatcher().addCallback(mBackPressedCallback);
    }


    private void release() {
        if (mBackPressedCallback == null) {
            return;
        }
        Log.d(TAG, "release");
        mViewModel.release();
        mBackPressedCallback.remove();
        mBackPressedCallback = null;
        mActivity = null;
        keepScreenOn(false);
    }

    private void updateConferenceParams(ConferenceParams params) {
        mConferenceParams.setMuteMicrophone(params.isMuteMicrophone());
        mConferenceParams.setOpenCamera(params.isOpenCamera());
        mConferenceParams.setSoundOnSpeaker(params.isSoundOnSpeaker());
        mConferenceParams.setName(params.getName());
        mConferenceParams.setEnableMicrophoneForAllUser(params.isEnableMicrophoneForAllUser());
        mConferenceParams.setEnableCameraForAllUser(params.isEnableCameraForAllUser());
        mConferenceParams.setEnableMessageForAllUser(params.isEnableMessageForAllUser());
        mConferenceParams.setEnableSeatControl(params.isEnableSeatControl());
    }
}
