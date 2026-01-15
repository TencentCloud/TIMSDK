package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.widget.AppCompatButton
import androidx.appcompat.widget.AppCompatImageView
import androidx.appcompat.widget.AppCompatTextView
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.ListAdapter
import androidx.recyclerview.widget.RecyclerView
import com.bumptech.glide.Glide
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.R
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountInfo

class OfficialAccountListAdapter(
    private val onItemAction: (OfficialAccountInfo, String) -> Unit
) : ListAdapter<OfficialAccountSectionItem, RecyclerView.ViewHolder>(DiffCallback()) {

    companion object {
        const val ACTION_CLICK = "click"
        const val ACTION_FOLLOW = "follow"
        
        private const val TYPE_SECTION_HEADER = 1
        private const val TYPE_ACCOUNT_ITEM = 2
        private const val TYPE_RECOMMENDATION_ITEM = 3
    }

    override fun getItemViewType(position: Int): Int {
        return when (getItem(position)) {
            is OfficialAccountSectionItem.SectionHeader -> TYPE_SECTION_HEADER
            is OfficialAccountSectionItem.AccountItem -> TYPE_ACCOUNT_ITEM
            is OfficialAccountSectionItem.RecommendationItem -> TYPE_RECOMMENDATION_ITEM
        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val inflater = LayoutInflater.from(parent.context)
        return when (viewType) {
            TYPE_SECTION_HEADER -> {
                val view = inflater.inflate(R.layout.official_account_section_header, parent, false)
                SectionHeaderViewHolder(view)
            }
            TYPE_ACCOUNT_ITEM -> {
                val view = inflater.inflate(R.layout.official_account_item, parent, false)
                AccountItemViewHolder(view)
            }
            TYPE_RECOMMENDATION_ITEM -> {
                val view = inflater.inflate(R.layout.official_account_recommendation_item, parent, false)
                RecommendationItemViewHolder(view)
            }
            else -> throw IllegalArgumentException("Unknown view type: $viewType")
        }
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        when (val item = getItem(position)) {
            is OfficialAccountSectionItem.SectionHeader -> {
                (holder as SectionHeaderViewHolder).bind(item)
            }
            is OfficialAccountSectionItem.AccountItem -> {
                (holder as AccountItemViewHolder).bind(item)
            }
            is OfficialAccountSectionItem.RecommendationItem -> {
                (holder as RecommendationItemViewHolder).bind(item)
            }
        }
    }

    inner class SectionHeaderViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val titleText: AppCompatTextView = itemView.findViewById(R.id.tv_section_title)

        fun bind(item: OfficialAccountSectionItem.SectionHeader) {
            titleText.text = item.title
        }
    }

    inner class AccountItemViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val avatarImage: AppCompatImageView = itemView.findViewById(R.id.iv_avatar)
        private val nameText: AppCompatTextView = itemView.findViewById(R.id.tv_name)
        private val descriptionText: AppCompatTextView = itemView.findViewById(R.id.tv_description)

        fun bind(item: OfficialAccountSectionItem.AccountItem) {
            nameText.text = item.accountInfo.name
            
            descriptionText.text = if (!item.lastMessage.isNullOrEmpty()) {
                item.lastMessage
            } else {
                item.accountInfo.introduction
            }

            Glide.with(itemView.context)
                .load(item.accountInfo.faceUrl)
                .placeholder(R.drawable.official_account_default_avatar)
                .into(avatarImage)

            itemView.setOnClickListener {
                onItemAction(item.accountInfo, ACTION_CLICK)
            }
        }
    }

    inner class RecommendationItemViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val avatarImage: AppCompatImageView = itemView.findViewById(R.id.iv_avatar)
        private val nameText: AppCompatTextView = itemView.findViewById(R.id.tv_name)
        private val fansText: AppCompatTextView = itemView.findViewById(R.id.tv_fans)
        private val followButton: AppCompatButton = itemView.findViewById(R.id.btn_follow)

        fun bind(item: OfficialAccountSectionItem.RecommendationItem) {
            nameText.text = item.accountInfo.name
            fansText.text = formatFansCount(item.accountInfo.subscriberNum)

            Glide.with(itemView.context)
                .load(item.accountInfo.faceUrl)
                .placeholder(R.drawable.official_account_default_avatar)
                .into(avatarImage)

            itemView.setOnClickListener {
                onItemAction(item.accountInfo, ACTION_CLICK)
            }

            followButton.setOnClickListener {
                onItemAction(item.accountInfo, ACTION_FOLLOW)
            }
        }

        private fun formatFansCount(count: Long): String {
            return when {
                count >= 10000 -> "${count / 10000}w fans"
                count >= 1000 -> "${count / 1000}k fans"
                else -> "$count fans"
            }
        }
    }

    private class DiffCallback : DiffUtil.ItemCallback<OfficialAccountSectionItem>() {
        override fun areItemsTheSame(
            oldItem: OfficialAccountSectionItem,
            newItem: OfficialAccountSectionItem
        ): Boolean {
            return when {
                oldItem is OfficialAccountSectionItem.SectionHeader && newItem is OfficialAccountSectionItem.SectionHeader ->
                    oldItem.title == newItem.title
                oldItem is OfficialAccountSectionItem.AccountItem && newItem is OfficialAccountSectionItem.AccountItem ->
                    oldItem.accountInfo.officialAccount == newItem.accountInfo.officialAccount
                oldItem is OfficialAccountSectionItem.RecommendationItem && newItem is OfficialAccountSectionItem.RecommendationItem ->
                    oldItem.accountInfo.officialAccount == newItem.accountInfo.officialAccount
                else -> false
            }
        }

        override fun areContentsTheSame(
            oldItem: OfficialAccountSectionItem,
            newItem: OfficialAccountSectionItem
        ): Boolean {
            return oldItem == newItem
        }
    }
}
