package com.tencent.qcloud.tuikit.tuiemojiplugin.minimalistui.widget;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Rect;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.ImageView;
import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.interfaces.TUICallback;
import com.tencent.qcloud.tuicore.util.ErrorMessageConverter;
import com.tencent.qcloud.tuicore.util.ToastUtil;
import com.tencent.qcloud.tuikit.timcommon.bean.Emoji;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.component.face.FaceManager;
import com.tencent.qcloud.tuikit.timcommon.component.face.RecentEmojiManager;
import com.tencent.qcloud.tuikit.timcommon.util.LayoutUtil;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu.ChatPopActivity;
import com.tencent.qcloud.tuikit.tuichat.util.TUIChatUtils;
import com.tencent.qcloud.tuikit.tuiemojiplugin.R;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.MessageReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.bean.ReactionBean;
import com.tencent.qcloud.tuikit.tuiemojiplugin.interfaces.OnEmojiClickedListener;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.MessageReactionBeanCache;
import com.tencent.qcloud.tuikit.tuiemojiplugin.presenter.TUIEmojiPresenter;
import com.tencent.qcloud.tuikit.tuiemojiplugin.util.TUIEmojiLog;
import java.util.ArrayList;
import java.util.List;

public class ChatMinimalistPopMenuReactProxy {
    private static final String TAG = ChatMinimalistPopMenuReactProxy.class.getSimpleName();
    private RecyclerView recentFaceView;
    private final List<Emoji> emojiList = new ArrayList<>();
    private final List<String> recentEmojiList = new ArrayList<>();
    private static final int RECENT_EMOJI_NUM = 6;
    private static final String RECENT_EMOJI_KEY = "recentEmoji";
    private ChatPopActivity chatPopActivity;
    private TUIEmojiPresenter presenter;
    private OnEmojiClickedListener onEmojiClickedListener;

    public void fill() {
        presenter = new TUIEmojiPresenter();
        initEmojiList();

        // recent faces
        recentFaceView = (RecyclerView) LayoutInflater.from(chatPopActivity).inflate(R.layout.tuiemoji_minimalist_chat_popup_react_area, null);
        FrameLayout reactionArea = chatPopActivity.getReactionArea();
        reactionArea.addView(recentFaceView);
        recentFaceView.setItemAnimator(null);
        LinearLayoutManager recentLayoutManager = new LinearLayoutManager(chatPopActivity, RecyclerView.HORIZONTAL, false);
        int recentSpacing = ScreenUtil.dip2px(8f);
        recentFaceView.addItemDecoration(new GridDecoration(null, RECENT_EMOJI_NUM + 1, recentSpacing, 0));
        recentFaceView.setLayoutManager(recentLayoutManager);
        RecentFaceAdapter recentFaceAdapter = new RecentFaceAdapter();
        recentFaceView.setAdapter(recentFaceAdapter);
        if (!chatPopActivity.isShowFaces()) {
            recentFaceView.setVisibility(View.GONE);
        }
        onEmojiClickedListener = new OnEmojiClickedListener() {
            @Override
            public void onEmojiClicked(Emoji emoji) {
                MessageReactionBean messageReactionBean = MessageReactionBeanCache.getMessageReactionBean(chatPopActivity.getMessageBean().getId());
                if (messageReactionBean != null) {
                    ReactionBean reactionBean = messageReactionBean.getReactionBean(emoji.getFaceKey());
                    if (reactionBean == null) {
                        addMessageReaction(chatPopActivity.getMessageBean(), emoji.getFaceKey());
                    } else {
                        if (reactionBean.isByMySelf()) {
                            removeMessageReaction(chatPopActivity.getMessageBean(), emoji.getFaceKey());
                        } else {
                            addMessageReaction(chatPopActivity.getMessageBean(), emoji.getFaceKey());
                        }
                    }
                }
                RecentEmojiManager.updateRecentUseEmoji(emoji.getFaceKey());
                chatPopActivity.hide();
            }
        };
    }

    private void addMessageReaction(TUIMessageBean messageBean, String reactionID) {
        presenter.addMessageReaction(messageBean, reactionID, new TUICallback() {
            @Override
            public void onSuccess() {
                TUIEmojiLog.i(TAG, "addMessageReaction success " + messageBean.getId() + " " + reactionID);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIEmojiLog.e(TAG, "addMessageReaction failed code " + errorCode + ",message " + errorMessage);
                ToastUtil.toastLongMessage(
                        chatPopActivity.getString(R.string.tuiemoji_add_reaction_failed_tip) + " " + ErrorMessageConverter.convertIMError(errorCode, errorMessage));
            }
        });
    }

    private void removeMessageReaction(TUIMessageBean messageBean, String reactionID) {
        presenter.removeMessageReaction(messageBean, reactionID, new TUICallback() {
            @Override
            public void onSuccess() {
                TUIEmojiLog.i(TAG, "removeMessageReaction success " + messageBean.getId() + " " + reactionID);
            }

            @Override
            public void onError(int errorCode, String errorMessage) {
                TUIEmojiLog.e(TAG, "addMessageReaction failed code " + errorCode + ",message " + errorMessage);
                ToastUtil.toastLongMessage(
                        chatPopActivity.getString(R.string.tuiemoji_remove_reaction_failed_tip) + " " + ErrorMessageConverter.convertIMError(errorCode, errorMessage));
            }
        });
    }

    public void setChatPopActivity(ChatPopActivity chatPopActivity) {
        this.chatPopActivity = chatPopActivity;
    }

    private void initEmojiList() {
        emojiList.addAll(FaceManager.getEmojiList());
        initDefaultEmoji();
    }

    private void initDefaultEmoji() {
        List<String> emojis = null;
        emojis = (List<String>) RecentEmojiManager.getCollection();
        if (emojis == null) {
            List<Emoji> subList = emojiList.subList(0, RECENT_EMOJI_NUM);
            List<String> emojiKeys = new ArrayList<>();
            for (Emoji emoji : subList) {
                emojiKeys.add(emoji.getFaceKey());
            }
            emojis = new ArrayList<>(emojiKeys);
            RecentEmojiManager.getInstance().putCollection(RECENT_EMOJI_KEY, emojis);
        }
        recentEmojiList.addAll(emojis);
    }

    private void updateRecentEmoji(Emoji emoji) {
        recentEmojiList.remove(emoji.getFaceKey());
        recentEmojiList.add(0, emoji.getFaceKey());
        RecentEmojiManager.updateRecentUseEmoji(emoji.getFaceKey());
    }

    class RecentFaceAdapter extends RecyclerView.Adapter<RecentFaceAdapter.RecentFaceViewHolder> {
        private Emoji moreBtn;

        @NonNull
        @Override
        public RecentFaceAdapter.RecentFaceViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View faceView = LayoutInflater.from(parent.getContext()).inflate(R.layout.tuiemoji_chat_menu_recent_face_item_layout, parent, false);
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
                        onEmojiClickedListener.onEmojiClicked(clickedEmoji);
                    }
                });
                dialogFragment.show(chatPopActivity.getSupportFragmentManager(), "ChatEmoji");
                return;
            }
            onEmojiClickedListener.onEmojiClicked(emoji);
            updateRecentEmoji(emoji);
            chatPopActivity.hide();
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

            int left = column * leftRightSpace / columnNum;
            int right = leftRightSpace * (columnNum - 1 - column) / columnNum;
            if (LayoutUtil.isRTL()) {
                outRect.left = right;
                outRect.right = left;
            } else {
                outRect.left = left;
                outRect.right = right;
            }

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
}
