package com.tencent.qcloud.tim.uikit.component.video.proxy;

import android.content.Context;
import android.net.Uri;
import android.text.TextUtils;
import android.view.Surface;
import android.view.SurfaceHolder;

import com.tencent.qcloud.tim.uikit.utils.TUIKitLog;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

public class IjkMediaPlayerWrapper implements IPlayer {

    private static final String TAG = IjkMediaPlayerWrapper.class.getSimpleName();

    private Class mMediaPlayerClass;
    private Object mMediaPlayerInstance;

    public IjkMediaPlayerWrapper() {
        try {
            mMediaPlayerClass = Class.forName("tv.danmaku.ijk.media.player.IjkMediaPlayer");
            mMediaPlayerInstance = mMediaPlayerClass.newInstance();
        } catch (Exception e) {
            TUIKitLog.i(TAG, "no IjkMediaPlayer: " + e.getMessage());
        }
    }

    @Override
    public void setOnPreparedListener(final OnPreparedListener l) {
        invokeListener("OnPreparedListener", "setOnPreparedListener", l);
    }

    @Override
    public void setOnErrorListener(final OnErrorListener l) {
        invokeListener("OnErrorListener", "setOnErrorListener", l);
    }

    @Override
    public void setOnCompletionListener(final OnCompletionListener l) {
        invokeListener("OnCompletionListener", "setOnCompletionListener", l);
    }

    @Override
    public void setOnVideoSizeChangedListener(final OnVideoSizeChangedListener l) {
        invokeListener("OnVideoSizeChangedListener", "setOnVideoSizeChangedListener", l);
    }


    @Override
    public void setOnInfoListener(final OnInfoListener l) {
        invokeListener("OnInfoListener", "setOnInfoListener", l);
    }

    @Override
    public void setDisplay(SurfaceHolder sh) {
        invoke("setDisplay", sh);
    }

    @Override
    public void setSurface(Surface sh) {
        invoke("setSurface", sh);
    }

    @Override
    public void setDataSource(Context context, Uri uri) {
        invoke("setDataSource", context, uri);
    }

    @Override
    public void prepareAsync() {
        invoke("prepareAsync");
    }

    @Override
    public void release() {
        invoke("release");
    }

    @Override
    public void start() {
        invoke("start");
    }

    @Override
    public void stop() {
        invoke("stop");
    }

    @Override
    public void pause() {
        invoke("pause");
    }

    @Override
    public boolean isPlaying() {
        return (boolean) invoke("isPlaying");
    }

    @Override
    public int getVideoWidth() {
        return (int) invoke("getVideoWidth");
    }

    @Override
    public int getVideoHeight() {
        return (int) invoke("getVideoHeight");
    }

    private Object invoke(String methodName, Object... args) {
        try {
            Class[] classes = null;
            if (args != null && args.length != 0) {
                classes = new Class[args.length];
                for (int i = 0; i < args.length; i++) {
                    classes[i] = args[i].getClass();
                    // setDataSource的参数不能用子类，必须要与方法签名一致
                    if (Context.class.isAssignableFrom(classes[i])) {
                        classes[i] = Context.class;
                    } else if (Uri.class.isAssignableFrom(classes[i])) {
                        classes[i] = Uri.class;
                    }
                }
            } else {
                args = null;
            }
            Method methodInstance = mMediaPlayerClass.getMethod(methodName, classes);
            Object result = methodInstance.invoke(mMediaPlayerInstance, args);
            return result;
        } catch (Exception e) {
            TUIKitLog.e(TAG, "invoke failed: " + methodName + " error: " + e.getCause());
        }
        return null;
    }

    private void invokeListener(String className, String methodName, Object outerListener) {
        try {
            Class<?> listenerClass = Class.forName("tv.danmaku.ijk.media.player.IMediaPlayer$" + className);
            Method method = mMediaPlayerClass.getMethod(methodName, listenerClass);
            ListenerHandler listenerHandler = new ListenerHandler(outerListener);
            Object listenerInstance = Proxy.newProxyInstance(
                    this.getClass().getClassLoader(),
                    new Class[] {listenerClass},
                    listenerHandler
            );
            method.invoke(mMediaPlayerInstance, listenerInstance);
        } catch (Exception e) {
            TUIKitLog.e(TAG, methodName + " failed: " + e.getMessage());
        }
    }

    private class ListenerHandler implements InvocationHandler {

        private Object mListener;

        private ListenerHandler(Object l) {
            mListener = l;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            if (mListener == null) {
                return false;
            }
            if (mListener instanceof OnInfoListener && TextUtils.equals("onInfo", method.getName())) {
                if ((int) args[1] == 10001) {
                    TUIKitLog.i(TAG, "IMediaPlayer.MEDIA_INFO_VIDEO_ROTATION_CHANGED");
                }
                ((OnInfoListener) mListener).onInfo(IjkMediaPlayerWrapper.this, (int) args[1], (int) args[2]);
            } else if (mListener instanceof OnVideoSizeChangedListener && TextUtils.equals("onVideoSizeChanged", method.getName())) {
                TUIKitLog.i(TAG, "width: " + args[1] + " height: " + args[2]
                        + " sarNum: " + args[3] + " sarDen: " + args[4]);
                ((OnVideoSizeChangedListener) mListener).onVideoSizeChanged(IjkMediaPlayerWrapper.this, (int) args[1], (int) args[2]);
            } else if (mListener instanceof OnCompletionListener && TextUtils.equals("onCompletion", method.getName())) {
                ((OnCompletionListener) mListener).onCompletion(IjkMediaPlayerWrapper.this);
            } else if (mListener instanceof OnErrorListener && TextUtils.equals("onError", method.getName())) {
                ((OnErrorListener) mListener).onError(IjkMediaPlayerWrapper.this, (int) args[1], (int) args[2]);
            } else if (mListener instanceof OnPreparedListener && TextUtils.equals("onPrepared", method.getName())) {
                ((OnPreparedListener) mListener).onPrepared(IjkMediaPlayerWrapper.this);
            }
            return false;
        }
    }
}
