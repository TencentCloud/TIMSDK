package com.tencent.qcloud.tim.demo.profile;

import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;

import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.uikit.component.TitleBarLayout;

public class WebViewActivity extends Activity {

    private WebView mWebView;
    private TitleBarLayout mTitleBar;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.profile_about_activity);

        mTitleBar = findViewById(R.id.webview_title);
        mTitleBar.setTitle(getResources().getString(R.string.about_im), TitleBarLayout.POSITION.MIDDLE);
        mTitleBar.getRightIcon().setVisibility(View.GONE);
        mTitleBar.setOnLeftClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mWebView = (WebView) findViewById(R.id.wv_view);
        mWebView.getSettings().setJavaScriptEnabled(true);
        mWebView.loadUrl("https://cloud.tencent.com/product/im");
        mWebView.setWebViewClient(new MyWebViewClient());
    }


    class MyWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
            //表示在当前的WebView继续打开网页
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                view.loadUrl(request.getUrl().toString());
            } else {
                view.loadUrl(request.toString());
            }
            return true;
        }

        @Override
        public void onPageStarted(WebView view, String url, Bitmap favicon) {
            super.onPageStarted(view, url, favicon);
        }

        @Override
        public void onPageFinished(WebView view, String url) {
            super.onPageFinished(view, url);
        }
    }

}
