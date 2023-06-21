package com.tencent.qcloud.tuikit.tuichat.classicui.widget.message.viewholder;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import androidx.recyclerview.widget.RecyclerView;
import com.tencent.qcloud.tuikit.timcommon.classicui.widget.message.MessageBaseHolder;
import com.tencent.qcloud.tuikit.timcommon.interfaces.ICommonMessageAdapter;
import com.tencent.qcloud.tuikit.tuichat.R;
import com.tencent.qcloud.tuikit.tuichat.classicui.ClassicUIService;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

public class MessageViewHolderFactory {
    public static RecyclerView.ViewHolder getInstance(ViewGroup parent, ICommonMessageAdapter adapter, int viewType) {
        LayoutInflater inflater = LayoutInflater.from(parent.getContext());
        RecyclerView.ViewHolder holder = null;
        View view = null;

        if (viewType == MessageBaseHolder.MSG_TYPE_HEADER_VIEW) {
            view = inflater.inflate(R.layout.chat_loading_progress_bar, parent, false);
            holder = new MessageHeaderHolder(view);
            return holder;
        }

        if (ClassicUIService.getInstance().isNeedEmptyViewGroup(viewType)) {
            view = inflater.inflate(R.layout.message_adapter_item_empty, parent, false);
            holder = getViewHolder(view, viewType);
        } else {
            view = inflater.inflate(com.tencent.qcloud.tuikit.timcommon.R.layout.message_adapter_item_content, parent, false);
            holder = getViewHolder(view, viewType);
        }

        if (holder == null) {
            holder = new TextMessageHolder(view);
        }
        ((MessageBaseHolder) holder).setAdapter(adapter);

        return holder;
    }

    private static RecyclerView.ViewHolder getViewHolder(View view, int viewType) {
        Class<? extends MessageBaseHolder> messageHolderClazz = ClassicUIService.getInstance().getMessageViewHolderClass(viewType);
        ;
        if (messageHolderClazz != null) {
            Constructor<? extends MessageBaseHolder> constructor;
            try {
                constructor = messageHolderClazz.getConstructor(View.class);
                return constructor.newInstance(view);
            } catch (NoSuchMethodException e) {
                e.printStackTrace();
            } catch (IllegalAccessException e) {
                e.printStackTrace();
            } catch (InstantiationException e) {
                e.printStackTrace();
            } catch (InvocationTargetException e) {
                e.printStackTrace();
            }
        }
        return null;
    }
}
