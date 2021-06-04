package com.tencent.qcloud.tim.uikit.modules.forward;

import android.content.Intent;
import android.os.Bundle;
import android.os.Environment;

import androidx.annotation.Nullable;

import com.tencent.qcloud.tim.uikit.R;
import com.tencent.qcloud.tim.uikit.base.BaseActvity;
import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.util.ArrayList;
import java.util.List;

public class ForwardSelectActivity extends BaseActvity {
    private static final String TAG = ForwardSelectActivity.class.getSimpleName();
    /*public static final String path= Environment.getExternalStorageDirectory().getAbsoluteFile()+"/"+"conversationInfo.dat";*/

    public static final String FORWARD_MODE = "forward_mode";//0,onebyone;  1,merge;
    public static final int FORWARD_MODE_ONE_BY_ONE = 0;
    public static final int FORWARD_MODE_MERGE = 1;
    private ForwardSelectFragment mForwardSelectFragment;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.forward_activity);

        init();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        TUIKitLog.i(TAG, "onNewIntent");
        super.onNewIntent(intent);;
    }

    @Override
    protected void onResume() {
        TUIKitLog.i(TAG, "onResume");
        super.onResume();
    }

    private void init() {
        mForwardSelectFragment = new ForwardSelectFragment();
        //mForwardSelectFragment.setArguments(bundle);
        getSupportFragmentManager().beginTransaction().replace(R.id.empty_view, mForwardSelectFragment).commitAllowingStateLoss();

        /*FragmentManager fragmentManager = getSupportFragmentManager();        // 开启一个事务
        FragmentTransaction fragmentTransaction = fragmentManager.beginTransaction();
        fragmentTransaction.replace(R.id.empty_view, mForwardSelectFragment);
        fragmentTransaction.addToBackStack(null);
        fragmentTransaction.commitAllowingStateLoss();*/
    }
}
