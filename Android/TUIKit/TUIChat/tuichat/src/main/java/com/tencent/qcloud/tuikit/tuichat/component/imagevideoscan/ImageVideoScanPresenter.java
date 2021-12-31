package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import android.app.ProgressDialog;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.MediaScannerConnection;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.os.FileUtils;
import android.provider.MediaStore;
import android.text.TextUtils;
import android.util.Log;
import android.webkit.MimeTypeMap;

import androidx.recyclerview.widget.RecyclerView;

import com.tencent.imsdk.v2.V2TIMMessage;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.List;

public class ImageVideoScanPresenter {
    private static final String TAG = ImageVideoScanPresenter.class.getSimpleName();

    private RecyclerView mRecyclerView;
    private ImageVideoScanAdapter mAdapter;
    private ViewPagerLayoutManager mViewPagerLayoutManager;
    private ImageVideoScanProvider mImageVideoScanProvider;
    private String mChatID;
    private int mCurrentPosition = -1;
    private int mIndex = 0;
    private boolean mIsForwardMode = false;

    void ImageVideoScanPresenter () {

    }

    public void setAdapter(ImageVideoScanAdapter mAdapter) {
        this.mAdapter = mAdapter;
    }

    public void setRecyclerView(RecyclerView mRecyclerView) {
        this.mRecyclerView = mRecyclerView;
    }

    public void setViewPagerLayoutManager(ViewPagerLayoutManager viewPagerLayoutManager) {
        this.mViewPagerLayoutManager = viewPagerLayoutManager;
    }

    public void init(TUIMessageBean messageBean, List<TUIMessageBean> messageBeans, boolean isForwardMode) {
        mIsForwardMode = isForwardMode;
        if (isForwardMode) {
            mAdapter.setDataSource(messageBeans);
            mAdapter.notifyDataSetChanged();

            int postion = 0;
            for (int i = 0; i < messageBeans.size(); i++) {
                if (messageBeans.get(i).getId().equals(messageBean.getId())) {
                    postion = i;
                    break;
                }
            }
            mRecyclerView.scrollToPosition(postion);
            mCurrentPosition = postion;
        } else {
            List<TUIMessageBean> mDataSource = new ArrayList<>();
            mDataSource.add(messageBean);
            mAdapter.setDataSource(mDataSource);
            mAdapter.notifyDataSetChanged();

            mImageVideoScanProvider = new ImageVideoScanProvider();
            mChatID = messageBean.isGroup() ? messageBean.getV2TIMMessage().getGroupID() : messageBean.getV2TIMMessage().getUserID();
            mImageVideoScanProvider.initMessageList(mChatID, messageBean.isGroup(), messageBean, new IUIKitCallback<List<TUIMessageBean>>() {
                @Override
                public void onSuccess(List<TUIMessageBean> messageBeans) {
                    mAdapter.setDataSource(messageBeans);
                    mAdapter.notifyDataSetChanged();

                    int postion = 0;
                    for (int i = 0; i < messageBeans.size(); i++) {
                        if (messageBeans.get(i).getId().equals(messageBean.getId())) {
                            postion = i;
                            break;
                        }
                    }
                    mRecyclerView.scrollToPosition(postion);
                    mCurrentPosition = postion;
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "loadChatMessages initMessageList failed, code = " + errCode + ", desc = " + errMsg);
                }
            });
        }

        mViewPagerLayoutManager.setOnViewPagerListener(new OnViewPagerListener() {

            @Override
            public void onInitComplete() {
                Log.e(TAG,"onInitComplete");
            }

            @Override
            public void onPageRelease(boolean isNext, int position) {
                Log.e(TAG,"释放位置:"+position +" 下一页:"+isNext);
                int index = 0;
                if (isNext){
                    index = 0;
                }else {
                    index = 1;
                }
                mIndex = index;
                releaseUI();
            }

            @Override
            public void onPageSelected(int position,boolean isBottom, boolean isLeftScroll) {
                Log.e(TAG,"选中位置:"+position+"  是否是滑动到底部:"+isBottom + "是否左滑:"+isBottom);
                mCurrentPosition = position;
                if (mIsForwardMode) {
                    return;
                }
                if (isLeftScroll) {
                    if (position == 0) {
                        if (mAdapter.getOldLocateMessage() != null) {
                            Log.d(TAG, "mAdapter.getOldLocateMessage() seq:" + mAdapter.getOldLocateMessage().getV2TIMMessage().getSeq());
                        }
                        mImageVideoScanProvider.loadLocalMediaMessageForward(mChatID, messageBean.isGroup(), mAdapter.getOldLocateMessage(), new IUIKitCallback<List<TUIMessageBean>>() {
                            @Override
                            public void onSuccess(List<TUIMessageBean> messageBeans) {
                                if (messageBeans == null || messageBeans.isEmpty()) {
                                    return;
                                }
                                int newPositon = mAdapter.addDataToSource(messageBeans, TUIChatConstants.GET_MESSAGE_FORWARD, position);
                                mRecyclerView.scrollToPosition(newPositon);
                                mAdapter.notifyDataSetChanged();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                TUIChatLog.e(TAG, "onPageSelected loadLocalMediaMessageForward failed, code = " + errCode + ", desc = " + errMsg);
                            }
                        });
                    }
                } else {
                    if (position == mAdapter.getItemCount() -1) {
                        if (mAdapter.getNewLocateMessage() != null) {
                            Log.d(TAG, "mAdapter.getNewLocateMessage() seq:" + mAdapter.getNewLocateMessage().getV2TIMMessage().getSeq());
                        }
                        mImageVideoScanProvider.loadLocalMediaMessageBackward(mChatID, messageBean.isGroup(), mAdapter.getNewLocateMessage(), new IUIKitCallback<List<TUIMessageBean>>() {
                            @Override
                            public void onSuccess(List<TUIMessageBean> messageBeans) {
                                if (messageBeans == null || messageBeans.isEmpty()) {
                                    return;
                                }
                                int newPositon = mAdapter.addDataToSource(messageBeans, TUIChatConstants.GET_MESSAGE_BACKWARD, position);
                                mRecyclerView.scrollToPosition(newPositon);
                                mAdapter.notifyDataSetChanged();
                            }

                            @Override
                            public void onError(String module, int errCode, String errMsg) {
                                TUIChatLog.e(TAG, "onPageSelected loadLocalMediaMessageBackward failed, code = " + errCode + ", desc = " + errMsg);
                            }
                        });
                    }
                }
            }
        });
    }

    public void releaseUI() {
        if (mAdapter != null) {
            mAdapter.destroyView(mRecyclerView, mIndex);
        }
    }

    public void saveLocal(Context context) {
        TUIChatLog.d(TAG, "mCurrentPosition = " + mCurrentPosition);
        if (mAdapter != null && mCurrentPosition >= 0 && mCurrentPosition < mAdapter.getItemCount()) {
            TUIMessageBean messageBean = mAdapter.getDataSource().get(mCurrentPosition);
            if (messageBean.getMsgType() == V2TIMMessage.V2TIM_ELEM_TYPE_IMAGE) {
                ImageMessageBean imageMessageBean;
                if (messageBean instanceof ImageMessageBean) {
                    imageMessageBean = (ImageMessageBean) messageBean;
                } else {
                    TUIChatLog.e(TAG, "is not ImageMessageBean");
                    return;
                }
                final List<ImageMessageBean.ImageBean> imgs = imageMessageBean.getImageBeanList();
                String imagePath = imageMessageBean.getDataPath();
                TUIChatLog.d(TAG, "imagePath = " + imagePath);
                String originImagePath = TUIChatUtils.getOriginImagePath(imageMessageBean);
                TUIChatLog.d(TAG, "originImagePath = " + originImagePath);
                if (!TextUtils.isEmpty(originImagePath)) {
                    imagePath = originImagePath;
                }

                String finalImagePath = imagePath;
                ThreadHelper.INST.execute(new Runnable() {
                    @Override
                    public void run() {
                        Bitmap bitmap = BitmapFactory.decodeFile(finalImagePath);
                        FileUtil.saveImageToGallery(context, bitmap);
                        ToastUtil.toastShortMessage(context.getString(R.string.save_tips));

                        //FileUtil.saveFileToAlbum(context, imagePath);
                    }
                });
            } else if (messageBean.getMsgType() == V2TIMMessage.V2TIM_ELEM_TYPE_VIDEO) {
                VideoMessageBean videoMessageBean;
                if (messageBean instanceof VideoMessageBean) {
                    videoMessageBean = (VideoMessageBean) messageBean;
                } else {
                    TUIChatLog.e(TAG, "is not VideoMessageBean");
                    return;
                }

                String videoPath = FileUtil.rootPath + videoMessageBean.getVideoUUID();

                final ProgressDialog progressDialog = ProgressDialog.show(context, "", context.getString(R.string.saving_tips), false, true);;
                videoMessageBean.downloadVideo(videoPath, new VideoMessageBean.VideoDownloadCallback() {
                    @Override
                    public void onProgress(long currentSize, long totalSize) {
                        TUIChatLog.i("downloadVideo progress current:", currentSize + ", total:" + totalSize);
                    }

                    @Override
                    public void onError(int code, String desc) {
                        ToastUtil.toastLongMessage(TUIChatService.getAppContext().getString(R.string.download_file_error) + code + "=" + desc);
                        videoMessageBean.setStatus(TUIMessageBean.MSG_STATUS_DOWNLOADED);
                        progressDialog.cancel();
                    }

                    @Override
                    public void onSuccess() {
                        progressDialog.cancel();
                        //将该文件扫描到相册
                        MediaScannerConnection.scanFile(context, new String[] { videoPath }, null, null);
                        ToastUtil.toastShortMessage(context.getString(R.string.save_tips));
                    }
                });

                /*ThreadHelper.INST.execute(new Runnable() {
                    @Override
                    public void run() {
                        FileUtil.saveFileToAlbum(context, videoPath);
                        ToastUtil.toastShortMessage(context.getString(R.string.save_tips));
                    }
                });*/
            } else {
                TUIChatLog.d(TAG, "error message type");
            }
         }
    }
}
