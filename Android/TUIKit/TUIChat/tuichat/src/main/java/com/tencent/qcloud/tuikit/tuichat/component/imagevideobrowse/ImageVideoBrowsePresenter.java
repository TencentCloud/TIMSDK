package com.tencent.qcloud.tuikit.tuichat.component.imagevideobrowse;

import android.content.Context;
import android.text.TextUtils;

import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuicore.interfaces.ITUINotification;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.interfaces.IUIKitCallback;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.bean.message.ImageMessageBean;
import com.tencent.qcloud.tuikit.tuichat.bean.message.VideoMessageBean;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.presenter.ChatFileDownloadPresenter;
import com.tencent.qcloud.tuikit.tuichat.util.FileUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public class ImageVideoBrowsePresenter {
    private static final String TAG = ImageVideoBrowsePresenter.class.getSimpleName();

    private static class MessageChangedListener implements ITUINotification {
        private WeakReference<ImageVideoBrowsePresenter> presenterWeakReference;

        @Override
        public void onNotifyEvent(String key, String subKey, Map<String, Object> param) {
            if (presenterWeakReference != null && presenterWeakReference.get() != null) {
                ImageVideoBrowsePresenter presenter = presenterWeakReference.get();
                TUIMessageBean messageBean = (TUIMessageBean) param.get(TUIChatConstants.MESSAGE_BEAN);
                presenter.onMessageStatusChanged(messageBean);
            }
        }
    }

    private static final MessageChangedListener messageChangedListener = new MessageChangedListener();

    private ImageVideoBrowseListener browseListener;
    private ImageVideoBrowseProvider provider;
    private String chatID;
    private boolean isGroup = false;
    private boolean isForwardMode = false;
    private TUIMessageBean currentMessageBean;
    private List<TUIMessageBean> loadedMessages = new ArrayList<>();
    private C2CChatEventListener c2CChatEventListener;

    public ImageVideoBrowsePresenter() {
        messageChangedListener.presenterWeakReference = new WeakReference<>(this);
        TUICore.registerEvent(TUIChatConstants.EVENT_KEY_MESSAGE_STATUS_CHANGED, TUIChatConstants.EVENT_SUB_KEY_MESSAGE_SEND, messageChangedListener);
    }

    public void initChatEventListener() {
        c2CChatEventListener = new C2CChatEventListener() {
            @Override
            public void onRecvMessageModified(TUIMessageBean messageBean) {
                onMessageStatusChanged(messageBean);
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(c2CChatEventListener);
    }

    public void setBrowseListener(ImageVideoBrowseListener browseListener) {
        this.browseListener = browseListener;
    }

    public void onMessageStatusChanged(TUIMessageBean messageBean) {
        if (browseListener != null && messageBean.hasRiskContent()) {
            if (currentMessageBean != null && TextUtils.equals(messageBean.getId(), currentMessageBean.getId()) && !currentMessageBean.hasRiskContent()) {
                if (browseListener != null) {
                    browseListener.onMessageHasRiskContent(messageBean);
                    browseListener.onCurrentMessageHasRiskContent(messageBean);
                }
            }
            return;
        }
        if (browseListener != null) {
            browseListener.onDataChanged(messageBean);
        }
    }

    public void init(TUIMessageBean messageBean, List<TUIMessageBean> messageBeans, boolean isForwardMode) {
        this.isForwardMode = isForwardMode;
        loadedMessages.clear();
        if (browseListener == null) {
            return;
        }
        int postion = 0;

        if (isForwardMode) {
            loadedMessages.addAll(messageBeans);

            for (int i = 0; i < messageBeans.size(); i++) {
                if (messageBeans.get(i).getId().equals(messageBean.getId())) {
                    postion = i;
                    break;
                }
            }
        } else {
            loadedMessages.add(messageBean);
            provider = new ImageVideoBrowseProvider();
            chatID = messageBean.isGroup() ? messageBean.getV2TIMMessage().getGroupID() : messageBean.getV2TIMMessage().getUserID();
            isGroup = messageBean.isGroup();
            provider.initMessageList(chatID, messageBean.isGroup(), messageBean, new IUIKitCallback<List<TUIMessageBean>>() {
                @Override
                public void onSuccess(List<TUIMessageBean> messageBeans) {
                    loadedMessages.clear();
                    loadedMessages.addAll(messageBeans);
                    setDataSource();
                    onDataSourceChanged();

                    int postion = 0;
                    for (int i = 0; i < messageBeans.size(); i++) {
                        if (messageBeans.get(i).getId().equals(messageBean.getId())) {
                            postion = i;
                            break;
                        }
                    }
                    browseListener.setCurrentItem(postion);
                }

                @Override
                public void onError(String module, int errCode, String errMsg) {
                    TUIChatLog.e(TAG, "loadChatMessages initMessageList failed, code = " + errCode + ", desc = " + errMsg);
                }
            });
        }
        setDataSource();
        onDataSourceChanged();
        browseListener.setCurrentItem(postion);
    }

    private void setDataSource() {
        if (browseListener != null) {
            browseListener.setDataSource(new ArrayList<>(loadedMessages));
        }
    }

    private void onDataSourceChanged() {
        if (browseListener != null) {
            browseListener.onDataSourceChanged();
        }
    }

    private void onDataSourceInserted(int position, int count) {
        if (browseListener != null) {
            browseListener.onDataSourceInserted(position, count);
        }
    }

    public void loadLocalMediaMessageForward(TUIMessageBean locateMessageBean) {
        provider.loadLocalMediaMessageForward(chatID, isGroup, locateMessageBean, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> messageBeans) {
                if (messageBeans == null || messageBeans.isEmpty()) {
                    return;
                }

                onLoadedMessageUpdate(messageBeans, TUIChatConstants.GET_MESSAGE_FORWARD);

            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.e(TAG, "onPageSelected loadLocalMediaMessageForward failed, code = " + errCode + ", desc = " + errMsg);
            }
        });
    }

    public void loadLocalMediaMessageBackward(TUIMessageBean locateMessageBean) {
        provider.loadLocalMediaMessageBackward(chatID, isGroup, locateMessageBean, new IUIKitCallback<List<TUIMessageBean>>() {
            @Override
            public void onSuccess(List<TUIMessageBean> messageBeans) {
                if (messageBeans == null || messageBeans.isEmpty()) {
                    return;
                }
                onLoadedMessageUpdate(messageBeans, TUIChatConstants.GET_MESSAGE_BACKWARD);
            }

            @Override
            public void onError(String module, int errCode, String errMsg) {
                TUIChatLog.e(TAG, "onPageSelected loadLocalMediaMessageBackward failed, code = " + errCode + ", desc = " + errMsg);
            }
        });
    }

    private void onLoadedMessageUpdate(List<TUIMessageBean> data, int type) {
        boolean isForward = type == TUIChatConstants.GET_MESSAGE_FORWARD;

        for (TUIMessageBean messageBean : loadedMessages) {
            Iterator<TUIMessageBean> iterator = data.listIterator();
            while (iterator.hasNext()) {
                TUIMessageBean dataBean = iterator.next();
                if (TextUtils.equals(dataBean.getId(), messageBean.getId())) {
                    iterator.remove();
                }
            }
        }
        if (isForward) {
            loadedMessages.addAll(0, data);
            setDataSource();
            onDataSourceInserted(0, data.size());
        } else {
            loadedMessages.addAll(data);
            setDataSource();
            onDataSourceInserted(loadedMessages.size() - data.size(), data.size());
        }
    }

    public void setCurrentMessageBean(TUIMessageBean currentMessageBean) {
        this.currentMessageBean = currentMessageBean;
    }

    public void saveLocal(Context context) {
        TUIMessageBean messageBean = currentMessageBean;
        if (messageBean instanceof ImageMessageBean) {
            saveImage(context, (ImageMessageBean) messageBean);
        } else if (messageBean instanceof VideoMessageBean) {
            String videoPath = ChatFileDownloadPresenter.getVideoPath((VideoMessageBean) messageBean);
            if (com.tencent.qcloud.tuikit.timcommon.util.FileUtil.isFileExists(videoPath)) {
                saveVideo(context, videoPath);
            } else {
                ToastUtil.toastShortMessage(context.getString(R.string.downloading));
            }
        } else {
            TUIChatLog.d(TAG, "error message type");
        }
    }

    private void saveImage(Context context, ImageMessageBean imageMessageBean) {
        ThreadUtils.execute(new Runnable() {
            @Override
            public void run() {
                boolean isSuccess;
                String imagePath = ChatFileDownloadPresenter.getImagePath(imageMessageBean, ImageMessageBean.IMAGE_TYPE_ORIGIN);
                if (!FileUtil.isFileExists(imagePath)) {
                    imagePath = ChatFileDownloadPresenter.getImagePath(imageMessageBean, ImageMessageBean.IMAGE_TYPE_LARGE);
                }
                if (!FileUtil.isFileExists(imagePath)) {
                    imagePath = ChatFileDownloadPresenter.getImagePath(imageMessageBean, ImageMessageBean.IMAGE_TYPE_THUMB);
                }
                isSuccess = FileUtil.saveImageToGallery(context, imagePath);
                if (isSuccess) {
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
