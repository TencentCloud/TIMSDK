/*
 Copyright 2011, 2012 Chris Banes.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */
package com.tencent.qcloud.uikit.common.widget.photoview;

import android.app.Activity;
import android.graphics.Matrix;
import android.graphics.RectF;
import android.net.Uri;
import android.os.Bundle;
import android.view.MotionEvent;
import android.view.View;
import android.view.Window;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.tencent.imsdk.TIMCallBack;
import com.tencent.imsdk.TIMImage;
import com.tencent.qcloud.uikit.R;
import com.tencent.qcloud.uikit.common.UIKitConstants;
import com.tencent.qcloud.uikit.common.utils.FileUtil;

import java.io.File;


public class PhotoViewActivity extends Activity {


    private PhotoView mPhotoView;


    private Matrix mCurrentDisplayMatrix = null;
    public static TIMImage mCurrentOriginalImage;
    private TextView mViewOriginalBtn;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        //去除标题栏
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        //去除状态栏
        getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
                WindowManager.LayoutParams.FLAG_FULLSCREEN);
        setContentView(R.layout.activity_photo_view);
        Uri uri = FileUtil.getUriFromPath(getIntent().getStringExtra(UIKitConstants.IMAGE_DATA));
        boolean isSelf = getIntent().getBooleanExtra(UIKitConstants.SELF_MESSAGE, false);
        mCurrentDisplayMatrix = new Matrix();
        mPhotoView = findViewById(R.id.photo_view);
        mPhotoView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        mPhotoView.setDisplayMatrix(mCurrentDisplayMatrix);
        mPhotoView.setOnMatrixChangeListener(new MatrixChangeListener());
        mPhotoView.setOnPhotoTapListener(new PhotoTapListener());
        mPhotoView.setOnSingleFlingListener(new SingleFlingListener());
        mViewOriginalBtn = findViewById(R.id.view_original_btn);
        if (isSelf || mCurrentOriginalImage == null) {
            mPhotoView.setImageURI(uri);
        } else {
            if (mCurrentOriginalImage != null) {
                String path = UIKitConstants.IMAGE_DOWNLOAD_DIR + mCurrentOriginalImage.getUuid();
                File file = new File(path);
                if (file.exists())
                    mPhotoView.setImageURI(FileUtil.getUriFromPath(file.getPath()));
                else {
                    mPhotoView.setImageURI(uri);
                    mViewOriginalBtn.setVisibility(View.VISIBLE);
                    mViewOriginalBtn.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            if (mCurrentOriginalImage != null) {

                                final String path = UIKitConstants.IMAGE_DOWNLOAD_DIR + mCurrentOriginalImage.getUuid();
                                final File file = new File(path);
                                if (!file.exists()) {
                                    mCurrentOriginalImage.getImage(path, new TIMCallBack() {
                                        @Override
                                        public void onError(int code, String desc) {

                                        }

                                        @Override
                                        public void onSuccess() {
                                            mPhotoView.setImageURI(FileUtil.getUriFromPath(file.getPath()));
                                            mViewOriginalBtn.setText("已完成");
                                            mViewOriginalBtn.setOnClickListener(null);
                                        }
                                    });
                                } else {

                                    mPhotoView.setImageURI(FileUtil.getUriFromPath(file.getPath()));
                                }
                            }
                        }
                    });
                }

            }
        }


        findViewById(R.id.photo_view_back).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
    }

    private class PhotoTapListener implements OnPhotoTapListener {

        @Override
        public void onPhotoTap(ImageView view, float x, float y) {
            float xPercentage = x * 100f;
            float yPercentage = y * 100f;
        }
    }


    private class MatrixChangeListener implements OnMatrixChangedListener {

        @Override
        public void onMatrixChanged(RectF rect) {

        }
    }

    private class SingleFlingListener implements OnSingleFlingListener {

        @Override
        public boolean onFling(MotionEvent e1, MotionEvent e2, float velocityX, float velocityY) {
            return true;
        }
    }
}
