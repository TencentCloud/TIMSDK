package com.tencent.qcloud.tuikit.tuichat.util;


public class AngleUtil {
    public static int getSensorAngle(float x, float y) {
        if (Math.abs(x) > Math.abs(y)) {
            /**
             * 横屏倾斜角度比较大
             * 
             * The tilt angle of the horizontal screen is relatively large
             */
            if (x > 4) {
                /**
                 * 左边倾斜
                 * 
                 * left tilt
                 */
                return 270;
            } else if (x < -4) {
                /**
                 * 右边倾斜
                 * 
                 * right tilt
                 */
                return 90;
            } else {
                /**
                 * 倾斜角度不够大
                 * 
                 * The angle of inclination is not large enough
                 */
                return 0;
            }
        } else {
            if (y > 7) {
                /**
                 * 左边倾斜
                 * 
                 * left tilt
                 */
                return 0;
            } else if (y < -7) {
                /**
                 * 右边倾斜
                 * 
                 * right tilt
                 */
                return 180;
            } else {
                /**
                 * 倾斜角度不够大
                 * 
                 * The angle of inclination is not large enough
                 */
                return 0;
            }
        }
    }
}
