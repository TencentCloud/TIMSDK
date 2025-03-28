package com.tencent.cloud.tuikit.roomkit.view.main.speechtotext;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.tencent.cloud.tuikit.roomkit.R;
import com.tencent.cloud.tuikit.roomkit.state.ASRState;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

public class SpeechToTextViewAdapter extends RecyclerView.Adapter {
    private List<ASRState.SpeechToText> mTextList = new LinkedList<>();

    private final Context mContext;

    public SpeechToTextViewAdapter(Context context) {
        mContext = context;
    }

    public void setDataList(List<ASRState.SpeechToText> list) {
        mTextList = list;
    }

    @NonNull
    @Override
    public RecyclerView.ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(mContext).inflate(R.layout.tuiroomkit_view_speech_to_text_item, parent, false);
        return new TextViewHolder(view);
    }

    @Override
    public void onBindViewHolder(@NonNull RecyclerView.ViewHolder holder, int position) {
        ASRState.SpeechToText speechToText = mTextList.get(position);
        ((TextViewHolder) holder).bindData(speechToText);
    }

    @Override
    public int getItemCount() {
        return mTextList.size();
    }

    static class TextViewHolder extends RecyclerView.ViewHolder {
        private final TextView textTitle;
        private final TextView textContent;

        public TextViewHolder(View itemView) {
            super(itemView);
            textTitle = itemView.findViewById(R.id.tuiroomkit_speech_to_text_item_title);
            textContent = itemView.findViewById(R.id.tuiroomkit_speech_to_text_item_content);
        }

        public void bindData(ASRState.SpeechToText speechToText) {
            textTitle.setText(parseTitle(speechToText));
            textContent.setText(speechToText.text);
        }

        public static String parseTitle(ASRState.SpeechToText speechToText) {
            SimpleDateFormat sdf = new SimpleDateFormat("MM-dd HH:mm:ss", Locale.getDefault());
            Date date = new Date(speechToText.startTimeMs);
            return speechToText.userName + "  " + sdf.format(date);
        }
    }
}

