package io.trtc.tuikit.atomicx.widget.utils

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.os.Build
import android.renderscript.Allocation
import android.renderscript.Element
import android.renderscript.RenderScript
import android.renderscript.ScriptIntrinsicBlur
import com.bumptech.glide.load.engine.bitmap_recycle.BitmapPool
import kotlin.math.abs
import kotlin.math.max
import kotlin.math.min

object BlurUtils {
    private const val SAMPLING = 10f

    @JvmStatic
    fun blur(context: Context, pool: BitmapPool, toTransform: Bitmap, radius: Int): Bitmap {
        val width = toTransform.width
        val height = toTransform.height
        val scaleWidth = (width / SAMPLING).toInt()
        val scaleHeight = (height / SAMPLING).toInt()

        val bitmap = pool.get(scaleWidth, scaleHeight, Bitmap.Config.ARGB_8888)
        bitmap.density = toTransform.density

        val canvas = Canvas(bitmap)
        canvas.scale(1 / SAMPLING, 1 / SAMPLING)
        val paint = Paint()
        paint.flags = Paint.FILTER_BITMAP_FLAG
        canvas.drawBitmap(toTransform, 0f, 0f, paint)

        var rs: RenderScript? = null
        var input: Allocation? = null
        var output: Allocation? = null
        var blur: ScriptIntrinsicBlur? = null

        try {
            rs = RenderScript.create(context)
            rs.messageHandler = RenderScript.RSMessageHandler()
            input = Allocation.createFromBitmap(
                rs, bitmap,
                Allocation.MipmapControl.MIPMAP_NONE,
                Allocation.USAGE_SCRIPT
            )
            output = Allocation.createTyped(rs, input.type)
            blur = ScriptIntrinsicBlur.create(rs, Element.U8_4(rs))
            blur.setRadius(radius.toFloat())
            blur.setInput(input)
            blur.forEach(output)
            output.copyTo(bitmap)
        } catch (e: Exception) {
            e.printStackTrace()
            fastBlur(bitmap, radius, true)
        } finally {
            rs?.let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    RenderScript.releaseAllContexts()
                } else {
                    @Suppress("DEPRECATION")
                    it.destroy()
                }
            }
            input?.destroy()
            output?.destroy()
            blur?.destroy()
        }

        return bitmap
    }

    @JvmStatic
    fun blur(context: Context, bitmap: Bitmap, radius: Int): Bitmap {
        var rs: RenderScript? = null
        var input: Allocation? = null
        var output: Allocation? = null
        var blur: ScriptIntrinsicBlur? = null

        try {
            rs = RenderScript.create(context)
            rs.messageHandler = RenderScript.RSMessageHandler()
            input = Allocation.createFromBitmap(
                rs, bitmap,
                Allocation.MipmapControl.MIPMAP_NONE,
                Allocation.USAGE_SCRIPT
            )
            output = Allocation.createTyped(rs, input.type)
            blur = ScriptIntrinsicBlur.create(rs, Element.U8_4(rs))
            blur.setRadius(radius.toFloat())
            blur.setInput(input)
            blur.forEach(output)
            output.copyTo(bitmap)
        } catch (e: Exception) {
            e.printStackTrace()
            fastBlur(bitmap, radius, true)
        } finally {
            rs?.let {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    RenderScript.releaseAllContexts()
                } else {
                    @Suppress("DEPRECATION")
                    it.destroy()
                }
            }
            input?.destroy()
            output?.destroy()
            blur?.destroy()
        }

        return bitmap
    }

    @JvmStatic
    fun fastBlur(sentBitmap: Bitmap, radius: Int, canReuseInBitmap: Boolean): Bitmap {
        val bitmap = if (canReuseInBitmap) {
            sentBitmap
        } else {
            sentBitmap.copy(sentBitmap.config!!, true)
        }

        if (radius < 1) {
            return sentBitmap
        }

        val w = bitmap.width
        val h = bitmap.height
        val pix = IntArray(w * h)
        bitmap.getPixels(pix, 0, w, 0, 0, w, h)

        val wm = w - 1
        val hm = h - 1
        val wh = w * h
        val div = radius + radius + 1

        val r = IntArray(wh)
        val g = IntArray(wh)
        val b = IntArray(wh)

        val vmin = IntArray(max(w, h))

        var divsum = (div + 1) shr 1
        divsum *= divsum
        val dv = IntArray(256 * divsum)
        for (i in 0 until 256 * divsum) {
            dv[i] = i / divsum
        }

        var yi = 0
        var yw = yi

        val stack = Array(div) { IntArray(3) }
        val r1 = radius + 1
        var routsum: Int
        var goutsum: Int
        var boutsum: Int
        var rinsum: Int
        var ginsum: Int
        var binsum: Int

        for (y in 0 until h) {
            var rsum = 0
            var gsum = 0
            var bsum = 0
            routsum = 0
            goutsum = 0
            boutsum = 0
            rinsum = 0
            ginsum = 0
            binsum = 0

            for (i in -radius..radius) {
                val p = pix[yi + min(wm, max(i, 0))]
                val sir = stack[i + radius]
                sir[0] = (p and 0xff0000) shr 16
                sir[1] = (p and 0x00ff00) shr 8
                sir[2] = p and 0x0000ff
                val rbs = r1 - abs(i)
                rsum += sir[0] * rbs
                gsum += sir[1] * rbs
                bsum += sir[2] * rbs
                if (i > 0) {
                    rinsum += sir[0]
                    ginsum += sir[1]
                    binsum += sir[2]
                } else {
                    routsum += sir[0]
                    goutsum += sir[1]
                    boutsum += sir[2]
                }
            }

            var stackpointer = radius
            var x = 0
            while (x < w) {
                r[yi] = dv[rsum]
                g[yi] = dv[gsum]
                b[yi] = dv[bsum]

                rsum -= routsum
                gsum -= goutsum
                bsum -= boutsum

                val stackstart = stackpointer - radius + div
                var sir = stack[stackstart % div]

                routsum -= sir[0]
                goutsum -= sir[1]
                boutsum -= sir[2]

                if (y == 0) {
                    vmin[x] = min(x + radius + 1, wm)
                }
                val p = pix[yw + vmin[x]]

                sir[0] = (p and 0xff0000) shr 16
                sir[1] = (p and 0x00ff00) shr 8
                sir[2] = p and 0x0000ff

                rinsum += sir[0]
                ginsum += sir[1]
                binsum += sir[2]

                rsum += rinsum
                gsum += ginsum
                bsum += binsum

                stackpointer = (stackpointer + 1) % div
                sir = stack[stackpointer % div]

                routsum += sir[0]
                goutsum += sir[1]
                boutsum += sir[2]

                rinsum -= sir[0]
                ginsum -= sir[1]
                binsum -= sir[2]

                yi++
                x++
            }
            yw += w
        }

        for (x in 0 until w) {
            var rsum = 0
            var gsum = 0
            var bsum = 0
            routsum = 0
            goutsum = 0
            boutsum = 0
            rinsum = 0
            ginsum = 0
            binsum = 0
            var yp = -radius * w

            for (i in -radius..radius) {
                yi = max(0, yp) + x
                val sir = stack[i + radius]
                sir[0] = r[yi]
                sir[1] = g[yi]
                sir[2] = b[yi]
                val rbs = r1 - abs(i)
                rsum += r[yi] * rbs
                gsum += g[yi] * rbs
                bsum += b[yi] * rbs
                if (i > 0) {
                    rinsum += sir[0]
                    ginsum += sir[1]
                    binsum += sir[2]
                } else {
                    routsum += sir[0]
                    goutsum += sir[1]
                    boutsum += sir[2]
                }
                if (i < hm) {
                    yp += w
                }
            }

            yi = x
            var stackpointer = radius
            for (y in 0 until h) {
                pix[yi] = (pix[yi] and -0x1000000.toInt()) or
                        (dv[rsum] shl 16) or
                        (dv[gsum] shl 8) or
                        dv[bsum]

                rsum -= routsum
                gsum -= goutsum
                bsum -= boutsum

                val stackstart = stackpointer - radius + div
                var sir = stack[stackstart % div]

                routsum -= sir[0]
                goutsum -= sir[1]
                boutsum -= sir[2]

                if (x == 0) {
                    vmin[y] = min(y + r1, hm) * w
                }
                val p = x + vmin[y]

                sir[0] = r[p]
                sir[1] = g[p]
                sir[2] = b[p]

                rinsum += sir[0]
                ginsum += sir[1]
                binsum += sir[2]

                rsum += rinsum
                gsum += ginsum
                bsum += binsum

                stackpointer = (stackpointer + 1) % div
                sir = stack[stackpointer]

                routsum += sir[0]
                goutsum += sir[1]
                boutsum += sir[2]

                rinsum -= sir[0]
                ginsum -= sir[1]
                binsum -= sir[2]

                yi += w
            }
        }

        bitmap.setPixels(pix, 0, w, 0, 0, w, h)
        return bitmap
    }
}
