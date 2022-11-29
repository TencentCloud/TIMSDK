package com.tencent.qcloud.tuikit.tuichat.component.face;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.text.Editable;
import android.text.Spannable;
import android.text.SpannableStringBuilder;
import android.text.TextUtils;
import android.text.style.ImageSpan;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import com.bumptech.glide.Glide;
import com.bumptech.glide.request.RequestOptions;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuicore.util.ThreadHelper;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatLog;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutionException;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class FaceManager {
    private static final String TAG = "FaceManager";

    private static final class FaceManagerHolder {
        @SuppressLint("StaticFieldLeak")
        private static final FaceManager instance = new FaceManager();
    }

    public static final int EMOJI_GROUP_ID = 0;
    private static final int EMOJI_SIZE = 20;
    private static final int EMOJI_COLUMN_COUNT = 8;
    private static final int EMOJI_ROW_COUNT = 3;

    private final Map<String, Emoji> emojiMap = new LinkedHashMap<>();
    private final Context context;
    private final String[] emojiKeys;
    private final String[] emojiNames;

    private final Map<Integer, FaceGroup> faceGroupMap = new ConcurrentHashMap<>();

    /**
     * Does the emojis need to be loaded
     * 表情是否需要加载
     */
    private boolean needLoad = true;

    private FaceManager() {
        context = TUIChatService.getAppContext();
        emojiKeys = context.getResources().getStringArray(R.array.emoji_key);
        emojiNames = context.getResources().getStringArray(R.array.emoji_name);
    }

    public static FaceManager getInstance() {
        return FaceManagerHolder.instance;
    }

    public static ArrayList<Emoji> getEmojiList() {
        return new ArrayList<>(getInstance().emojiMap.values());
    }

    /**
     * add a new faceGroup
     * @param groupID must >= 1
     * @param faceGroup the faceGroup be added
     */
    public static void addFaceGroup(int groupID, FaceGroup faceGroup) {
        faceGroup.setGroupID(groupID);
        getInstance().faceGroupMap.put(groupID, faceGroup);
    }

    public static List<FaceGroup> getFaceGroupList() {
        return new ArrayList<>(getInstance().faceGroupMap.values());
    }

    public static String[] getEmojiNames(){
        return getInstance().emojiNames;
    }

    public static String[] getEmojiKey(){
        return getInstance().emojiKeys;
    }

    public static void loadEmojis() {
        getInstance().internalLoadEmojis();
    }

    private synchronized void internalLoadEmojis() {
        if (!needLoad) {
            return;
        }
        needLoad = false;
        TUIChatLog.i(TAG, "start load emojis");
        Thread loadEmojiThread = new Thread() {
            @Override
            public void run() {
                // load chat default emojis
                FaceGroup emojiFaceGroup = new FaceGroup();
                for (String emojiKey : getInstance().emojiKeys) {
                    String emojiFilePath = "emoji/" + emojiKey + "@2x.png";
                    Emoji emoji = loadAssetEmoji(emojiKey, emojiFilePath);
                    if (emoji != null) {
                        emojiMap.put(emojiKey, emoji);
                        emojiFaceGroup.addFace(emojiKey, emoji);
                    }
                }
                emojiFaceGroup.setPageColumnCount(EMOJI_COLUMN_COUNT);
                emojiFaceGroup.setPageRowCount(EMOJI_ROW_COUNT);
                emojiFaceGroup.setFaceGroupIconUrl("file:///android_asset/emoji/[可爱]@2x.png");
                addFaceGroup(EMOJI_GROUP_ID, emojiFaceGroup);
                TUIChatLog.i(TAG, "load emojis finished");
            }
        };
        loadEmojiThread.setName("TUIChatLoadEmojiThread");
        ThreadHelper.INST.execute(loadEmojiThread);
    }

    private Emoji loadAssetEmoji(String emojiKey, String assetFilePath) {
        String realPath = "file:///android_asset/" + assetFilePath;
        int emojiSize = ScreenUtil.dip2px(EMOJI_SIZE);
        Bitmap bitmap = loadBitmap(realPath, emojiSize, emojiSize);
        if (bitmap == null) {
            return null;
        }
        Emoji emoji = new Emoji();
        emoji.setIcon(bitmap);
        emoji.setFaceKey(emojiKey);
        return emoji;
    }

    private Bitmap loadBitmap(String resUrl, int width, int height) {
        Bitmap bitmap = null;
        try {
            bitmap = Glide.with(context)
                    .asBitmap()
                    .load(resUrl)
                    .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                    .submit(width, height)
                    .get();
        } catch (InterruptedException | ExecutionException e) {
            TUIChatLog.e(TAG, "load bitmap failed : " + e.getMessage());
        }
        return bitmap;
    }

    public static void loadFace(ChatFace chatFace, ImageView imageView) {
        getInstance().internalLoadFace(chatFace, imageView, true);
    }

    private void internalLoadFace(ChatFace chatFace, ImageView imageView, boolean isBitMap) {
        if (imageView == null || chatFace == null) {
            return;
        }
        if (chatFace instanceof Emoji) {
            Glide.with(imageView.getContext())
                    .load(((Emoji) chatFace).getIcon())
                    .centerInside()
                    .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                    .into(imageView);
            return;
        }
        String faceUrl = "";
        FaceGroup faceGroup = chatFace.getFaceGroup();
        if (faceGroup != null) {
            ChatFace face = faceGroup.getFace(chatFace.getFaceKey());
            if (face != null) {
                faceUrl = face.getFaceUrl();
            }
        }
        if (isBitMap) {
            Glide.with(imageView.getContext())
                    .asBitmap()
                    .load(faceUrl)
                    .centerInside()
                    .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                    .into(imageView);
        } else {
            Glide.with(imageView.getContext())
                    .load(faceUrl)
                    .centerInside()
                    .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                    .into(imageView);
        }
    }

    public static void loadFace(int faceGroupID, String faceKey, ImageView view) {
        getInstance().internalLoadFace(faceGroupID, faceKey, view);
    }

    private void internalLoadFace(int faceGroupID, String faceKey, ImageView imageView) {
        if (imageView == null) {
            return;
        }
        if (TextUtils.isEmpty(faceKey)) {
            Glide.with(imageView.getContext())
                    .load(android.R.drawable.ic_menu_report_image)
                    .centerInside()
                    .into(imageView);
            return;
        }
        String faceUrl = "";
        FaceGroup faceGroup = faceGroupMap.get(faceGroupID);
        if (faceGroup != null) {
            ChatFace face = faceGroup.getFace(faceKey);
            if (face != null) {
                faceUrl = face.getFaceUrl();
            }
        }
        Glide.with(imageView.getContext())
                .load(faceUrl)
                .centerInside()
                .apply(new RequestOptions().error(android.R.drawable.ic_menu_report_image))
                .into(imageView);
    }

    public static Map<String, Emoji> getEmojiMap() {
        return getInstance().emojiMap;
    }

    public static boolean isFaceChar(String faceChar) {
        return getEmojiMap().get(faceChar) != null;
    }

    public static boolean handlerEmojiText(TextView comment, CharSequence content, boolean typing) {
        if (content == null) {
            comment.setText(null);
            return false;
        }

        Spannable spannable;
        if (comment instanceof EditText && content instanceof Editable) {
            spannable = (Editable) content;
            ImageSpan[] imageSpans = ((Editable) content).getSpans(0, content.length(), ImageSpan.class);
            for (ImageSpan span : imageSpans) {
                ((Editable) content).removeSpan(span);
            }
        } else {
            spannable = new SpannableStringBuilder(content);
        }
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(content);
        boolean imageFound = false;
        while (m.find()) {
            String emojiName = m.group();
            Emoji emoji = getEmojiMap().get(emojiName);
            if (emoji != null) {
                Bitmap bitmap = emoji.getIcon();
                if (bitmap != null) {
                    imageFound = true;

                    ImageSpan imageSpan = new ImageSpan(getInstance().context, bitmap);
                    spannable.setSpan(imageSpan, m.start(), m.end(), Spannable.SPAN_INCLUSIVE_EXCLUSIVE);
                }
            }
        }
        // 如果没有发现表情图片，并且当前是输入状态，不再重设输入框
        // If no emoticon picture is found, and it is currently in the input state, the input box will not be reset.
        if (!imageFound && typing) {
            return false;
        }
        int selection = comment.getSelectionStart();
        if (!(comment instanceof EditText)) {
            comment.setText(spannable);
        }
        if (comment instanceof EditText) {
            ((EditText) comment).setSelection(selection);
        }

        return true;
    }

    public static Bitmap getEmoji(String name) {
        Emoji emoji = getEmojiMap().get(name);
        if (emoji != null) {
            return emoji.getIcon();
        }
        return null;
    }

    public static String emojiJudge(String text){
        if (TextUtils.isEmpty(text)){
            return "";
        }

        String[] emojiList = FaceManager.getEmojiKey();
        if (emojiList ==null || emojiList.length == 0){
            return text;
        }
        SpannableStringBuilder sb = new SpannableStringBuilder(text);
        String regex = "\\[(\\S+?)\\]";
        Pattern p = Pattern.compile(regex);
        Matcher m = p.matcher(text);
        ArrayList<EmojiData> emojiDataArrayList = new ArrayList<>();
        // 遍历找到匹配字符并存储
        // Traverse to find matching characters and store
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

            int index = findEmoji(emojiName);
            String[] emojiListValues = FaceManager.getEmojiNames();
            if (index != -1 && emojiListValues != null && emojiListValues.length >= index){
                emojiName = emojiListValues[index];
            }

            EmojiData emojiData =new EmojiData();
            emojiData.setStart(start);
            emojiData.setEnd(end);
            emojiData.setEmojiText(emojiName);

            emojiDataArrayList.add(emojiData);
        }

        // 倒叙替换
        // flashback replacement
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

    private static int findEmoji(String text){
        int result = -1;
        if (TextUtils.isEmpty(text)){
            return result;
        }

        String[] emojiList = FaceManager.getEmojiKey();
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

    private static class EmojiData {
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
