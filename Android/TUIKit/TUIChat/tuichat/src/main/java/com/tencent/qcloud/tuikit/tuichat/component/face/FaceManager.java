package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.LayerDrawable;
import android.graphics.drawable.ShapeDrawable;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.BackgroundColorSpan;
import android.text.style.ImageSpan;
import android.util.DisplayMetrics;
import android.util.LruCache;
import android.widget.EditText;
import android.widget.TextView;

import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.config.TUIChatConfigs;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


public class FaceManager {

    private static final int drawableWidth = ScreenUtil.getPxByDp(32);
    private static ArrayList<Emoji> emojiList = new ArrayList<>();
    private static LruCache<String, Bitmap> drawableCache = new LruCache(1024);
    private static Context context = TUIChatService.getAppContext();
    private static String[] emojiFilters = context.getResources().getStringArray(R.array.emoji_filter_key);
    private static String[] emojiFilters_values = context.getResources().getStringArray(R.array.emoji_filter_value);
    private static ArrayList<FaceGroup> customFace = new ArrayList<>();

    public static ArrayList<Emoji> getEmojiList() {
        return emojiList;
    }

    public static ArrayList<FaceGroup> getCustomFaceList() {
        return customFace;
    }


    public static Bitmap getCustomBitmap(int groupId, String name) {
        for (int i = 0; i < customFace.size(); i++) {
            FaceGroup group = customFace.get(i);
            if (group.getGroupId() == groupId) {
                ArrayList<Emoji> faces = group.getFaces();
                for (int j = 0; j < faces.size(); j++) {
                    Emoji face = faces.get(j);
                    if (face.getFilter().equals(name)) {
                        return face.getIcon();
                    }
                }

            }
        }
        return null;
    }

    public static String[] getEmojiFiltersValues(){
        return emojiFilters_values;
    }

    public static String[] getEmojiFilters(){
        return emojiFilters;
    }

    public static void loadFaceFiles() {
        new Thread() {
            @Override
            public void run() {
                for (int i = 0; i < emojiFilters.length; i++) {
                    loadAssetBitmap(emojiFilters[i], "emoji/" + emojiFilters[i] + "@2x.png", true);
                }
                CustomFaceConfig config = TUIChatService.getChatConfig().getCustomFaceConfig();
                if (config == null) {
                    return;
                }
                List<CustomFaceGroup> groups = config.getFaceGroups();
                if (groups == null) {
                    return;
                }
                for (int i = 0; i < groups.size(); i++) {
                    CustomFaceGroup groupConfigs = groups.get(i);
                    FaceGroup groupInfo = new FaceGroup();
                    groupInfo.setGroupId(groupConfigs.getFaceGroupId());
                    groupInfo.setDesc(groupConfigs.getFaceIconName());
                    groupInfo.setPageColumnCount(groupConfigs.getPageColumnCount());
                    groupInfo.setPageRowCount(groupConfigs.getPageRowCount());
                    groupInfo.setGroupIcon(loadAssetBitmap(groupConfigs.getFaceIconName(), groupConfigs.getFaceIconPath(), false).getIcon());

                    ArrayList<CustomFace> customFaceArray = groupConfigs.getCustomFaceList();
                    ArrayList<Emoji> faceList = new ArrayList<>();
                    for (int j = 0; j < customFaceArray.size(); j++) {
                        CustomFace face = customFaceArray.get(j);
                        Emoji emoji = loadAssetBitmap(face.getFaceName(), face.getAssetPath(), false);
                        emoji.setWidth(face.getFaceWidth());
                        emoji.setHeight(face.getFaceHeight());
                        faceList.add(emoji);

                    }
                    groupInfo.setFaces(faceList);
                    customFace.add(groupInfo);
                }
            }
        }.start();


    }


    private static Emoji loadAssetBitmap(String filter, String assetPath, boolean isEmoji) {
        InputStream is = null;
        try {
            Emoji emoji = new Emoji();
            Resources resources = context.getResources();
            BitmapFactory.Options options = new BitmapFactory.Options();
            options.inDensity = DisplayMetrics.DENSITY_XXHIGH;
            options.inScreenDensity = resources.getDisplayMetrics().densityDpi;
            options.inTargetDensity = resources.getDisplayMetrics().densityDpi;
            context.getAssets().list("");
            is = context.getAssets().open(assetPath);
            Bitmap bitmap = BitmapFactory.decodeStream(is, new Rect(0, 0, drawableWidth, drawableWidth), options);
            if (bitmap != null) {
                drawableCache.put(filter, bitmap);

                emoji.setIcon(bitmap);
                emoji.setFilter(filter);
                if (isEmoji) {
                    emojiList.add(emoji);
                }

            }
            return emoji;
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (is != null) {
                try {
                    is.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return null;
    }


    public static int calculateInSampleSize(BitmapFactory.Options options,
                                            int reqWidth, int reqHeight) {
        // 源图片的高度和宽度
        final int height = options.outHeight;
        final int width = options.outWidth;
        int inSampleSize = 1;
        if (height > reqHeight || width > reqWidth) {
            // 计算出实际宽高和目标宽高的比率
            final int heightRatio = Math.round((float) height / (float) reqHeight);
            final int widthRatio = Math.round((float) width / (float) reqWidth);
            // 选择宽和高中最小的比率作为inSampleSize的值，这样可以保证最终图片的宽和高
            // 一定都会大于等于目标的宽和高。
            inSampleSize = heightRatio < widthRatio ? heightRatio : widthRatio;
        }
        return inSampleSize;
    }

    public static Bitmap decodeSampledBitmapFromResource(Resources res, int resId,
                                                         int reqWidth, int reqHeight) {
        // 第一次解析将inJustDecodeBounds设置为true，来获取图片大小
        final BitmapFactory.Options options = new BitmapFactory.Options();
        options.inJustDecodeBounds = true;
        BitmapFactory.decodeResource(res, resId, options);
        // 调用上面定义的方法计算inSampleSize值
        options.inSampleSize = calculateInSampleSize(options, reqWidth, reqHeight);
        // 使用获取到的inSampleSize值再次解析图片
        options.inJustDecodeBounds = false;
        return BitmapFactory.decodeResource(res, resId, options);
    }


    public static int dip2px(Context context, float dipValue) {
        final float scale = context.getResources().getDisplayMetrics().density;
        return (int) (dipValue * scale + 0.5f);
    }

    public static boolean isFaceChar(String faceChar) {
        return drawableCache.get(faceChar) != null;
    }

    public static boolean handlerEmojiText(TextView comment, String content, boolean typing) {
        if (content == null) {
            comment.setText(content);
            return false;
        }
        SpannableStringBuilder sb = new SpannableStringBuilder(content);
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(content);
        boolean imageFound = false;
        while (m.find()) {
            String emojiName = m.group();
            Bitmap bitmap = drawableCache.get(emojiName);
            if (bitmap != null) {
                imageFound = true;

                sb.setSpan(new ImageSpan(context, bitmap),
                        m.start(), m.end(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
            }
        }
        // 如果没有发现表情图片，并且当前是输入状态，不再重设输入框
        if (!imageFound && typing) {
            return false;
        }
        int selection = comment.getSelectionStart();
        comment.setText(sb);
        if (comment instanceof EditText) {
            ((EditText) comment).setSelection(selection);
        }

        return true;
    }

    public static Bitmap getEmoji(String name) {
        return drawableCache.get(name);
    }

    public static String emojiJudge(String text){
        if (TextUtils.isEmpty(text)){
            return "";
        }

        String[] emojiList = FaceManager.getEmojiFilters();
        if (emojiList ==null || emojiList.length == 0){
            return text;
        }

        SpannableStringBuilder sb = new SpannableStringBuilder(text);
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        ArrayList<EmojiData> emojiDataArrayList = new ArrayList<>();
        //遍历找到匹配字符并存储
        int lastMentionIndex = -1;
        while (m.find()) {
            String emojiName = m.group();
            int start;
            if (lastMentionIndex != -1) {
                start = text.indexOf(emojiName, lastMentionIndex);
            } else {
                start = text.indexOf(emojiName);
            }
            int end = start + emojiName.length();
            lastMentionIndex = end;

            int index = findeEmoji(emojiName);
            String[] emojiListValues = FaceManager.getEmojiFiltersValues();
            if (index != -1 && emojiListValues != null && emojiListValues.length >= index){
                emojiName = emojiListValues[index];
            }


            EmojiData emojiData =new EmojiData();
            emojiData.setStart(start);
            emojiData.setEnd(end);
            emojiData.setEmojiText(emojiName);

            emojiDataArrayList.add(emojiData);
        }

        //倒叙替换
        if (emojiDataArrayList.isEmpty()){
            return text;
        }
        for (int i = emojiDataArrayList.size() - 1; i >= 0; i--){
            EmojiData emojiData = emojiDataArrayList.get(i);
            String emojiName = emojiData.getEmojiText();
            int start = emojiData.getStart();
            int end = emojiData.getEnd();

            if (!TextUtils.isEmpty(emojiName) && start != -1 && end != -1) {
                sb.replace(start, end, emojiName);
            }
        }
        return sb.toString();
    }

    private static int findeEmoji(String text){
        int result = -1;
        if (TextUtils.isEmpty(text)){
            return result;
        }

        String[] emojiList = FaceManager.getEmojiFilters();
        if (emojiList ==null || emojiList.length == 0){
            return result;
        }

        for (int i = 0; i < emojiList.length; i++){
            if (text.equals(emojiList[i])){
                result = i;
                break;
            }
        }

        return result;
    }

    private static class EmojiData{
        private int start;
        private int end;
        private String emojiText;

        public int getEnd() {
            return end;
        }

        public void setEnd(int end) {
            this.end = end;
        }

        public int getStart() {
            return start;
        }

        public void setStart(int start) {
            this.start = start;
        }

        public String getEmojiText() {
            return emojiText;
        }

        public void setEmojiText(String emojiText) {
            this.emojiText = emojiText;
        }
    }

}
