package com.tencent.qcloud.tuikit.tuimultimediaplugin.common;

import android.graphics.Point;
import android.graphics.PointF;
import androidx.annotation.NonNull;

public class TUIMultimediaGraphComputerUtils {

    public static float distance4PointF(@NonNull PointF pf1, @NonNull PointF pf2) {
        float disX = pf2.x - pf1.x;
        float disY = pf2.y - pf1.y;
        return (float) Math.sqrt(disX * disX + disY * disY);
    }

    public static double radianToDegree(double radian) {
        return radian * 180 / Math.PI;
    }

    public static double degreeToRadian(double degree) {
        return degree * Math.PI / 180;
    }

    @NonNull
    public static Point obtainRotationPoint(@NonNull Point center, @NonNull Point source, float degree) {
        Point disPoint = new Point();
        disPoint.x = source.x - center.x;
        disPoint.y = source.y - center.y;
        double originRadian = 0;
        double originDegree;
        double resultDegree;
        double resultRadian;
        Point resultPoint = new Point();

        double distance = Math.sqrt(disPoint.x * disPoint.x + disPoint.y * disPoint.y);
        if (disPoint.x == 0 && disPoint.y == 0) {
            return center;
        } else if (disPoint.x >= 0 && disPoint.y >= 0) {
            originRadian = Math.asin(disPoint.y / distance);
        } else if (disPoint.x < 0 && disPoint.y >= 0) {
            originRadian = Math.asin(Math.abs(disPoint.x) / distance);
            originRadian = originRadian + Math.PI / 2;
        } else if (disPoint.x < 0 && disPoint.y < 0) {
            originRadian = Math.asin(Math.abs(disPoint.y) / distance);
            originRadian = originRadian + Math.PI;
        } else if (disPoint.x >= 0 && disPoint.y < 0) {
            originRadian = Math.asin(disPoint.x / distance);
            originRadian = originRadian + Math.PI * 3 / 2;
        }

        originDegree = radianToDegree(originRadian);
        resultDegree = originDegree + degree;
        resultRadian = degreeToRadian(resultDegree);

        resultPoint.x = (int) Math.round(distance * Math.cos(resultRadian));
        resultPoint.y = (int) Math.round(distance * Math.sin(resultRadian));
        resultPoint.x += center.x;
        resultPoint.y += center.y;

        return resultPoint;
    }
}
