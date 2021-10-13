package com.tencent.qcloud.tim.demo.profile;

import android.os.Bundle;

import androidx.annotation.Nullable;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.tencent.imsdk.v2.V2TIMCallback;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.bean.UserInfo;
import com.tencent.qcloud.tim.demo.utils.TUIKitConstants;
import com.tencent.qcloud.tim.uikit.TUIKit;
import com.tencent.qcloud.tuicore.component.dialog.TUIKitDialog;
import com.tencent.qcloud.tuicore.component.fragments.BaseFragment;
import com.tencent.qcloud.tuicore.util.ToastUtil;


public class ProfileFragment extends BaseFragment {

    private View mBaseView;
    private ProfileLayout mProfileLayout;

    @Nullable
    @Override
    public View onCreateView(LayoutInflater inflater, @Nullable ViewGroup container, Bundle savedInstanceState) {

        mBaseView = inflater.inflate(R.layout.profile_fragment, container, false);
        initView();
        return mBaseView;
    }

    private void initView() {
        mProfileLayout = mBaseView.findViewById(R.id.profile_view);
        mBaseView.findViewById(R.id.logout_btn).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                new TUIKitDialog(getActivity())
                        .builder()
                        .setCancelable(true)
                        .setCancelOutside(true)
                        .setTitle(getString(R.string.logout_tip))
                        .setDialogWidth(0.75f)
                        .setPositiveButton(getString(R.string.sure), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                Thread logoutThread = new Thread(() -> TUIKit.logout(new V2TIMCallback() {
                                    @Override
                                    public void onSuccess() {

                                    }

                                    @Override
                                    public void onError(int code, String desc) {
                                        ToastUtil.toastLongMessage("logout fail: " + code + "=" + desc);
                                    }
                                }));
                                logoutThread.setName("Logout-Thread");
                                logoutThread.start();
                                UserInfo.getInstance().setToken("");
                                UserInfo.getInstance().setAutoLogin(false);
                                Bundle bundle = new Bundle();
                                bundle.putBoolean(TUIKitConstants.LOGOUT, true);
                                TUIKit.startActivity("LoginForDevActivity", bundle);
                                if (getActivity() != null) {
                                    getActivity().finish();
                                }
                            }

                        })
                        .setNegativeButton(getString(R.string.cancel), new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {

                            }
                        })
                        .show();
            }
        });

    }
}
