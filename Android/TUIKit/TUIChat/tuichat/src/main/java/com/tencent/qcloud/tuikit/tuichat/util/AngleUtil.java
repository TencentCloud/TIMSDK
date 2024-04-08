package com.tencent.qcloud.tuikit.tuichat.util;

public class AngleUtil {
    public static int getSensorAngle(float x, float y) {
        if (Math.abs(x) > Math.abs(y)) {
            /**
             * The tilt angle of the horizontal screen is relatively large
             */
            if (x > 4) {
                /**
                 * left tilt
                 */
                return 270;
            } else if (x < -4) {
                /**
                 * right tilt
                 */
                return 90;
            } else {
                /**
                 * The angle of inclination is not large enough
                 */
                return 0;
            }
        } else {
            if (y > 7) {
                /**
                 * left tilt
                 */
                return 0;
            } else if (y < -7) {
                /**
                 * right tilt
                 */
                return 180;
            } else {
                /**
                 * The angle of inclination is not large enough
                 */
                return 0;
            }
        }
    }
}
