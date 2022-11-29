package com.tencent.qcloud.tuikit.tuicommunity.ui.page;

import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;
import com.tencent.qcloud.tuicore.component.TitleBarLayout;
import com.tencent.qcloud.tuicore.component.activities.BaseLightActivity;
import com.tencent.qcloud.tuicore.component.activities.ImageSelectActivity;
import com.tencent.qcloud.tuicore.component.interfaces.ITitleBarLayout;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuicommunity.R;
import com.tencent.qcloud.tuikit.tuicommunity.component.SelectTextButton;
import com.tencent.qcloud.tuikit.tuicommunity.presenter.CommunityPresenter;
import com.tencent.qcloud.tuikit.tuicommunity.utils.CommunityConstants;

import java.util.ArrayList;

public class CreateCommunityActivity extends BaseLightActivity {

    private static final int COVER_REQUEST_CODE = 1;
    private static final int FACE_REQUEST_CODE = 2;

    private ImageView coverImage;
    private ImageView faceImage;
    private View faceSelectArea;
    private View selectFaceLayout;
    private TextView nameCount;
    private TextView introductionCount;
    private EditText nameEdit;
    private EditText introductionEdit;
    private SelectTextButton selectTextButton;
    private TitleBarLayout titleBarLayout;
    private CommunityPresenter communityPresenter;

    private String coverUrl = CommunityConstants.DEFAULT_COVER_URL;
    private String faceUrl = CommunityConstants.DEFAULT_GROUP_FACE_URL;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.community_create_community_activity_layout);
        coverImage = findViewById(R.id.cover_iv);
        titleBarLayout = findViewById(R.id.create_community_title);
        nameCount = findViewById(R.id.name_count);
        introductionCount = findViewById(R.id.introduction_count);
        nameEdit = findViewById(R.id.name_edit_text);
        introductionEdit = findViewById(R.id.introduction_edit_text);
        selectTextButton = findViewById(R.id.select_cover_button);
        faceSelectArea = findViewById(R.id.face_select_fl);
        selectFaceLayout = findViewById(R.id.select_face_ll);
        faceImage = findViewById(R.id.face_iv);
        init();
    }

    private void init() {
        communityPresenter = new CommunityPresenter();

        titleBarLayout.setTitle(getString(com.tencent.qcloud.tuicore.R.string.sure), ITitleBarLayout.Position.RIGHT);
        titleBarLayout.getRightIcon().setVisibility(View.GONE);
        titleBarLayout.setOnRightClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String name = nameEdit.getText().toString();
                String introduction = introductionEdit.getText().toString();
                if (!TextUtils.isEmpty(name)) {
                    communityPresenter.createCommunityGroup(name, introduction, coverUrl, faceUrl);
                    finish();
                }
            }
        });
        selectTextButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ArrayList<ImageSelectActivity.ImageBean> coverList = new ArrayList<>();
                for (int i = 0; i < CommunityConstants.COVER_COUNT; i++) {
                    ImageSelectActivity.ImageBean imageBean= new ImageSelectActivity.ImageBean();
                    imageBean.setThumbnailUri(String.format(CommunityConstants.COVER_URL, (i + 1) + ""));
                    imageBean.setImageUri(String.format(CommunityConstants.COVER_URL, (i + 1) + ""));
                    coverList.add(imageBean);
                }

                Intent intent = new Intent(CreateCommunityActivity.this, ImageSelectActivity.class);
                intent.putExtra(ImageSelectActivity.TITLE, getString(R.string.community_select_cover));
                intent.putExtra(ImageSelectActivity.SPAN_COUNT, 2);
                intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(165));
                intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(79));
                intent.putExtra(ImageSelectActivity.DATA, coverList);
                startActivityForResult(intent, COVER_REQUEST_CODE);
            }
        });
        faceSelectArea.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                ArrayList<ImageSelectActivity.ImageBean> faceList = new ArrayList<>();
                for (int i = 0; i < CommunityConstants.GROUP_FACE_COUNT; i++) {
                    ImageSelectActivity.ImageBean imageBean= new ImageSelectActivity.ImageBean();
                    imageBean.setThumbnailUri(String.format(CommunityConstants.GROUP_FACE_URL, (i + 1) + ""));
                    imageBean.setImageUri(String.format(CommunityConstants.GROUP_FACE_URL, (i + 1) + ""));
                    faceList.add(imageBean);
                }

                Intent intent = new Intent(CreateCommunityActivity.this, ImageSelectActivity.class);
                intent.putExtra(ImageSelectActivity.TITLE, getString(R.string.community_select_face));
                intent.putExtra(ImageSelectActivity.SPAN_COUNT, 4);
                intent.putExtra(ImageSelectActivity.ITEM_WIDTH, ScreenUtil.dip2px(77));
                intent.putExtra(ImageSelectActivity.ITEM_HEIGHT, ScreenUtil.dip2px(77));
                intent.putExtra(ImageSelectActivity.DATA, faceList);
                startActivityForResult(intent, FACE_REQUEST_CODE);
            }
        });
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (data != null) {
            if (resultCode == ImageSelectActivity.RESULT_CODE_SUCCESS) {
                if (requestCode == COVER_REQUEST_CODE) {
                    ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) data.getSerializableExtra(ImageSelectActivity.DATA);
                    if (imageBean == null) {
                        return;
                    }

                    coverUrl = imageBean.getImageUri();
                    coverImage.setBackground(null);
                    Glide.with(this).load(coverUrl).into(coverImage);
                } else if (requestCode == FACE_REQUEST_CODE) {
                    ImageSelectActivity.ImageBean imageBean = (ImageSelectActivity.ImageBean) data.getSerializableExtra(ImageSelectActivity.DATA);
                    if (imageBean == null) {
                        return;
                    }

                    faceUrl = imageBean.getImageUri();
                    selectFaceLayout.setVisibility(View.GONE);
                    Glide.with(this).load(faceUrl).into(faceImage);
                }
            }
        }
    }
}
