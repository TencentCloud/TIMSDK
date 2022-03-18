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
    private LineControllerView cancelAccountLv;
    private LineControllerView selfInfomationCollectionLv;
    private LineControllerView thirdPartSharedLv;

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
        cancelAccountLv = findViewById(R.id.cancel_account_lv);
        selfInfomationCollectionLv = findViewById(R.id.self_infomation_collection_lv);
        thirdPartSharedLv = findViewById(R.id.third_part_shared_lv);
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
        cancelAccountLv.setOnClickListener(this);
        selfInfomationCollectionLv.setOnClickListener(this);
        thirdPartSharedLv.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        if (v == privacyLv) {
            String title = getResources().getString(R.string.im_privacy);
            startWebUrl(Constants.IM_PRIVACY_PROTECTION);
        } else if (v == userAgreementLv) {
            String title = getResources().getString(R.string.im_user_agreement);
            startWebUrl(Constants.IM_USER_AGREEMENT);
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
            startWebUrl(Constants.IM_ABOUT);
        } else if (v == titleBarLayout.getLeftGroup()) {
            finish();
        } else if (v == cancelAccountLv) {
        } else if (v == selfInfomationCollectionLv) {
            String title = getResources().getString(R.string.self_infomation_collection_list);
            startWebUrl(Constants.IM_SELF_INFORMATION_COLLECTION);
        } else if (v == thirdPartSharedLv) {
            String title = getResources().getString(R.string.third_part_shared_list);
            startWebUrl(Constants.IM_THIRD_SHARED);
        }
    }

    private void startWebUrl(String url) {
        Intent intent = new Intent();
        intent.setAction(Intent.ACTION_VIEW);
        Uri contentUrl = Uri.parse(url);
        intent.setData(contentUrl);
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        startActivity(intent);
    }
}