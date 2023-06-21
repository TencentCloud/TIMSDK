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
import android.net.Uri;
import android.text.TextUtils;

import com.tencent.imsdk.v2.V2TIMImageElem;
import com.tencent.qcloud.tuicore.TUIConfig;
import com.tencent.qcloud.tuicore.TUILogin;
import com.tencent.qcloud.tuicore.util.SPUtils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

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
            bitmap.compress(Bitmap.CompressFormat.JPEG, 100, fOut);
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

    public static Bitmap getBitmapFormPath(Uri uri) {
        Bitmap bitmap = null;
        try {
            BitmapFactory.Options onlyBoundsOptions = new BitmapFactory.Options();
            onlyBoundsOptions.inJustDecodeBounds = true;
            onlyBoundsOptions.inDither = true; // optional
            onlyBoundsOptions.inPreferredConfig = Bitmap.Config.ARGB_8888; // optional
            InputStream input = TUIConfig.getAppContext().getContentResolver().openInputStream(uri);
            BitmapFactory.decodeStream(input, null, onlyBoundsOptions);
            input.close();
            int originalWidth = onlyBoundsOptions.outWidth;
            int originalHeight = onlyBoundsOptions.outHeight;
            if ((originalWidth == -1) || (originalHeight == -1)) {
                return null;
            }
            float hh = 800f;
            float ww = 480f;
            int degree = getBitmapDegree(uri);
            if (degree == 90 || degree == 270) {
                hh = 480;
                ww = 800;
            }
            // 缩放比。由于是固定比例缩放，只用高或者宽其中一个数据进行计算即可
            // zoom ratio. Since it is a fixed scale scaling, only one data of height or width can be used for calculation.
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
            input = TUIConfig.getAppContext().getContentResolver().openInputStream(uri);
            bitmap = BitmapFactory.decodeStream(input, null, bitmapOptions);

            input.close();
            compressImage(bitmap);
            bitmap = rotateBitmapByDegree(bitmap, degree);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return bitmap;
    }

    public static Bitmap getBitmapFormPath(String path) {
        if (TextUtils.isEmpty(path)) {
            return null;
        }
        return getBitmapFormPath(Uri.fromFile(new File(path)));
    }

    public static Bitmap compressImage(Bitmap image) {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        image.compress(Bitmap.CompressFormat.JPEG, 100, baos);
        int options = 100;
        while (baos.toByteArray().length / 1024 > 100) {
            baos.reset();
            image.compress(Bitmap.CompressFormat.JPEG, options, baos);
            options -= 10;
        }
        ByteArrayInputStream isBm = new ByteArrayInputStream(baos.toByteArray());
        Bitmap bitmap = BitmapFactory.decodeStream(isBm, null, null);
        return bitmap;
    }

    /**
     * 读取图片的旋转的角度
     *
     * Read the rotation angle of the image
     */
    public static int getBitmapDegree(Uri uri) {
        int degree = 0;
        try {
            ExifInterface exifInterface = new ExifInterface(FileUtil.getPathFromUri(uri));
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
     * 读取图片的旋转的角度
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
     * 将图片按照某个角度进行旋转
     *
     * @param bm     需要旋转的图片
     * @param degree 旋转角度
     * @return 旋转后的图片
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

    // 图片文件先在本地做旋转，返回旋转之后的图片文件路径
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
     * 转换图片成圆形
     *
     * @param bitmap 传入Bitmap对象
     * @return
     *
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

    public static boolean isImageDownloaded(String imagePath) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(imagePath, options);
            //            ImageDecoder.Source src = ImageDecoder.createSource(mContext.getContentResolver(),
            //                    uri, res);
            //            return ImageDecoder.decodeDrawable(src, (decoder, info, s) -> {
            //                decoder.setAllocator(ImageDecoder.ALLOCATOR_SOFTWARE);
            //            });

            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     *  加载高分辨率图片需要做下适配
     *
     * @param imagePath 图片路径
     * @return Bitmap 调整后的位图
     *
     *
     * Loading high-resolution images requires adaptation
     *
     * @param imagePath
     * @return Bitmap
     */
    public static Bitmap adaptBitmapFormPath(String imagePath, int reqWidth, int reqHeight) {
        try {
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inJustDecodeBounds = true;
            BitmapFactory.decodeFile(imagePath, options);

            options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);

            options.inJustDecodeBounds = false;
            return BitmapFactory.decodeFile(imagePath, options);
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    private static int calculateInSampleSize(BitmapFactory.Options options, int reqWidth, int reqHeight) {
        // Raw height and width of image
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;

        if (height > reqHeight || width > reqWidth) {
            final int halfHeight = height / 2;
            final int halfWidth = width / 2;

            // Calculate the largest inSampleSize value that is a power of 2 and keeps both
            // height and width larger than the requested height and width.
            while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                inSampleSize *= 2;
            }
        }

        return inSampleSize;
    }

    /**
     * 根据图片 UUID 和 类型得到图片文件路径
     * @param uuid 图片 UUID
     * @param imageType 图片类型 V2TIMImageElem.V2TIM_IMAGE_TYPE_THUMB , V2TIMImageElem.V2TIM_IMAGE_TYPE_ORIGIN ,
     *                  V2TIMImageElem.V2TIM_IMAGE_TYPE_LARGE
     * @return 图片文件路径
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
