package com.tencent.qcloud.tuikit.tuichat.component.camera.view;

import static android.graphics.Bitmap.createBitmap;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.Matrix;
import android.graphics.Rect;
import android.graphics.RectF;
import android.hardware.Camera;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.media.MediaRecorder;
import android.os.Build;
import android.util.Log;
import android.view.Surface;
import android.view.SurfaceHolder;
import com.tencent.qcloud.tuikit.timcommon.util.FileUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ThreadUtils;
import com.tencent.qcloud.tuikit.tuichat.component.camera.CameraUtil;
import com.tencent.qcloud.tuikit.tuichat.component.camera.listener.ErrorListener;
import com.tencent.qcloud.tuikit.tuichat.util.AngleUtil;
import com.tencent.qcloud.tuikit.tuichat.util.DeviceUtil;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;
import java.util.ArrayList;
import java.util.List;

public class CameraInterface {
    private static final String TAG = CameraInterface.class.getSimpleName();
    public static final int TYPE_RECORDER = 0x090;
    public static final int TYPE_CAPTURE = 0x091;
    private static volatile CameraInterface mCameraInterface;
    int handlerTime = 0;
    private Camera mCamera;
    private Camera.Parameters mParams;
    private boolean isPreviewing = false;
    private int selectedCamera = -1;
    private int cameraBackPosition = -1;
    private int cameraFrontPosition = -1;
    private float screenProp = -1.0f;
    private boolean isRecording = false;
    private MediaRecorder mediaRecorder;
    private String videoFileAbsPath;
    private ErrorListener errorListener;
    private int previewWidth;
    private int previewHeight;
    private int angle = 0;
    private int cameraAngle = 90;
    private int rotation = 0;
    private int nowScaleRate = 0;
    private int recordScaleRate = 0;
    private OnRotateListener onRotateListener;

    private int nowAngle;
    private int mediaQuality = CameraView.MEDIA_QUALITY_MIDDLE;
    private SensorManager sm = null;
    private final SensorEventListener sensorEventListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent event) {
            if (Sensor.TYPE_ACCELEROMETER != event.sensor.getType()) {
                return;
            }
            float[] values = event.values;
            angle = AngleUtil.getSensorAngle(values[0], values[1]);
            if (onRotateListener != null) {
                onRotateListener.onRotateChanged(angle);
            }
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {}
    };

    private CameraInterface() {
        findAvailableCameras();
        selectedCamera = cameraBackPosition;
    }

    public static void destroyCameraInterface() {
        if (mCameraInterface != null) {
            mCameraInterface.doDestroyCamera();
            mCameraInterface = null;
        }
    }

    public static synchronized CameraInterface getInstance() {
        if (mCameraInterface == null) {
            mCameraInterface = new CameraInterface();
        }
        return mCameraInterface;
    }

    private static Rect calculateTapArea(float x, float y, float coefficient, Context context) {
        float focusAreaSize = 300;
        int areaSize = Float.valueOf(focusAreaSize * coefficient).intValue();
        int centerX = (int) (x / ScreenUtil.getScreenWidth(context) * 2000 - 1000);
        int centerY = (int) (y / ScreenUtil.getScreenHeight(context) * 2000 - 1000);
        int left = clamp(centerX - areaSize / 2, -1000, 1000);
        int top = clamp(centerY - areaSize / 2, -1000, 1000);
        RectF rectF = new RectF(left, top, left + areaSize, top + areaSize);
        return new Rect(Math.round(rectF.left), Math.round(rectF.top), Math.round(rectF.right), Math.round(rectF.bottom));
    }

    private static int clamp(int x, int min, int max) {
        if (x > max) {
            return max;
        }
        if (x < min) {
            return min;
        }
        return x;
    }

    public void setZoom(float zoom, int type) {
        if (mCamera == null) {
            return;
        }
        if (mParams == null) {
            mParams = mCamera.getParameters();
        }
        if (!mParams.isZoomSupported() || !mParams.isSmoothZoomSupported()) {
            return;
        }
        switch (type) {
            case TYPE_RECORDER:
                if (!isRecording) {
                    return;
                }
                if (zoom >= 0) {
                    // Zooms one level every 50 pixels you move
                    int scaleRate = (int) (zoom / 40);
                    if (scaleRate <= mParams.getMaxZoom() && scaleRate >= nowScaleRate && recordScaleRate != scaleRate) {
                        mParams.setZoom(scaleRate);
                        mCamera.setParameters(mParams);
                        recordScaleRate = scaleRate;
                    }
                }
                break;
            case TYPE_CAPTURE:
                if (isRecording) {
                    return;
                }
                // Zooms one level every 50 pixels you move
                int scaleRate = (int) (zoom / 50);
                if (scaleRate < mParams.getMaxZoom()) {
                    nowScaleRate += scaleRate;
                    if (nowScaleRate < 0) {
                        nowScaleRate = 0;
                    } else if (nowScaleRate > mParams.getMaxZoom()) {
                        nowScaleRate = mParams.getMaxZoom();
                    }
                    mParams.setZoom(nowScaleRate);
                    mCamera.setParameters(mParams);
                }
                TUIChatLog.i(TAG, "setZoom = " + nowScaleRate);
                break;
            default:
                break;
        }
    }

    void setMediaQuality(int quality) {
        this.mediaQuality = quality;
    }

    public synchronized void setFlashMode(String flashMode) {
        if (mCamera == null) {
            return;
        }
        try {
            Camera.Parameters params = mCamera.getParameters();
            params.setFlashMode(flashMode);
            mCamera.setParameters(params);
        } catch (Throwable throwable) {
            Log.e(TAG, "set flash mode exception " + throwable.getMessage());
        }
    }

    /**
     * open Camera
     */
    void doOpenCamera() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            if (!CameraUtil.isCameraUsable(selectedCamera)) {
                if (errorListener != null) {
                    errorListener.onError(String.format("camera %d unavailable", selectedCamera));
                }
                return;
            }
        }
        safeOpenCamera(selectedCamera);
    }

    private synchronized void safeOpenCamera(int cameraID) {
        try {
            releaseCameraAndPreview();
            mCamera = Camera.open(cameraID);
            if (Build.VERSION.SDK_INT > 17 && mCamera != null) {
                mCamera.enableShutterSound(false);
            }
        } catch (Throwable throwable) {
            if (this.errorListener != null) {
                this.errorListener.onError("safe open camera exception");
            }
            TUIChatLog.e(TAG, "safe open camera exception " + throwable.getMessage());
        }
    }

    private synchronized void releaseCameraAndPreview() throws Throwable {
        if (mCamera != null) {
            mCamera.setPreviewCallback(null);
            mCamera.stopPreview();
            mCamera.setPreviewDisplay(null);
            mCamera.release();
            mCamera = null;
            isPreviewing = false;
        }
    }

    public synchronized void switchCamera(SurfaceHolder holder, float screenProp) {
        if (selectedCamera == cameraBackPosition) {
            selectedCamera = cameraFrontPosition;
        } else {
            selectedCamera = cameraBackPosition;
        }
        safeOpenCamera(selectedCamera);
        doStartPreview(holder, screenProp);
    }

    /**
     * doStartPreview
     */
    public synchronized void doStartPreview(SurfaceHolder holder, float screenProp) {
        if (isPreviewing) {
            TUIChatLog.i(TAG, "doStartPreview isPreviewing");
        }
        if (this.screenProp < 0) {
            this.screenProp = screenProp;
        }
        if (holder == null) {
            return;
        }
        if (mCamera != null) {
            try {
                mParams = mCamera.getParameters();
                Camera.Size previewSize = CameraUtil.getPreviewSize(mParams.getSupportedPreviewSizes(), 1000, screenProp);
                mParams.setPreviewSize(previewSize.width, previewSize.height);
                previewWidth = previewSize.width;
                previewHeight = previewSize.height;

                Camera.Size pictureSize = CameraUtil.getPictureSize(mParams.getSupportedPictureSizes(), 1200, screenProp);
                mParams.setPictureSize(pictureSize.width, pictureSize.height);

                if (CameraUtil.isSupportedFocusMode(mParams.getSupportedFocusModes(), Camera.Parameters.FOCUS_MODE_AUTO)) {
                    mParams.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
                }
                if (CameraUtil.isSupportedPictureFormats(mParams.getSupportedPictureFormats(), ImageFormat.JPEG)) {
                    mParams.setPictureFormat(ImageFormat.JPEG);
                    mParams.setJpegQuality(100);
                }
                mCamera.setParameters(mParams);
                mParams = mCamera.getParameters();
                mCamera.setPreviewDisplay(holder); // SurfaceView
                mCamera.setDisplayOrientation(cameraAngle);
                mCamera.startPreview();
                isPreviewing = true;
            } catch (Throwable e) {
                TUIChatLog.i(TAG, "start preview exception " + e.getMessage());
                if (this.errorListener != null) {
                    this.errorListener.onError("preview exception");
                }
            }
        }
    }

    public synchronized void doStopPreview() {
        if (null != mCamera) {
            try {
                mCamera.stopPreview();
                mCamera.setPreviewDisplay(null);
                isPreviewing = false;
            } catch (Throwable e) {
                TUIChatLog.i(TAG, "stop preview exception " + e.getMessage());
            }
        }
    }

    void doDestroyCamera() {
        errorListener = null;
        if (null != mCamera) {
            try {
                mCamera.setPreviewCallback(null);
                mCamera.stopPreview();
                mCamera.setPreviewDisplay(null);
                isPreviewing = false;
                mCamera.release();
                mCamera = null;
            } catch (Throwable e) {
                TUIChatLog.i(TAG, "destroy camera exception " + e.getMessage());
            }
        } else {
            TUIChatLog.i(TAG, "doDestroyCamera camera is null");
        }
    }

    public synchronized void takePicture(final TakePictureCallback callback) {
        if (mCamera == null) {
            return;
        }
        switch (cameraAngle) {
            case 90:
                nowAngle = Math.abs(angle + cameraAngle) % 360;
                break;
            case 270:
                nowAngle = Math.abs(cameraAngle - angle);
                break;
            default:
                break;
        }
        TUIChatLog.i(TAG, angle + " = " + cameraAngle + " = " + nowAngle);
        mCamera.takePicture(null, null, new Camera.PictureCallback() {
            @Override
            public void onPictureTaken(byte[] data, Camera camera) {
                Bitmap bitmap = BitmapFactory.decodeByteArray(data, 0, data.length);
                Matrix matrix = new Matrix();
                if (selectedCamera == cameraBackPosition) {
                    matrix.setRotate(nowAngle);
                } else if (selectedCamera == cameraFrontPosition) {
                    matrix.setRotate(360 - nowAngle);
                    matrix.postScale(-1, 1);
                }

                bitmap = createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
                if (callback != null) {
                    if (nowAngle == 90 || nowAngle == 270) {
                        callback.captureResult(bitmap, true);
                    } else {
                        callback.captureResult(bitmap, false);
                    }
                }
            }
        });
    }

    public synchronized void startRecord(Surface surface, float screenProp) {
        final int nowAngle = (angle + 90) % 360;
        if (isRecording) {
            return;
        }
        try {
            if (mediaRecorder == null) {
                mediaRecorder = new MediaRecorder();
            }
            if (mCamera == null) {
                safeOpenCamera(selectedCamera);
            }
            if (mParams == null) {
                mParams = mCamera.getParameters();
            }
            List<String> focusModes = mParams.getSupportedFocusModes();
            if (focusModes.contains(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO)) {
                mParams.setFocusMode(Camera.Parameters.FOCUS_MODE_CONTINUOUS_VIDEO);
            }
            mCamera.setParameters(mParams);
            mediaRecorder.reset();
            if (DeviceUtil.isVivoX21()) {
                safeOpenCamera(selectedCamera);
            }
            mCamera.unlock();
            mediaRecorder.setCamera(mCamera);
            mediaRecorder.setVideoSource(MediaRecorder.VideoSource.CAMERA);

            mediaRecorder.setAudioSource(MediaRecorder.AudioSource.MIC);

            mediaRecorder.setOutputFormat(MediaRecorder.OutputFormat.MPEG_4);
            mediaRecorder.setVideoEncoder(MediaRecorder.VideoEncoder.H264);
            mediaRecorder.setAudioEncoder(MediaRecorder.AudioEncoder.AAC);

            Camera.Size videoSize;
            if (mParams.getSupportedVideoSizes() == null) {
                videoSize = CameraUtil.getPreviewSize(mParams.getSupportedPreviewSizes(), 600, screenProp);
            } else {
                videoSize = CameraUtil.getPreviewSize(mParams.getSupportedVideoSizes(), 600, screenProp);
            }
            TUIChatLog.i(TAG, "setVideoSize    width = " + videoSize.width + "height = " + videoSize.height);
            if (videoSize.width == videoSize.height) {
                mediaRecorder.setVideoSize(previewWidth, previewHeight);
            } else {
                mediaRecorder.setVideoSize(videoSize.width, videoSize.height);
            }

            if (selectedCamera == cameraFrontPosition) {
                if (cameraAngle == 270) {
                    if (nowAngle == 0) {
                        mediaRecorder.setOrientationHint(180);
                    } else if (nowAngle == 270) {
                        mediaRecorder.setOrientationHint(270);
                    } else {
                        mediaRecorder.setOrientationHint(90);
                    }
                } else {
                    if (nowAngle == 90) {
                        mediaRecorder.setOrientationHint(270);
                    } else if (nowAngle == 270) {
                        mediaRecorder.setOrientationHint(90);
                    } else {
                        mediaRecorder.setOrientationHint(nowAngle);
                    }
                }
            } else {
                mediaRecorder.setOrientationHint(nowAngle);
            }

            if (DeviceUtil.isHuaWeiOrHonor()) {
                mediaRecorder.setVideoEncodingBitRate(CameraView.MEDIA_QUALITY_FUNNY);
            } else {
                mediaRecorder.setVideoEncodingBitRate(mediaQuality);
            }
            mediaRecorder.setPreviewDisplay(surface);

            videoFileAbsPath = FileUtil.generateVideoFilePath();
            mediaRecorder.setOutputFile(videoFileAbsPath);
            mediaRecorder.prepare();
            mediaRecorder.start();
            isRecording = true;
        } catch (Exception e) {
            if (this.errorListener != null) {
                this.errorListener.onError("media recorder error " + e.getMessage());
            }
        }
    }

    public synchronized void stopRecord(boolean isShort, StopRecordCallback callback) {
        if (!isRecording) {
            return;
        }
        if (mediaRecorder != null) {
            mediaRecorder.setOnErrorListener(null);
            mediaRecorder.setOnInfoListener(null);
            mediaRecorder.setPreviewDisplay(null);
            try {
                mediaRecorder.stop();
            } catch (RuntimeException e) {
                Log.e(TAG, e.getMessage());
                Log.e(TAG, "stop recording failed, reopen preview.");
                ThreadUtils.postOnUiThread(() -> {
                    if (callback != null) {
                        callback.recordFailed(videoFileAbsPath);
                    }
                });
                return;
            } finally {
                mediaRecorder.release();
                mediaRecorder = null;
                isRecording = false;
            }
            if (!isShort) {
                doStopPreview();
            }
            if (callback != null) {
                callback.recordResult(videoFileAbsPath);
            }
        }
    }

    private void findAvailableCameras() {
        Camera.CameraInfo info = new Camera.CameraInfo();
        int cameraNum = Camera.getNumberOfCameras();
        for (int i = 0; i < cameraNum; i++) {
            Camera.getCameraInfo(i, info);
            switch (info.facing) {
                case Camera.CameraInfo.CAMERA_FACING_FRONT:
                    cameraFrontPosition = info.facing;
                    break;
                case Camera.CameraInfo.CAMERA_FACING_BACK:
                    cameraBackPosition = info.facing;
                    break;
                default:
                    break;
            }
        }
    }

    public void handleFocus(final Context context, final float x, final float y, final FocusCallback callback) {
        if (mCamera == null) {
            return;
        }
        try {
            final Camera.Parameters params = mCamera.getParameters();
            Rect focusRect = calculateTapArea(x, y, 1f, context);
            mCamera.cancelAutoFocus();
            if (params.getMaxNumFocusAreas() > 0) {
                List<Camera.Area> focusAreas = new ArrayList<>();
                focusAreas.add(new Camera.Area(focusRect, 800));
                params.setFocusAreas(focusAreas);
            } else {
                TUIChatLog.i(TAG, "focus areas not supported");
                callback.focusSuccess();
                return;
            }
            final String currentFocusMode = params.getFocusMode();
            params.setFocusMode(Camera.Parameters.FOCUS_MODE_AUTO);
            mCamera.setParameters(params);
            mCamera.autoFocus(new Camera.AutoFocusCallback() {
                @Override
                public void onAutoFocus(boolean success, Camera camera) {
                    if (success || handlerTime > 10) {
                        Camera.Parameters params = camera.getParameters();
                        params.setFocusMode(currentFocusMode);
                        camera.setParameters(params);
                        handlerTime = 0;
                        callback.focusSuccess();
                    } else {
                        handlerTime++;
                        handleFocus(context, x, y, callback);
                    }
                }
            });
        } catch (Exception e) {
            TUIChatLog.e(TAG, "autoFocus failed");
        }
    }

    void setErrorListener(ErrorListener errorListener) {
        this.errorListener = errorListener;
    }

    void registerSensorManager(Context context) {
        if (sm == null) {
            sm = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        }
        sm.registerListener(sensorEventListener, sm.getDefaultSensor(Sensor.TYPE_ACCELEROMETER), SensorManager.SENSOR_DELAY_NORMAL);
    }

    void unregisterSensorManager(Context context) {
        if (sm == null) {
            sm = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        }
        sm.unregisterListener(sensorEventListener);
    }

    void setPreview(boolean isPreviewing) {
        this.isPreviewing = isPreviewing;
    }

    public interface StopRecordCallback {
        void recordResult(String path);

        void recordFailed(String path);
    }

    public interface TakePictureCallback {
        void captureResult(Bitmap bitmap, boolean isVertical);
    }

    public interface FocusCallback {
        void focusSuccess();
    }

    public void setOnRotateListener(OnRotateListener onRotateListener) {
        this.onRotateListener = onRotateListener;
    }

    public interface OnRotateListener {
        void onRotateChanged(int angle);
    }
}
