package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu;

import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.ColorFilter;
import android.graphics.LightingColorFilter;
import android.graphics.Rect;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.GestureDetector;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.res.ResourcesCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.qcloud.tuicore.component.RoundCornerImageView;
import com.tencent.qcloud.tuicore.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.bean.message.TUIMessageBean;
import com.tencent.qcloud.tuikit.tuichat.component.face.Emoji;
import com.tencent.qcloud.tuikit.tuichat.component.face.FaceManager;
import com.tencent.qcloud.tuikit.tuichat.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageContentHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.util.BlurUtils;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class ChatPopActivity extends AppCompatActivity {
    private static final String TAG = ChatPopActivity.class.getSimpleName();

    private static final int ACTION_MAX_NUM_PER_PAGE = 4;
    private static final int RECENT_EMOJI_NUM = 6;
    private static final String RECENT_EMOJI_KEY = "recentEmoji";

    private List<ChatPopMenuAction> chatPopMenuActionList;
    private final List<Emoji> emojiList = new ArrayList<>();
    private final List<String> recentEmojiList = new ArrayList<>();

    private boolean isShowFaces = true;

    private ViewGroup popupView;
    private View actionArea;
    private RecyclerView actionRecyclerView;
    private RecyclerView recentFaceView;
    private MenuActionAdapter menuActionAdapter;

    private FrameLayout frameLayout;
    private RelativeLayout dialogContainer;
    private ScrollView scrollMessageContainer;
    private View moreBtn;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_minimalist_pop_menu_layout);
        popupView = findViewById(android.R.id.content);
        dialogContainer = popupView.findViewById(R.id.dialog_content_layout);
        moreBtn = popupView.findViewById(R.id.more_btn);
        actionArea = popupView.findViewById(R.id.action_area);
        actionRecyclerView = popupView.findViewById(R.id.chat_pop_menu_action_view);
        recentFaceView = popupView.findViewById(R.id.recent_faces);
        scrollMessageContainer = popupView.findViewById(R.id.scroll_container);
        // message container can not scroll
        scrollMessageContainer.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                return true;
            }
        });
        chatPopMenuActionList = ChatPopDataHolder.getActionList();
        if (chatPopMenuActionList == null || chatPopMenuActionList.size() <= ACTION_MAX_NUM_PER_PAGE) {
            moreBtn.setVisibility(View.GONE);
        }
        Window window = getWindow();
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR1) {
            Bitmap bitmap = BlurUtils.fastBlur(this, ChatPopDataHolder.getChatPopBgBitmap());
            if (bitmap != null) {
                BitmapDrawable bitmapDrawable = new BitmapDrawable(null, bitmap);
                ColorFilter colorFilter = new LightingColorFilter(0x666666, 0);
                bitmapDrawable.setColorFilter(colorFilter);
                window.setBackgroundDrawable(bitmapDrawable);
            } else {
                window.setBackgroundDrawable(new ColorDrawable(0xBF000000));
            }
        } else {
            window.setBackgroundDrawable(new ColorDrawable(0xBF000000));
        }
        frameLayout = findViewById(R.id.message_frame);
        setLocation();
        init();
    }

    private void setLocation() {
        Rect messageRect = ChatPopDataHolder.getMessageViewGlobalRect();
        int actionAreaHeight = ScreenUtil.dip2px(214);
        if (chatPopMenuActionList != null && chatPopMenuActionList.size() <= ACTION_MAX_NUM_PER_PAGE) {
            actionAreaHeight = ScreenUtil.dip2px(40) * chatPopMenuActionList.size() + ScreenUtil.dip2px(8);
        }

        int emojiHeight = ScreenUtil.dip2px(48);
        int screenHeight = ScreenUtil.getScreenHeight(this);

        int statusBarHeight = getStatusBarHeight();

        if (messageRect.top - emojiHeight >= statusBarHeight &&
                messageRect.bottom + actionAreaHeight <= screenHeight) {
            // no need to move container
            dialogContainer.setY(messageRect.top - emojiHeight - statusBarHeight);
        } else {
            // need to move container
            int messageHeight = messageRect.height();
            if (messageHeight + actionAreaHeight + emojiHeight <= screenHeight - statusBarHeight) {
                // no need to move action list
                int dialogContainerHeight = emojiHeight + actionAreaHeight + messageHeight;
                int remainingSpace = screenHeight - dialogContainerHeight;
                if ((remainingSpace / 2) > actionAreaHeight) {
                    dialogContainer.setY(remainingSpace / 2 + statusBarHeight);
                } else {
                    dialogContainer.setY(screenHeight - dialogContainerHeight - statusBarHeight - remainingSpace / 2);
                }
            } else {
                // need to move action list
                RelativeLayout.LayoutParams actionAreaLayoutParams = (RelativeLayout.LayoutParams) actionArea.getLayoutParams();
                actionAreaLayoutParams.removeRule(RelativeLayout.BELOW);
                actionAreaLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM);
                actionAreaLayoutParams.bottomMargin = emojiHeight;
                actionArea.setLayoutParams(actionAreaLayoutParams);
            }
        }
    }

    private int getStatusBarHeight() {
        int statusBarHeight = 0;
        try {
            int resourceId = getResources().getIdentifier("status_bar_height",
                    "dimen", "android");
            statusBarHeight = getResources().getDimensionPixelSize(resourceId);
        } catch (Exception e) {
            Log.e(TAG, "setLocation getStatusBarHeight exception");
        }
        if (statusBarHeight == 0) {
            statusBarHeight = ScreenUtil.dip2px(32);
        }
        return statusBarHeight;
    }

    private void init() {
        Intent intent = getIntent();
        TUIMessageBean messageBean = (TUIMessageBean) intent.getSerializableExtra(TUIChatConstants.MESSAGE_BEAN);
        int type = MinimalistUIService.getInstance().getViewType(messageBean.getClass());
        RecyclerView.ViewHolder holder = MessageViewHolderFactory.getInstance(frameLayout, null, type);
        if (holder instanceof MessageContentHolder) {
            ((MessageContentHolder) holder).setFloatMode(true);
            if (holder instanceof ImageMessageHolder) {
                RoundCornerImageView roundCornerImageView = ChatPopDataHolder.getImageMessageView();
                if (roundCornerImageView != null) {
                    ((ImageMessageHolder) holder).contentImage.setLeftTopRadius(roundCornerImageView.getLeftTopRadius());
                    ((ImageMessageHolder) holder).contentImage.setLeftBottomRadius(roundCornerImageView.getLeftBottomRadius());
                    ((ImageMessageHolder) holder).contentImage.setRightBottomRadius(roundCornerImageView.getRightBottomRadius());
                    ((ImageMessageHolder) holder).contentImage.setRightTopRadius(roundCornerImageView.getRightTopRadius());
                }
            }
            ((MessageContentHolder) holder).layoutViews(messageBean, 0);
            ((MessageContentHolder) holder).msgArea.setBackground(ChatPopDataHolder.getMsgAreaBackground());
        }
        if (messageBean.isSelf()) {
            RelativeLayout.LayoutParams faceViewLayoutParams = (RelativeLayout.LayoutParams) recentFaceView.getLayoutParams();
            faceViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            faceViewLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_START);
            recentFaceView.setLayoutParams(faceViewLayoutParams);
            RelativeLayout.LayoutParams messageContainerLayoutParams = (RelativeLayout.LayoutParams) scrollMessageContainer.getLayoutParams();
            messageContainerLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            messageContainerLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_START);
            scrollMessageContainer.setLayoutParams(messageContainerLayoutParams);
            RelativeLayout.LayoutParams actionAreaLayoutParams = (RelativeLayout.LayoutParams) actionArea.getLayoutParams();
            actionAreaLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            actionAreaLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_START);
            actionArea.setLayoutParams(actionAreaLayoutParams);
        } else {
            RelativeLayout.LayoutParams faceViewLayoutParams = (RelativeLayout.LayoutParams) recentFaceView.getLayoutParams();
            faceViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_START);
            faceViewLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_END);
            recentFaceView.setLayoutParams(faceViewLayoutParams);
            RelativeLayout.LayoutParams messageContainerLayoutParams = (RelativeLayout.LayoutParams) scrollMessageContainer.getLayoutParams();
            messageContainerLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_START);
            messageContainerLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_END);
            scrollMessageContainer.setLayoutParams(messageContainerLayoutParams);
            RelativeLayout.LayoutParams actionAreaLayoutParams = (RelativeLayout.LayoutParams) actionArea.getLayoutParams();
            actionAreaLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_START);
            actionAreaLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_END);
            actionArea.setLayoutParams(actionAreaLayoutParams);
        }
        frameLayout.addView(holder.itemView);
        moreBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                menuActionAdapter.switchNextPage();
            }
        });
        GestureDetector detector = new GestureDetector(this, new GestureDetector.SimpleOnGestureListener() {
            @Override
            public boolean onSingleTapUp(MotionEvent e) {
                onBackPressed();
                return true;
            }
        });
        popupView.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (v == popupView) {
                    detector.onTouchEvent(event);
                    return true;
                }
                return false;
            }
        });
        initEmojiList();

        // actions
        actionRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        menuActionAdapter = new MenuActionAdapter();
        actionRecyclerView.setAdapter(menuActionAdapter);

        // recent faces
        recentFaceView.setItemAnimator(null);
        LinearLayoutManager recentLayoutManager = new LinearLayoutManager(this, RecyclerView.HORIZONTAL, false);
        int recentSpacing = ScreenUtil.dip2px(8f);
        recentFaceView.addItemDecoration(new ChatPopActivity.GridDecoration(null, RECENT_EMOJI_NUM + 1, recentSpacing, 0));
        recentFaceView.setLayoutManager(recentLayoutManager);
        RecentFaceAdapter recentFaceAdapter = new RecentFaceAdapter();
        recentFaceView.setAdapter(recentFaceAdapter);
        if (!isShowFaces) {
            recentFaceView.setVisibility(View.GONE);
        }
    }

    private void initEmojiList() {
        emojiList.addAll(FaceManager.getEmojiList());
        initDefaultEmoji();
    }

    private void initDefaultEmoji() {
        List<String> emojis = null;
        try {
            emojis = (List<String>) RecentEmojiManager.getInstance().getCollection(RECENT_EMOJI_KEY);
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        if (emojis == null) {
            List<Emoji> subList = emojiList.subList(0, RECENT_EMOJI_NUM);
            List<String> emojiKeys = new ArrayList<>();
            for (Emoji emoji : subList) {
                emojiKeys.add(emoji.getFaceKey());
            }
            emojis = new ArrayList<>(emojiKeys);
            try {
                RecentEmojiManager.getInstance().putCollection(RECENT_EMOJI_KEY, emojis);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        recentEmojiList.addAll(emojis);
    }

    private void updateRecentEmoji(Emoji emoji) {
        recentEmojiList.remove(emoji.getFaceKey());
        recentEmojiList.add(0, emoji.getFaceKey());
        try {
            RecentEmojiManager.getInstance().putCollection(RECENT_EMOJI_KEY, recentEmojiList);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    class RecentFaceAdapter extends RecyclerView.Adapter<RecentFaceAdapter.RecentFaceViewHolder> {

        private Emoji moreBtn;

        @NonNull
        @Override
        public RecentFaceAdapter.RecentFaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_menu_recent_face_item_layout, parent, false);
            moreBtn = new Emoji();
            Bitmap bitMap = BitmapFactory.decodeResource(parent.getResources(), R.drawable.chat_pop_menu_add_icon);
            moreBtn.setIcon(bitMap);
            return new RecentFaceAdapter.RecentFaceViewHolder(faceView);
        }

        @Override
        public void onBindViewHolder(@NonNull RecentFaceAdapter.RecentFaceViewHolder holder, int position) {
            Emoji emoji;
            if (position == RECENT_EMOJI_NUM) {
                emoji = moreBtn;
            } else {
                emoji = getEmoji(recentEmojiList.get(position));
            }
            if (emoji == null) {
                return;
            }
            holder.faceIv.setImageBitmap(emoji.getIcon());
            holder.faceIv.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onEmojiClicked(emoji);
                }
            });
        }

        private void onEmojiClicked(Emoji emoji) {
            if (emoji == moreBtn) {
                ChatPopMenuEmojiDialogFragment dialogFragment = new ChatPopMenuEmojiDialogFragment();
                dialogFragment.setEmojiClickListener(new ChatPopMenuEmojiDialogFragment.EmojiClickListener() {
                    @Override
                    public void onClick(Emoji clickedEmoji) {
                        onEmojiClicked(clickedEmoji);
                    }
                });
                dialogFragment.show(getSupportFragmentManager(), "ChatEmoji");
                return;
            }
            ChatPopActivity.EmojiOnClickListener listener = ChatPopDataHolder.getEmojiOnClickListener();
            if (listener != null) {
                listener.onClick(emoji);
                updateRecentEmoji(emoji);
                hide();
            }
        }

        private Emoji getEmoji(String emojiKey) {
            for (Emoji emoji : emojiList) {
                if (TextUtils.equals(emoji.getFaceKey(), emojiKey)) {
                    return emoji;
                }
            }
            return null;
        }

        @Override
        public int getItemCount() {
            return RECENT_EMOJI_NUM + 1;
        }

        class RecentFaceViewHolder extends RecyclerView.ViewHolder {
            ImageView faceIv;

            public RecentFaceViewHolder(@NonNull View itemView) {
                super(itemView);
                faceIv = itemView.findViewById(R.id.face_iv);
            }
        }
    }

    private void hide() {
        onBackPressed();
    }

    private ChatPopMenuAction getChatPopMenuAction(int position) {
        return chatPopMenuActionList.get(position);
    }

    class MenuActionAdapter extends RecyclerView.Adapter<MenuActionAdapter.MenuItemViewHolder> {
        private int page = 1;

        @NonNull
        @Override
        public MenuActionAdapter.MenuItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.chat_minimalist_pop_menu_action_item_layou, parent, false);
            return new MenuActionAdapter.MenuItemViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull MenuActionAdapter.MenuItemViewHolder holder, int position) {
            int realPosition = (page - 1) * ACTION_MAX_NUM_PER_PAGE + position;
            ChatPopMenuAction chatPopMenuAction = getChatPopMenuAction(realPosition);
            if (chatPopMenuAction.textColor != Integer.MAX_VALUE) {
                holder.title.setTextColor(chatPopMenuAction.textColor);
            } else {
                holder.title.setTextColor(Color.BLACK);
            }
            holder.title.setText(chatPopMenuAction.actionName);
            Drawable drawable = ResourcesCompat.getDrawable(holder.itemView.getResources(), chatPopMenuAction.actionIcon, null);
            holder.icon.setImageDrawable(drawable);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    chatPopMenuAction.actionClickListener.onClick();
                    hide();
                }
            });
        }

        public void switchNextPage() {
            page++;
            if (page * ACTION_MAX_NUM_PER_PAGE - chatPopMenuActionList.size() >= ACTION_MAX_NUM_PER_PAGE) {
                page = 1;
            }
            notifyDataSetChanged();
        }

        @Override
        public int getItemCount() {
            if (chatPopMenuActionList == null) {
                return 0;
            }
            return Math.min(chatPopMenuActionList.size() - (page - 1) * ACTION_MAX_NUM_PER_PAGE, ACTION_MAX_NUM_PER_PAGE);
        }

        class MenuItemViewHolder extends RecyclerView.ViewHolder {
            public TextView title;
            public ImageView icon;

            public MenuItemViewHolder(@NonNull View itemView) {
                super(itemView);
                title = itemView.findViewById(R.id.action_name);
                icon = itemView.findViewById(R.id.action_icon);
            }
        }
    }

    static class GridDecoration extends RecyclerView.ItemDecoration {

        private final int columnNum;
        private final int leftRightSpace;
        private final int topBottomSpace;
        private final Drawable divider;

        public GridDecoration(Drawable divider, int columnNum, int leftRightSpace, int topBottomSpace) {
            this.divider = divider;
            this.columnNum = columnNum;
            this.leftRightSpace = leftRightSpace;
            this.topBottomSpace = topBottomSpace;
        }

        @Override
        public void getItemOffsets(Rect outRect, View view, RecyclerView parent, RecyclerView.State state) {
            int position = parent.getChildAdapterPosition(view);
            int column = position % columnNum;

            outRect.left = column * leftRightSpace / columnNum;
            outRect.right = leftRightSpace * (columnNum - 1 - column) / columnNum;

            if (position >= columnNum) {
                outRect.top = topBottomSpace;
            }
        }

        @Override
        public void onDraw(@NonNull Canvas canvas, @NonNull RecyclerView parent, @NonNull RecyclerView.State state) {
            if (divider == null) {
                return;
            }
            canvas.save();
            final int childCount = parent.getChildCount();
            int rowNum = (int) Math.ceil(childCount * 1.0f / columnNum);
            final int divideLine = rowNum - 1;
            for (int i = 0; i < divideLine; i++) {
                View startChild = parent.getChildAt(i * columnNum);
                View endChild = parent.getChildAt((i + 1) * columnNum - 1);
                final int bottom = startChild.getBottom();
                final int top = bottom - divider.getIntrinsicHeight();
                divider.setBounds(startChild.getLeft(), top + topBottomSpace / 2, endChild.getRight(), bottom + topBottomSpace / 2);
                divider.draw(canvas);
            }
            canvas.restore();
        }
    }


    public interface EmojiOnClickListener {
        void onClick(Emoji emoji);
    }

    public static class ChatPopMenuAction {
        private String actionName;

        private int textColor = Integer.MAX_VALUE;

        private int actionIcon;
        private ChatPopMenuAction.OnClickListener actionClickListener;

        public void setActionName(String actionName) {
            this.actionName = actionName;
        }

        public String getActionName() {
            return actionName;
        }

        public void setActionIcon(int actionIcon) {
            this.actionIcon = actionIcon;
        }

        public int getActionIcon() {
            return actionIcon;
        }

        public void setTextColor(int color) {
            this.textColor = color;
        }

        public void setActionClickListener(ChatPopMenuAction.OnClickListener actionClickListener) {
            this.actionClickListener = actionClickListener;
        }

        public ChatPopMenuAction.OnClickListener getActionClickListener() {
            return actionClickListener;
        }

        @FunctionalInterface
        public interface OnClickListener {
            void onClick();
        }
    }

}
