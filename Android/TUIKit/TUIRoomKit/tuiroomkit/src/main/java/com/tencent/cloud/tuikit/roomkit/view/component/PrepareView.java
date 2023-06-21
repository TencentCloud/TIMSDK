package com.tencent.cloud.tuikit.roomkit.view.component;

import android.content.Context;
import android.graphics.LinearGradient;
import android.graphics.Shader;
import android.view.View;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.constraintlayout.widget.ConstraintLayout;
import androidx.constraintlayout.widget.ConstraintSet;

import com.tencent.cloud.tuikit.engine.common.TUIVideoView;
import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.utils.ImageLoader;
import com.tencent.cloud.tuikit.roomkit.viewmodel.PrepareViewModel;

import de.hdodenhof.circleimageview.CircleImageView;

public class PrepareView extends RelativeLayout implements View.OnClickListener {

    private Context          mContext;
    private TextView         mTextUserName;
    private TextView         mTextProductName;
    private TextView         mTextUserNameCloseVideo;
    private ImageView        mImageBack;
    private ImageView        mImageMirror;
    private ImageView        mImageCamera;
    private ImageView        mImageLanguage;
    private ImageView        mImageCloudIcon;
    private ImageView        mImageMicroPhone;
    private ImageView        mImageSwitchCamera;
    private CircleImageView  mImageHead;
    private CircleImageView  mImageHeadCloseVideo;
    private TUIVideoView     mVideoView;
    private LinearLayout     mLayoutCamera;
    private LinearLayout     mLayoutEnterRoom;
    private LinearLayout     mLayoutCreateRoom;
    private LinearLayout     mLayoutMicrophone;
    private LinearLayout     mLayoutUserInfo;
    private RelativeLayout   mLayoutVideoPreview;
    private RelativeLayout   mLayoutProductLogo;
    private ConstraintLayout mLayoutRoot;
    private ConstraintSet    mPreSet;
    private PrepareViewModel mViewModel;

    public PrepareView(Context context, boolean enablePreview) {
        super(context);
        mContext = context;
        initView();
        updatePreviewLayout(enablePreview);
    }

    private void initView() {
        View.inflate(mContext, R.layout.tuiroomkit_view_prepare, this);
        mViewModel = new PrepareViewModel(mContext, this);

        mLayoutRoot = findViewById(R.id.cl_root_prepare);
        mImageHead = findViewById(R.id.img_head_prepare);
        mTextProductName = findViewById(R.id.tv_product_name);
        mImageHeadCloseVideo = findViewById(R.id.image_head_close_video);
        mTextUserName = findViewById(R.id.tv_name_prepare);
        mTextUserNameCloseVideo = findViewById(R.id.tv_user_name_close_video);
        mImageLanguage = findViewById(R.id.img_language_change);
        mImageBack = findViewById(R.id.img_back);
        mImageMirror = findViewById(R.id.image_mirror_preview);
        mImageCamera = findViewById(R.id.image_camera_prepare);
        mImageCloudIcon = findViewById(R.id.img_cloud_icon_bottom);
        mImageMicroPhone = findViewById(R.id.image_microphone_prepare);
        mImageSwitchCamera = findViewById(R.id.image_switch_camera_preview);
        mLayoutEnterRoom = findViewById(R.id.ll_enter_room);
        mLayoutCreateRoom = findViewById(R.id.ll_create_room);
        mLayoutUserInfo = findViewById(R.id.ll_user_info_close_video);
        mLayoutCamera = findViewById(R.id.ll_camera_prepare);
        mLayoutMicrophone = findViewById(R.id.ll_mic_prepare);
        mLayoutVideoPreview = findViewById(R.id.rl_video_preview);
        mLayoutProductLogo = findViewById(R.id.rl_product_logo);

        mImageBack.setOnClickListener(this);
        mImageHead.setOnClickListener(this);
        mImageLanguage.setOnClickListener(this);
        mImageMirror.setOnClickListener(this);
        mImageSwitchCamera.setOnClickListener(this);
        mLayoutEnterRoom.setOnClickListener(this);
        mLayoutCreateRoom.setOnClickListener(this);
        mLayoutCamera.setOnClickListener(this);
        mLayoutMicrophone.setOnClickListener(this);

        ImageLoader.loadImage(mContext, mImageHead, mViewModel.getUserModel().userAvatar,
                R.drawable.tuiroomkit_head);
        ImageLoader.loadImage(mContext, mImageHeadCloseVideo, mViewModel.getUserModel().userAvatar,
                R.drawable.tuiroomkit_head);
        mTextUserName.setText(mViewModel.getUserModel().userName);
        mTextUserNameCloseVideo.setText(mViewModel.getUserModel().userName);
        mViewModel.setVideoView(mVideoView);

        mPreSet = new ConstraintSet();
        mPreSet.clone(mLayoutRoot);
    }

    private void updatePreviewLayout(boolean enableVideoPreview) {
        if (enableVideoPreview) {
            mPreSet.applyTo(mLayoutRoot);
        } else {
            mLayoutProductLogo.setVisibility(VISIBLE);
            mImageCloudIcon.setVisibility(GONE);
            mLayoutCamera.setVisibility(GONE);
            mLayoutMicrophone.setVisibility(GONE);
            mLayoutVideoPreview.setVisibility(GONE);
            ConstraintSet set = new ConstraintSet();
            set.clone(mLayoutRoot);
            set.clear(mLayoutCreateRoom.getId());
            set.clear(mLayoutEnterRoom.getId());

            set.centerHorizontally(mLayoutCreateRoom.getId(), ConstraintSet.PARENT_ID);
            set.constrainHeight(mLayoutCreateRoom.getId(), ConstraintSet.WRAP_CONTENT);
            set.constrainPercentWidth(mLayoutCreateRoom.getId(), 0.5f);
            set.connect(mLayoutCreateRoom.getId(), ConstraintSet.BOTTOM, mLayoutRoot.getId(),
                    ConstraintSet.BOTTOM,
                    getResources().getDimensionPixelSize(R.dimen.tuiroomkit_create_room_margin_bottom));
            set.connect(mLayoutCreateRoom.getId(), ConstraintSet.START, ConstraintSet.PARENT_ID, ConstraintSet.START);
            set.connect(mLayoutCreateRoom.getId(), ConstraintSet.END, ConstraintSet.PARENT_ID, ConstraintSet.END);

            set.connect(mLayoutEnterRoom.getId(), ConstraintSet.BOTTOM, mLayoutCreateRoom.getId(), ConstraintSet.TOP,
                    getResources().getDimensionPixelSize(R.dimen.tuiroomkit_enter_room_margin_bottom));
            set.connect(mLayoutEnterRoom.getId(), ConstraintSet.LEFT, mLayoutCreateRoom.getId(), ConstraintSet.LEFT);
            set.connect(mLayoutEnterRoom.getId(), ConstraintSet.RIGHT, mLayoutCreateRoom.getId(), ConstraintSet.RIGHT);
            set.constrainWidth(mLayoutEnterRoom.getId(), ConstraintSet.MATCH_CONSTRAINT);
            set.constrainHeight(mLayoutEnterRoom.getId(), ConstraintSet.WRAP_CONTENT);
            set.setVerticalBias(mLayoutEnterRoom.getId(), 100f);

            set.applyTo(mLayoutRoot);
            setTextGradient(mTextProductName);
        }
    }

    private void setTextGradient(TextView view) {
        LinearGradient gradient = new LinearGradient(0, 0,
                view.getPaint().getTextSize() * view.getText().length(),
                0, getResources().getColor(R.color.tuiroomkit_color_gradient_start),
                getResources().getColor(R.color.tuiroomkit_color_gradient_end),
                Shader.TileMode.CLAMP);
        view.getPaint().setShader(gradient);
        view.invalidate();
    }

    public void updateVideoView(boolean enableCamera) {
        if (enableCamera) {
            mImageMirror.setVisibility(VISIBLE);
            mImageSwitchCamera.setVisibility(VISIBLE);
            mImageHeadCloseVideo.setVisibility(GONE);
            mLayoutUserInfo.setVisibility(GONE);
            mImageCamera.setImageResource(R.drawable.tuiroomkit_ic_camera_on);
        } else {
            mImageMirror.setVisibility(GONE);
            mImageSwitchCamera.setVisibility(GONE);
            mImageHeadCloseVideo.setVisibility(VISIBLE);
            mLayoutUserInfo.setVisibility(VISIBLE);
            mImageCamera.setImageResource(R.drawable.tuiroomkit_ic_camera_off);
        }
    }

    public void updateMicPhoneButton(boolean enableMicrophone) {
        if (enableMicrophone) {
            mImageMicroPhone.setImageResource(R.drawable.tuiroomkit_ic_mic_on);
        } else {
            mImageMicroPhone.setImageResource(R.drawable.tuiroomkit_ic_mic_off);
        }
    }

    @Override
    protected void onVisibilityChanged(@NonNull View changedView, int visibility) {
        if (visibility == VISIBLE) {
            mViewModel.setVideoView(mVideoView);
            mViewModel.initRoomStore();
            mViewModel.initMicAndCamera();
        } else {
            mViewModel.closeLocalCamera();
            mViewModel.closeLocalMicrophone();
        }
        super.onVisibilityChanged(changedView, visibility);
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.img_back) {
            mViewModel.finishActivity();
        } else if (v.getId() == R.id.img_language_change) {
            mViewModel.changeLanguage();
        } else if (v.getId() == R.id.image_switch_camera_preview) {
            mViewModel.switchCamera();
        } else if (v.getId() == R.id.image_mirror_preview) {
            mViewModel.switchMirrorType();
        } else if (v.getId() == R.id.ll_mic_prepare) {
            mViewModel.changeMicrophoneState();
        } else if (v.getId() == R.id.ll_camera_prepare) {
            mViewModel.changeCameraState();
        } else if (v.getId() == R.id.ll_enter_room) {
            mViewModel.enterRoom(mContext);
        } else if (v.getId() == R.id.ll_create_room) {
            mViewModel.closeLocalCamera();
            mViewModel.createRoom(mContext);
        }
    }

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        if (mLayoutVideoPreview != null) {
            mVideoView = new TUIVideoView(mContext.getApplicationContext());
            mLayoutVideoPreview.addView(mVideoView, 0);
        }
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        if (mLayoutVideoPreview != null) {
            mLayoutVideoPreview.removeAllViews();
        }
    }
}
