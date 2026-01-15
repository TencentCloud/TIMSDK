package com.tencent.qcloud.tuikit.tuiofficialaccountplugin.minimalistui

import android.content.Intent
import android.graphics.drawable.Drawable
import android.text.TextUtils
import android.view.View
import android.view.ViewGroup
import com.bumptech.glide.Glide
import com.bumptech.glide.load.DataSource
import com.bumptech.glide.load.engine.GlideException
import com.bumptech.glide.request.RequestListener
import com.bumptech.glide.request.target.Target
import com.tencent.qcloud.tuicore.util.ScreenUtil
import com.tencent.qcloud.tuikit.timcommon.bean.TUIMessageBean
import com.tencent.qcloud.tuikit.timcommon.component.RoundCornerImageView
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.MessageBaseHolder
import com.tencent.qcloud.tuikit.timcommon.minimalistui.widget.message.TimeInLineTextLayout
import com.tencent.qcloud.tuikit.timcommon.util.DateTimeUtil
import com.tencent.qcloud.tuikit.timcommon.util.TextUtil
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.R
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.bean.OfficialAccountMessageBean
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.component.ImagePreviewActivity
import com.tencent.qcloud.tuikit.tuiofficialaccountplugin.util.TUIOfficialAccountLog
import java.util.*

class OfficialAccountMessageHolder(itemView: View) : MessageBaseHolder(itemView) {

    companion object {
        private const val TAG = "OfficialAccountMessageHolder"
    }

    private val contentTextView: TimeInLineTextLayout = itemView.findViewById(R.id.tv_official_account_content)
    private val imageView: RoundCornerImageView = itemView.findViewById(R.id.iv_official_account_image)

    override fun getVariableLayout(): Int {
        return R.layout.official_account_message_adapter_content
    }

    override fun layoutViews(msg: TUIMessageBean?, position: Int) {
        if (msg !is OfficialAccountMessageBean) {
            TUIOfficialAccountLog.e(TAG, "layoutVariableViews: message is not OfficialAccountMessageBean")
            return
        }

        setupMessageBackground(msg)
        setupMessageContent(msg)
    }

    private fun setupMessageBackground(msg: OfficialAccountMessageBean) {
        val paddingHorizontal = ScreenUtil.dip2px(16.0f)
        val paddingVertical = ScreenUtil.dip2px(16.0f)
        itemView.setPaddingRelative(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical)
        chatTimeText.visibility = View.GONE
    }

    private fun setupMessageContent(msg: OfficialAccountMessageBean) {
        val officialMessage = msg.officialAccountMessage ?: return

        if (!TextUtils.isEmpty(officialMessage.content)) {
            val layoutParams = contentTextView.textView.layoutParams
            layoutParams.width = ViewGroup.LayoutParams.MATCH_PARENT
            contentTextView.textView.layoutParams = layoutParams
            contentTextView.setText(officialMessage.content)
            contentTextView.setTimeText(DateTimeUtil.getHMTimeString(Date(msg.messageTime * 1000)))
            contentTextView.textView.isActivated = true
            contentTextView.visibility = View.VISIBLE
        } else {
            contentTextView.visibility = View.GONE
            contentTextView.textView.isActivated = false
        }
        TextUtil.linkifyUrls(contentTextView.textView)

        val imageUrl = officialMessage.imageInfo?.url
        if (!TextUtils.isEmpty(imageUrl)) {
            imageView.visibility = View.VISIBLE
            imageView.setOnClickListener {
                previewImage(imageUrl)
            }

            val hasContent = !TextUtils.isEmpty(officialMessage.content)
            val cornerRadius = ScreenUtil.dip2px(16.0f)
            if (hasContent) {
                imageView.leftBottomRadius = 0
                imageView.rightBottomRadius = 0
            } else {
                imageView.leftBottomRadius = cornerRadius
                imageView.rightBottomRadius = cornerRadius
            }

            Glide.with(itemView.context)
                .load(imageUrl)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .listener(object : RequestListener<Drawable> {
                    override fun onLoadFailed(
                        e: GlideException?,
                        model: Any?,
                        target: Target<Drawable>?,
                        isFirstResource: Boolean
                    ): Boolean {
                        return false
                    }

                    override fun onResourceReady(
                        resource: Drawable,
                        model: Any?,
                        target: Target<Drawable>?,
                        dataSource: DataSource,
                        isFirstResource: Boolean
                    ): Boolean {
                        adjustImageHeight(resource.intrinsicWidth, resource.intrinsicHeight)
                        return false
                    }
                })
                .into(imageView)
        } else {
            imageView.visibility = View.GONE
            imageView.setOnClickListener(null)
        }
    }

    private fun previewImage(imageUrl: String?) {
        if (TextUtils.isEmpty(imageUrl)) {
            return
        }
        val intent = Intent(itemView.context, ImagePreviewActivity::class.java)
        intent.putExtra(ImagePreviewActivity.EXTRA_IMAGE_URL, imageUrl)
        itemView.context.startActivity(intent)
    }

    private fun adjustImageHeight(drawableWidth: Int, drawableHeight: Int) {
        if (drawableWidth <= 0 || drawableHeight <= 0) return

        val applyResize: () -> Unit = applyResize@{
            val parentWidth = (imageView.parent as? View)?.width ?: imageView.width
            if (parentWidth <= 0) {
                return@applyResize
            }

            val aspect = drawableHeight.toFloat() / drawableWidth.toFloat()
            val desired = (aspect * parentWidth).toInt()
            val minH = (0.5f * parentWidth).toInt()
            val maxH = (2.0f * parentWidth).toInt()
            val clamped = desired.coerceIn(minH, maxH)

            val lp = imageView.layoutParams
            lp.width = ViewGroup.LayoutParams.MATCH_PARENT
            lp.height = clamped
            imageView.layoutParams = lp
            imageView.requestLayout()
        }

        if (((imageView.parent as? View)?.width ?: 0) <= 0) {
            imageView.post { applyResize() }
        } else {
            applyResize()
        }
    }

}
