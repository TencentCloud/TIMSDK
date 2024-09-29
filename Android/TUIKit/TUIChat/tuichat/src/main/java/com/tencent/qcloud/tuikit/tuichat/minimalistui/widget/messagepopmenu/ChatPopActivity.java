package com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.messagepopmenu;

import android.content.Intent;
import android.graphics.Bitmap;
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
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.res.ResourcesCompat;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuicore.TUIConstants;
import com.tencent.qcloud.tuicore.TUICore;
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean;
import com.tencent.qcloud.tuikit.timcommon.bean.UserBean;
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView;
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageContentHolder;
import com.tencent.qcloud.tuikit.timcommon.util.ScreenUtil;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.TUIChatConstants;
import com.tencent.qcloud.tuikit.tuichat.TUIChatService;
import com.tencent.qcloud.tuikit.tuichat.config.minimalistui.TUIChatConfigMinimalist;
import com.tencent.qcloud.tuikit.tuichat.interfaces.C2CChatEventListener;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.MinimalistUIService;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.ImageMessageHolder;
import com.tencent.qcloud.tuikit.tuichat.minimalistui.widget.message.viewholder.MessageViewHolderFactory;
import com.tencent.qcloud.tuikit.tuichat.util.BlurUtils;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ChatPopActivity extends AppCompatActivity {
    private static final String TAG = ChatPopActivity.class.getSimpleName();

    private static final int ACTION_MAX_NUM_PER_PAGE = 4;

    private List<ChatPopMenuAction> chatPopMenuActionList;

    private ChatPopMenuAction clickedChatPopMenuAction = null;

    private ViewGroup popupView;
    private View actionArea;
    private RecyclerView actionRecyclerView;

    private MenuActionAdapter menuActionAdapter;

    private FrameLayout messageArea;
    private FrameLayout reactionArea;
    private RelativeLayout dialogContainer;
    private ScrollView scrollMessageContainer;
    private View moreBtn;
    TUIMessageBean messageBean;
    private C2CChatEventListener chatEventListener;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.chat_minimalist_pop_menu_layout);
        popupView = findViewById(android.R.id.content);
        dialogContainer = popupView.findViewById(R.id.dialog_content_layout);
        moreBtn = popupView.findViewById(R.id.more_btn);
        actionArea = popupView.findViewById(R.id.action_area);
        actionRecyclerView = popupView.findViewById(R.id.chat_pop_menu_action_view);
        reactionArea = popupView.findViewById(R.id.reaction_area);
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
        messageArea = findViewById(R.id.message_frame);
        setLocation();
        init();

        chatEventListener = new C2CChatEventListener() {
            @Override
            public void onRecvMessageRevoked(String msgID, UserBean userBean, String reason) {
                if (messageBean != null && TextUtils.equals(msgID, messageBean.getId())) {
                    hide();
                }
            }
        };
        TUIChatService.getInstance().addC2CChatEventListener(chatEventListener);
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

        if (messageRect.top - emojiHeight >= statusBarHeight && messageRect.bottom + actionAreaHeight <= screenHeight) {
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
            int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
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
        messageBean = (TUIMessageBean) intent.getSerializableExtra(TUIChatConstants.MESSAGE_BEAN);
        int type = MinimalistUIService.getInstance().getViewType(messageBean.getClass());
        RecyclerView.ViewHolder holder = MessageViewHolderFactory.getInstance(messageArea, null, type);
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
            ((MessageContentHolder) holder).setMessageBubbleBackground(ChatPopDataHolder.getMsgAreaBackground());
        }
        if (messageBean.isSelf()) {
            RelativeLayout.LayoutParams faceViewLayoutParams = (RelativeLayout.LayoutParams) reactionArea.getLayoutParams();
            faceViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            faceViewLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_START);
            reactionArea.setLayoutParams(faceViewLayoutParams);
            RelativeLayout.LayoutParams messageContainerLayoutParams = (RelativeLayout.LayoutParams) scrollMessageContainer.getLayoutParams();
            messageContainerLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            messageContainerLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_START);
            scrollMessageContainer.setLayoutParams(messageContainerLayoutParams);
            RelativeLayout.LayoutParams actionAreaLayoutParams = (RelativeLayout.LayoutParams) actionArea.getLayoutParams();
            actionAreaLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_END);
            actionAreaLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_START);
            actionArea.setLayoutParams(actionAreaLayoutParams);
        } else {
            RelativeLayout.LayoutParams faceViewLayoutParams = (RelativeLayout.LayoutParams) reactionArea.getLayoutParams();
            faceViewLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_START);
            faceViewLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_END);
            reactionArea.setLayoutParams(faceViewLayoutParams);
            RelativeLayout.LayoutParams messageContainerLayoutParams = (RelativeLayout.LayoutParams) scrollMessageContainer.getLayoutParams();
            messageContainerLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_START);
            messageContainerLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_END);
            scrollMessageContainer.setLayoutParams(messageContainerLayoutParams);
            RelativeLayout.LayoutParams actionAreaLayoutParams = (RelativeLayout.LayoutParams) actionArea.getLayoutParams();
            actionAreaLayoutParams.addRule(RelativeLayout.ALIGN_PARENT_START);
            actionAreaLayoutParams.removeRule(RelativeLayout.ALIGN_PARENT_END);
            actionArea.setLayoutParams(actionAreaLayoutParams);
        }
        messageArea.addView(holder.itemView);
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
        // actions
        actionRecyclerView.setLayoutManager(new LinearLayoutManager(this));
        menuActionAdapter = new MenuActionAdapter();
        actionRecyclerView.setAdapter(menuActionAdapter);

        // raise reaction area
        Map<String, Object> param = new HashMap<>();
        param.put(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.CHAT_POP_MENU, this);
        TUICore.raiseExtension(TUIConstants.TUIChat.Extension.MessagePopMenuTopAreaExtension.EXTENSION_ID, null, param);
    }

    public void hide() {
        if (isFinishing() || isDestroyed()) {
            return;
        }
        onBackPressed();
    }

    public TUIMessageBean getMessageBean() {
        return messageBean;
    }

    public FrameLayout getReactionArea() {
        return reactionArea;
    }

    public boolean isShowFaces() {
        return TUIChatConfigMinimalist.isEnableEmojiReaction();
    }

    private ChatPopMenuAction getChatPopMenuAction(int position) {
        return chatPopMenuActionList.get(position);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (clickedChatPopMenuAction != null) {
            clickedChatPopMenuAction.actionClickListener.onClick();
        }
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
                    clickedChatPopMenuAction = chatPopMenuAction;
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

    public static class ChatPopMenuAction {
        private String actionName;

        private int textColor = Integer.MAX_VALUE;

        private int actionIcon;

        private int priority;
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

        public int getPriority() {
            return priority;
        }

        public void setPriority(int priority) {
            this.priority = priority;
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
