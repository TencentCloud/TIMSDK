package com.tencent.qcloud.tim.demo.profile;

import androidx.appcompat.app.AlertDialog;
import androidx.appcompat.app.AppCompatActivity;

import android.content.DialogInterface;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;

import com.tencent.imsdk.v2.V2TIMManager;
import com.tencent.qcloud.tim.demo.R;
import com.tencent.qcloud.tim.demo.utils.Constants;
import com.tencent.qcloud.tuicore.component.LineControllerView;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;

public class AboutIMActivity extends BaseLightActivity implements View.OnClickListener {
    private TitleBarLayout titleBarLayout;
    private LineControllerView sdkVersionLv;
    private LineControllerView privacyLv;
    private LineControllerView userAgreementLv;
    private LineControllerView statementLv;
    private LineControllerView aboutIMLv;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_about_im);
        titleBarLayout = findViewById(R.id.about_im_title_bar);
        sdkVersionLv = findViewById(R.id.about_sdk_version_lv);
        privacyLv = findViewById(R.id.about_im_privacy_lv);
        userAgreementLv = findViewById(R.id.about_user_agreement_lv);
        statementLv = findViewById(R.id.about_statement_lv);
        aboutIMLv = findViewById(R.id.about_im_lv);

        setupViews();
    }

    private void setupViews() {
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.setTitle(getResources().getString(R.string.about_im), ITitleBarLayout.Position.MIDDLE);
        titleBarLayout.setOnLeftClickListener(this);

        String sdkVersion = V2TIMManager.getInstance().getVersion();
        sdkVersionLv.setContent(sdkVersion);

        privacyLv.setOnClickListener(this);
        userAgreementLv.setOnClickListener(this);
        statementLv.setOnClickListener(this);
        aboutIMLv.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v == privacyLv) {
            String title = getResources().getString(R.string.im_privacy);
            startWebUrl(title, Constants.IM_PRIVACY_PROTECTION);
        } else if (v == userAgreementLv) {
            String title = getResources().getString(R.string.im_user_agreement);
            startWebUrl(title, Constants.IM_USER_AGREEMENT);
        } else if (v == statementLv) {
            AlertDialog.Builder builder = new AlertDialog.Builder(this)
                    .setTitle(this.getString(R.string.im_statement))
                    .setMessage(this.getString(R.string.im_statement_content))
                    .setPositiveButton(this.getString(R.string.sure), new DialogInterface.OnClickListener() {
                        @Override
                        public void onClick(DialogInterface dialog, int which) {
                            dialog.dismiss();
                        }
                    });

            AlertDialog mDialogStatement = builder.create();
            mDialogStatement.show();
        } else if (v == aboutIMLv) {
            String title = getResources().getString(R.string.about_im);
            startWebUrl(title, Constants.IM_ABOUT);
        } else if (v == titleBarLayout.getLeftGroup()) {
            finish();
        }
    }

    private void startWebUrl(String title, String url) {
        Intent intent = new Intent(this, WebViewActivity.class);
        intent.putExtra("title", title);
        intent.putExtra("url", url);
        startActivity(intent);
    }
}