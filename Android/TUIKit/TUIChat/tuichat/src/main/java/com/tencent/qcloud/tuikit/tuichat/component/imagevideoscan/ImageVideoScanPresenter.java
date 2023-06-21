package com.tencent.qcloud.tuikit.tuichat.component.imagevideoscan;

import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import java.io.File;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class ImageVideoScanPresenter {
    private static final String TAG = ImageVideoScanPresenter.class.getSimpleName();

    private static class MessageChangedListener implements ITUINotification {
        private WeakReference<ImageVideoScanPresenter> presenterWeakReference;

        @Override
        public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
            if (presenterWeakReference != null && presenterWeakReference.get() != null) {
                ImageVideoScanPresenter presenter = presenterWeakReference.get();
                TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIChatConstants.MESSAGE_BEAN);
                presenter.onMessageStatusChanged(messageBean);
            }
        }
    }

    private static MessageChangedListener messageChangedListener = new MessageChangedListener();

    private RecyclerView mRecyclerView;
    private ImageVideoScanAdapter mAdapter;
    private ImageVideoScanActivity activity;
    private ViewPagerLayoutManager mViewPagerLayoutManager;
    private ImageVideoScanProvider mImageVideoScanProvider;
    private String mChatID;
    private int mCurrentPosition = -1;
    private int mIndex = 0;
    private boolean mIsForwardMode = false;

    public ImageVideoScanPresenter() {
        messageChangedListener.presenterWeakReference = new WeakReference<>(this);
        TUICore.registerEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, messageChangedListener);
    }

    public void setActivity(ImageVideoScanActivity activity) {
        this.activity = activity;
    }

    public void onMessageStatusChanged(TUIMessageBean messageBean) {
        if (mAdapter != null) {
            mAdapter.onDataChanged(messageBean);
        }
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
                Log.i(TAG, "onInitComplete");
            }

            @Override
            public void onPageRelease(boolean isNext, int position) {
                Log.i(TAG, "release position :" + position + " next page:" + isNext);
                int index = 0;
                if (isNext) {
                    index = 0;
                } else {
                    index = 1;
                }
                mIndex = index;
                releaseUI();
            }

            @Override
            public void onPageSelected(int position, boolean isBottom, boolean isLeftScroll) {
                Log.i(TAG, "select:" + position + " isBottom:" + isBottom + "isLeftScroll:" + isBottom);
                mCurrentPosition = position;
                if (mIsForwardMode) {
                    return;
                }
                if (isLeftScroll) {
                    if (position == 0) {
                        if (mAdapter.getOldLocateMessage() != null) {
                            onItemSelected(mAdapter.getOldLocateMessage());
                            Log.d(TAG, "mAdapter.getOldLocateMessage() seq:" + mAdapter.getOldLocateMessage().getV2TIMMessage().getSeq());
                        }
                        mImageVideoScanProvider.loadLocalMediaMessageForward(
                            mChatID, messageBean.isGroup(), mAdapter.getOldLocateMessage(), new IUIKitCallback<List<TUIMessageBean>>() {
                                @Override
                                public void onSuccess(List<TUIMessageBean> messageBeans) {
                                    if (messageBeans == null || messageBeans.isEmpty()) {
                                        return;
                                    }
                                    int newPositon = mAdapter.addDataToSource(messageBeans, TUIChatConstants.GET_MESSAGE_FORWARD, position);
                                    mRecyclerView.scrollToPosition(newPositon);
                                    onItemSelected(mAdapter.getItem(newPositon));
                                    mAdapter.notifyDataSetChanged();
                                }

                                @Override
                                public void onError(String module, int errCode, String errMsg) {
                                    TUIChatLog.e(TAG, "onPageSelected loadLocalMediaMessageForward failed, code = " + errCode + ", desc = " + errMsg);
                                }
                            });
                    } else {
                        onItemSelected(mAdapter.getItem(position));
                    }
                } else {
                    if (position == mAdapter.getItemCount() - 1) {
                        if (mAdapter.getNewLocateMessage() != null) {
                            onItemSelected(mAdapter.getNewLocateMessage());
                            Log.d(TAG, "mAdapter.getNewLocateMessage() seq:" + mAdapter.getNewLocateMessage().getV2TIMMessage().getSeq());
                        }
                        mImageVideoScanProvider.loadLocalMediaMessageBackward(
                            mChatID, messageBean.isGroup(), mAdapter.getNewLocateMessage(), new IUIKitCallback<List<TUIMessageBean>>() {
                                @Override
                                public void onSuccess(List<TUIMessageBean> messageBeans) {
                                    if (messageBeans == null || messageBeans.isEmpty()) {
                                        return;
                                    }
                                    int newPositon = mAdapter.addDataToSource(messageBeans, TUIChatConstants.GET_MESSAGE_BACKWARD, position);
                                    mRecyclerView.scrollToPosition(newPositon);
                                    onItemSelected(mAdapter.getItem(newPositon));
                                    mAdapter.notifyDataSetChanged();
                                }

                                @Override
                                public void onError(String module, int errCode, String errMsg) {
                                    TUIChatLog.e(TAG, "onPageSelected loadLocalMediaMessageBackward failed, code = " + errCode + ", desc = " + errMsg);
                                }
                            });
                    } else {
                        onItemSelected(mAdapter.getItem(position));
                    }
                }
            }
        });
    }

    private void onItemSelected(TUIMessageBean messageBean) {
        if (activity != null) {
            activity.onItemSelected(messageBean);
        }
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
            if (messageBean instanceof ImageMessageBean) {
                ImageMessageBean imageMessageBean = (ImageMessageBean) messageBean;
                String imagePath = imageMessageBean.getDataPath();
                TUIChatLog.d(TAG, "imagePath = " + imagePath);
                String originImagePath = TUIChatUtils.getOriginImagePath(imageMessageBean);
                TUIChatLog.d(TAG, "originImagePath = " + originImagePath);
                if (!TextUtils.isEmpty(originImagePath)) {
                    imagePath = originImagePath;
                }
                saveImage(context, imagePath);
            } else if (messageBean instanceof VideoMessageBean) {
                VideoMessageBean videoMessageBean = (VideoMessageBean) messageBean;
                final String videoPath = TUIConfig.getVideoDownloadDir() + videoMessageBean.getVideoUUID();
                File file = new File(videoPath);
                if (file.exists() && file.length() == videoMessageBean.getVideoSize()) {
                    saveVideo(context, videoPath);
                } else {
                    ToastUtil.toastShortMessage(context.getString(R.string.downloading));
                }
            } else {
                TUIChatLog.d(TAG, "error message type");
            }
        }
    }

    private void saveImage(Context context, String imagePath) {
        ThreadUtils.execute(new Runnable() {
            @Override
            public void run() {
                boolean success = FileUtil.saveImageToGallery(context, imagePath);
                if (success) {
                    ToastUtil.toastShortMessage(context.getString(R.string.save_success));
                } else {
                    ToastUtil.toastShortMessage(context.getString(R.string.save_failed));
                }
            }
        });
    }

    private void saveVideo(Context context, String videoPath) {
        ThreadUtils.execute(new Runnable() {
            @Override
            public void run() {
                boolean success = FileUtil.saveVideoToGallery(context, videoPath);
                if (success) {
                    ToastUtil.toastShortMessage(context.getString(R.string.save_success));
                } else {
                    ToastUtil.toastShortMessage(context.getString(R.string.save_failed));
                }
            }
        });
    }
}
