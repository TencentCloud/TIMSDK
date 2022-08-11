package com.tencent.qcloud.tuikit.tuicallkit.extensions;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.PowerManager;

import com.tencent.qcloud.tuikit.tuicallengine.impl.base.TUILog;

public class CallingScreenSensorFeature {
    private static final String TAG = "CallingScreenSensorFeature";

    private Context             mContext;
    private SensorManager       mSensorManager;
    private SensorEventListener mSensorEventListener;
    private boolean             mEnableCloseScreenNearEar = true;

    public CallingScreenSensorFeature(Context context) {
        mContext = context;
    }

    public void enableScreenSensor(boolean enable) {
        mEnableCloseScreenNearEar = enable;
    }

    public void registerSensorEventListener() {
        if (!mEnableCloseScreenNearEar) {
            TUILog.i(TAG, "you have already reject screen sensor");
            return;
        }
        if (null != mSensorManager) {
            return;
        }
        TUILog.i(TAG, "registerSensorEventListener");
        mSensorManager = (SensorManager) mContext.getSystemService(Context.SENSOR_SERVICE);
        Sensor sensor = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
        PowerManager pm = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
        final PowerManager.WakeLock wakeLock = pm.newWakeLock(PowerManager.PROXIMITY_SCREEN_OFF_WAKE_LOCK,
                "TUICalling:TRTCAudioCallWakeLock");
        mSensorEventListener = new SensorEventListener() {
            @Override
            public void onSensorChanged(SensorEvent event) {
                if (event.sensor.getType() == Sensor.TYPE_PROXIMITY) {
                    if (event.values[0] == 0.0) {
                        if (wakeLock.isHeld()) {
                            return;
                        } else {
                            wakeLock.acquire();
                        }
                    } else {
                        if (!wakeLock.isHeld()) {
                            return;
                        } else {
                            wakeLock.setReferenceCounted(false);
                            wakeLock.release();
                        }
                    }
                }
            }

            @Override
            public void onAccuracyChanged(Sensor sensor, int accuracy) {

            }
        };
        mSensorManager.registerListener(mSensorEventListener, sensor, SensorManager.SENSOR_DELAY_FASTEST);
    }

    public void unregisterSensorEventListener() {
        if (null != mSensorManager && null != mSensorEventListener) {
            TUILog.i(TAG, "unregisterSensorEventListener");
            Sensor sensor = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY);
            mSensorManager.unregisterListener(mSensorEventListener, sensor);
            mSensorManager = null;
        }
    }
}
