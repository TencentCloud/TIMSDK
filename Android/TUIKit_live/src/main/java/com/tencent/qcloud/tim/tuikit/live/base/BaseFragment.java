package com.tencent.qcloud.tim.tuikit.live.base;

import android.content.pm.PackageManager;
import android.os.Build;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;

import com.tencent.qcloud.tim.tuikit.live.R;

import java.util.ArrayList;
import java.util.List;

public class BaseFragment extends Fragment {
    private static final int PERMISSION_REQUEST_CODE = 100;

    private OnPermissionGrandCallback mOnPermissionCallback;

    public void onBackPressed() {
    }

    protected void requestPermissions(String[] permissions, OnPermissionGrandCallback callback) {
        mOnPermissionCallback = callback;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            requestPermissions(permissions, PERMISSION_REQUEST_CODE);
        } else {
            if (mOnPermissionCallback != null) {
                mOnPermissionCallback.onAllPermissionsGrand();
            }
        }
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == PERMISSION_REQUEST_CODE) {
            List<String> deniedPermissionList = new ArrayList<>();
            for (int i = 0; i < grantResults.length; i++) {
                if (grantResults[i] != PackageManager.PERMISSION_GRANTED) {
                    deniedPermissionList.add(permissions[i]);
                }
            }
            if (deniedPermissionList.isEmpty()) {
                if (mOnPermissionCallback != null) {
                    mOnPermissionCallback.onAllPermissionsGrand();
                }
            } else {
                Toast.makeText(getContext(), R.string.live_permission_denied, Toast.LENGTH_SHORT).show();
            }
        }
    }

    public interface OnPermissionGrandCallback {
        void onAllPermissionsGrand();
    }
}
