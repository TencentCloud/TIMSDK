package com.tencent.qcloud.tuikit.timcommon.component.activities;

import android.content.Context;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowCompat;
import androidx.core.view.WindowInsetsCompat;
import androidx.core.view.WindowInsetsControllerCompat;


public class BaseMinimalistLightActivity extends AppCompatActivity {
    private static final String TAG = "BaseMinimalistLightActivity";
    
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setupEdgeToEdge();
    }

    @Override
    public void setContentView(int layoutResID) {
        super.setContentView(layoutResID);
        applyWindowInsetsToRootView();
    }

    @Override
    public void setContentView(View view) {
        super.setContentView(view);
        applyWindowInsetsToRootView();
    }

    @Override
    public void setContentView(View view, ViewGroup.LayoutParams params) {
        super.setContentView(view, params);
        applyWindowInsetsToRootView();
    }

    private void setupEdgeToEdge() {
        WindowCompat.setDecorFitsSystemWindows(getWindow(), false);
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            getWindow().clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_NAVIGATION);
            getWindow().addFlags(WindowManager.LayoutParams.FLAG_DRAWS_SYSTEM_BAR_BACKGROUNDS);
            getWindow().setStatusBarColor(0xFFFFFFFF);
            getWindow().setNavigationBarColor(0xFFFFFFFF);
        }
        
        updateStatusBarAppearance();
    }
    
    private void updateStatusBarAppearance() {
        int statusBarColor = Color.WHITE;
        int navigationBarColor = Color.WHITE;
        
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            statusBarColor = getWindow().getStatusBarColor();
            navigationBarColor = getWindow().getNavigationBarColor();
        }
        
        WindowInsetsControllerCompat controller = WindowCompat.getInsetsController(getWindow(), getWindow().getDecorView());
        if (controller != null) {
            controller.setAppearanceLightStatusBars(isColorLight(statusBarColor));
            controller.setAppearanceLightNavigationBars(isColorLight(navigationBarColor));
        }
    }
    
    private boolean isColorLight(int color) {
        double darkness = 1 - (0.299 * Color.red(color) + 0.587 * Color.green(color) + 0.114 * Color.blue(color)) / 255;
        return darkness < 0.5;
    }

    private void applyWindowInsetsToRootView() {
        View rootView = findViewById(android.R.id.content);
        if (rootView instanceof ViewGroup) {
            ViewGroup contentView = (ViewGroup) rootView;
            if (contentView.getChildCount() > 0) {
                View actualRootView = contentView.getChildAt(0);
                applyWindowInsets(actualRootView);
            }
        }
    }

    private void applyWindowInsets(View view) {
        final int[] initialPadding = new int[]{
            view.getPaddingLeft(),
            view.getPaddingTop(),
            view.getPaddingRight(),
            view.getPaddingBottom()
        };

        ViewCompat.setOnApplyWindowInsetsListener(view, (v, windowInsets) -> {
            Insets systemBars = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars());
            Insets ime = windowInsets.getInsets(WindowInsetsCompat.Type.ime());
            
            int bottomInset = Math.max(systemBars.bottom, ime.bottom);
            
            v.setPadding(
                initialPadding[0] + systemBars.left,
                initialPadding[1] + systemBars.top,
                initialPadding[2] + systemBars.right,
                initialPadding[3] + bottomInset
            );
            ViewCompat.setOnApplyWindowInsetsListener(v, null);
            return WindowInsetsCompat.CONSUMED;
        });
        
        ViewCompat.requestApplyInsets(view);
    }

    @Override
    public void finish() {
        hideSoftInput();
        super.finish();
    }

    public void hideSoftInput() {
        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
        Window window = getWindow();
        if (window != null) {
            imm.hideSoftInputFromWindow(window.getDecorView().getWindowToken(), 0);
        }
    }
}
