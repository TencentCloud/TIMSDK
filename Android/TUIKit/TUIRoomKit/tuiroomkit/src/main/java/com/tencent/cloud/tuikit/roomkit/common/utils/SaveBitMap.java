package com.tencent.cloud.tuikit.roomkit.common.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.Looper;
import android.provider.MediaStore;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.view.basic.RoomToast;

public class SaveBitMap {

    private boolean       mIsPrecessing;
    private Handler       mHandler;
    private HandlerThread mHandlerThread;

    public SaveBitMap() {
        mHandlerThread = new HandlerThread("save-bitmap-thread");
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());
        mIsPrecessing = false;
    }

    public void saveToAlbum(final Context context, final Bitmap bitmap) {
        if (bitmap == null) {
            RoomToast.toastShortMessage(context.getString(R.string.tuiroomkit_get_image_failed));
            return;
        }
        if (mIsPrecessing) {
            return;
        }
        mIsPrecessing = true;
        final SaveBitMapRunnable runnable = new SaveBitMapRunnable(context, bitmap);
        runnable.setListener(new SaveProgressListener() {
            @Override
            public void onEnd() {
                mIsPrecessing = false;
                mHandler.removeCallbacks(runnable);
            }
        });
        mHandler.post(runnable);
    }

    private static class SaveBitMapRunnable implements Runnable {
        private Context              mContext;
        private Bitmap               mBitmap;
        private SaveProgressListener mListener;
        private Handler              mMainHandler;

        public SaveBitMapRunnable(Context context, Bitmap bitmap) {
            mMainHandler = new Handler(Looper.getMainLooper());
            mContext = context;
            mBitmap = bitmap;
        }

        @Override
        public void run() {
            try {
                MediaStore.Images.Media.insertImage(mContext.getContentResolver(), mBitmap,
                        null, null);
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (mListener != null) {
                            mListener.onEnd();
                        }
                        RoomToast.toastShortMessage(mContext.getString(R.string.tuiroomkit_save_image_success));
                    }
                });
            } catch (Exception e) {
                mMainHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        if (mListener != null) {
                            mListener.onEnd();
                        }
                        RoomToast.toastShortMessage(mContext.getString(R.string.tuiroomkit_save_image_failed));
                    }
                });
            }
        }

        public void setListener(SaveProgressListener listener) {
            this.mListener = listener;
        }
    }

    public interface SaveProgressListener {
        void onEnd();
    }
}

