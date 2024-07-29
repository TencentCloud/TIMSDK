package com.tencent.qcloud.tuikit.timcommon.util;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.media.ExifInterface;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.SPUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class ImageUtil {
    public static final String SP_IMAGE = "_conversation_group_face";

    /**
     * @param outFile
     * @param bitmap
     * @return
     */
    public static File storeBitmap(File outFile, Bitmap bitmap) {
        if (!outFile.exists() || outFile.isDirectory()) {
            outFile.getParentFile().mkdirs();
        }
        FileOutputStream fOut = null;
        try {
            outFile.deleteOnExit();
            outFile.createNewFile();
            fOut = new FileOutputStream(outFile);
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, fOut);
            fOut.flush();
        } catch (IOException e1) {
            outFile.deleteOnExit();
        } finally {
            if (null != fOut) {
                try {
                    fOut.close();
                } catch (IOException e) {
                    e.printStackTrace();
                    outFile.deleteOnExit();
                }
            }
        }
        return outFile;
    }

    /**
     *
     * Read the rotation angle of the image
     */
    public static int getBitmapDegree(String fileName) {
        int degree = 0;
        try {
            ExifInterface exifInterface = new ExifInterface(fileName);
            int orientation = exifInterface.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
            switch (orientation) {
                case ExifInterface.ORIENTATION_ROTATE_90:
                    degree = 90;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_180:
                    degree = 180;
                    break;
                case ExifInterface.ORIENTATION_ROTATE_270:
                    degree = 270;
                    break;
                default:
                    break;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return degree;
    }

    /**
     *
     *
     * Rotate the image by an angle
     *
     * @param bm     image to be rotated
     * @param degree Rotation angle
     * @return rotated image
     */
    public static Bitmap rotateBitmapByDegree(Bitmap bm, int degree) {
        Bitmap returnBm = null;

        Matrix matrix = new Matrix();
        matrix.postRotate(degree);
        try {
            returnBm = Bitmap.createBitmap(bm, 0, 0, bm.getWidth(), bm.getHeight(), matrix, true);
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
        }
        if (returnBm == null) {
            returnBm = bm;
        }
        if (bm != returnBm) {
            bm.recycle();
        }
        return returnBm;
    }

    public static int[] getImageSize(String path) {
        int[] size = new int[2];
        try {
            BitmapFactory.Options onlyBoundsOptions = new BitmapFactory.Options();
            onlyBoundsOptions.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(path, onlyBoundsOptions);
            int originalWidth = onlyBoundsOptions.outWidth;
            int originalHeight = onlyBoundsOptions.outHeight;
            // size[0] = originalWidth;
            // size[1] = originalHeight;

            int degree = getBitmapDegree(path);
            if (degree == 0) {
                size[0] = originalWidth;
                size[1] = originalHeight;
            } else {
                float hh = 800f;
                float ww = 480f;
                if (degree == 90 || degree == 270) {
                    hh = 480;
                    ww = 800;
                }
                int be = 1;
                if (originalWidth > originalHeight && originalWidth > ww) {
                    be = (int) (originalWidth / ww);
                } else if (originalWidth < originalHeight && originalHeight > hh) {
                    be = (int) (originalHeight / hh);
                }
                if (be <= 0) {
                    be = 1;
                }
                BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
                bitmapOptions.inSampleSize = be;
                bitmapOptions.inDither = true;
                bitmapOptions.inPreferredConfig = Bitmap.Config.ARGB_8888;
                Bitmap bitmap = BitmapFactory.decodeFile(path, bitmapOptions);
                bitmap = rotateBitmapByDegree(bitmap, degree);
                size[0] = bitmap.getWidth();
                size[1] = bitmap.getHeight();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return size;
    }

    
    // The image file is rotated locally, and the path of the image file after rotation is returned.
    public static String getImagePathAfterRotate(final String imagePath) {
        try {
            Bitmap originBitmap = BitmapFactory.decodeFile(imagePath, null);
            int degree = ImageUtil.getBitmapDegree(imagePath);
            if (degree == 0) {
                return imagePath;
            } else {
                Bitmap newBitmap = ImageUtil.rotateBitmapByDegree(originBitmap, degree);
                String oldName = FileUtil.getName(imagePath);
                File newImageFile = FileUtil.generateFileName(oldName, FileUtil.getDocumentCacheDir(TUIConfig.getAppContext()));
                if (newImageFile == null) {
                    return imagePath;
                }
                ImageUtil.storeBitmap(newImageFile, newBitmap);
                newBitmap.recycle();
                return newImageFile.getAbsolutePath();
            }
        } catch (Exception e) {
            return imagePath;
        }
    }

    /**
     *
     * Convert image to circle
     *
     * @param bitmap   Pass in a Bitmap object
     * @return
     */
    public static Bitmap toRoundBitmap(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        float roundPx;
        float left;
        float top;
        float right;
        float bottom;
        float dstLeft;
        float dstTop;
        float dstRight;
        float dstBottom;
        if (width <= height) {
            roundPx = width / 2;
            left = 0;
            top = 0;
            right = width;
            bottom = width;
            height = width;
            dstLeft = 0;
            dstTop = 0;
            dstRight = width;
            dstBottom = width;
        } else {
            roundPx = height / 2;
            float clip = (width - height) / 2;
            left = clip;
            right = width - clip;
            top = 0;
            bottom = height;
            width = height;
            dstLeft = 0;
            dstTop = 0;
            dstRight = height;
            dstBottom = height;
        }

        Bitmap output = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Canvas canvas = new Canvas(output);

        final int color = 0xff424242;
        final Paint paint = new Paint();
        final Rect src = new Rect((int) left, (int) top, (int) right, (int) bottom);
        final Rect dst = new Rect((int) dstLeft, (int) dstTop, (int) dstRight, (int) dstBottom);
        final RectF rectF = new RectF(dst);

        paint.setAntiAlias(true);

        canvas.drawARGB(0, 0, 0, 0);
        paint.setColor(color);

        // canvas.drawRoundRect(rectF, roundPx, roundPx, paint);
        canvas.drawCircle(roundPx, roundPx, roundPx, paint);

        paint.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SRC_IN));
        canvas.drawBitmap(bitmap, src, dst, paint);

        return output;
    }

    public static Bitmap zoomImg(Bitmap bm, int targetWidth, int targetHeight) {
        int srcWidth = bm.getWidth();
        int srcHeight = bm.getHeight();
        float widthScale = targetWidth * 1.0f / srcWidth;
        float heightScale = targetHeight * 1.0f / srcHeight;
        Matrix matrix = new Matrix();
        matrix.postScale(widthScale, heightScale, 0, 0);
        Bitmap bmpRet = Bitmap.createBitmap(targetWidth, targetHeight, Bitmap.Config.RGB_565);
        Canvas canvas = new Canvas(bmpRet);
        Paint paint = new Paint();
        canvas.drawBitmap(bm, matrix, paint);
        return bmpRet;
    }

    /**
     *
     * Get the image file path based on the image UUID and type
     * @param uuid
     * @param imageType V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB , V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN ,
     *                  V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE
     * @return path
     */
    public static String generateImagePath(String uuid, int imageType) {
        String imageTypePreStr;
        if (imageType == V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB) {
            imageTypePreStr = "thumb_";
        } else if (imageType == V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN) {
            imageTypePreStr = "origin_";
        } else if (imageType == V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE) {
            imageTypePreStr = "large_";
        } else {
            imageTypePreStr = "other_";
        }
        return TUIConfig.getImageDownloadDir() + imageTypePreStr + uuid;
    }

    public static String getGroupConversationAvatar(String conversationID) {
        SPUtils spUtils = SPUtils.getInstance(TUILogin.getSdkAppId() + SP_IMAGE);
        final String savedIcon = spUtils.getString(conversationID, "");
        if (!TextUtils.isEmpty(savedIcon) && new File(savedIcon).isFile() && new File(savedIcon).exists()) {
            return savedIcon;
        }
        return "";
    }

    public static void setGroupConversationAvatar(String conversationId, String url) {
        SPUtils spUtils = SPUtils.getInstance(TUILogin.getSdkAppId() + SP_IMAGE);
        spUtils.put(conversationId, url);
    }
}
