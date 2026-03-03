package io.trtc.tuikit.atomicx.theme.tokens

import android.content.Context
import android.util.AttributeSet
import androidx.annotation.ColorInt
import androidx.core.content.ContextCompat
import io.trtc.tuikit.atomicx.R

data class ColorTokens(
    // text & icon
    @ColorInt val textColorPrimary: Int,
    @ColorInt val textColorSecondary: Int,
    @ColorInt val textColorTertiary: Int,
    @ColorInt val textColorDisable: Int,
    @ColorInt val textColorButton: Int,
    @ColorInt val textColorButtonDisabled: Int,
    @ColorInt val textColorLink: Int,
    @ColorInt val textColorLinkHover: Int,
    @ColorInt val textColorLinkActive: Int,
    @ColorInt val textColorLinkDisabled: Int,
    @ColorInt val textColorAntiPrimary: Int,
    @ColorInt val textColorAntiSecondary: Int,
    @ColorInt val textColorWarning: Int,
    @ColorInt val textColorSuccess: Int,
    @ColorInt val textColorError: Int,
    // background
    @ColorInt val bgColorTopBar: Int,
    @ColorInt val bgColorOperate: Int,
    @ColorInt val bgColorDialog: Int,
    @ColorInt val bgColorDialogModule: Int,
    @ColorInt val bgColorEntryCard: Int,
    @ColorInt val bgColorFunction: Int,
    @ColorInt val bgColorBottomBar: Int,
    @ColorInt val bgColorInput: Int,
    @ColorInt val bgColorBubbleReciprocal: Int,
    @ColorInt val bgColorBubbleOwn: Int,
    @ColorInt val bgColorDefault: Int,
    @ColorInt val bgColorTagMask: Int,
    @ColorInt val bgColorElementMask: Int,
    @ColorInt val bgColorMask: Int,
    @ColorInt val bgColorMaskDisappeared: Int,
    @ColorInt val bgColorMaskBegin: Int,
    @ColorInt val bgColorAvatar: Int,
    // border
    @ColorInt val strokeColorPrimary: Int,
    @ColorInt val strokeColorSecondary: Int,
    @ColorInt val strokeColorModule: Int,
    // shadow
    @ColorInt val shadowColor: Int,
    // status
    @ColorInt val listColorDefault: Int,
    @ColorInt val listColorHover: Int,
    @ColorInt val listColorFocused: Int,
    // button
    @ColorInt val buttonColorPrimaryDefault: Int,
    @ColorInt val buttonColorPrimaryHover: Int,
    @ColorInt val buttonColorPrimaryActive: Int,
    @ColorInt val buttonColorPrimaryDisabled: Int,
    @ColorInt val buttonColorSecondaryDefault: Int,
    @ColorInt val buttonColorSecondaryHover: Int,
    @ColorInt val buttonColorSecondaryActive: Int,
    @ColorInt val buttonColorSecondaryDisabled: Int,
    @ColorInt val buttonColorAccept: Int,
    @ColorInt val buttonColorHangupDefault: Int,
    @ColorInt val buttonColorHangupDisabled: Int,
    @ColorInt val buttonColorHangupHover: Int,
    @ColorInt val buttonColorHangupActive: Int,
    @ColorInt val buttonColorOn: Int,
    @ColorInt val buttonColorOff: Int,
    // dropdown
    @ColorInt val dropdownColorDefault: Int,
    @ColorInt val dropdownColorHover: Int,
    @ColorInt val dropdownColorActive: Int,
    // scrollbar
    @ColorInt val scrollbarColorDefault: Int,
    @ColorInt val scrollbarColorHover: Int,
    // floating
    @ColorInt val floatingColorDefault: Int,
    @ColorInt val floatingColorOperate: Int,
    // checkbox
    @ColorInt val checkboxColorSelected: Int,
    // toast
    @ColorInt val toastColorWarning: Int,
    @ColorInt val toastColorSuccess: Int,
    @ColorInt val toastColorError: Int,
    @ColorInt val toastColorDefault: Int,
    // tag
    @ColorInt val tagColorLevel1: Int,
    @ColorInt val tagColorLevel2: Int,
    @ColorInt val tagColorLevel3: Int,
    @ColorInt val tagColorLevel4: Int,
    // switch
    @ColorInt val switchColorOff: Int,
    @ColorInt val switchColorOn: Int,
    @ColorInt val switchColorButton: Int,
    // slider
    @ColorInt val sliderColorFilled: Int,
    @ColorInt val sliderColorEmpty: Int,
    @ColorInt val sliderColorButton: Int,
    // tab
    @ColorInt val tabColorSelected: Int,
    @ColorInt val tabColorUnselected: Int,
    @ColorInt val tabColorOption: Int,
) {
    operator fun get(key: String): Int {
        return when (key) {
            // --- Text & Icon ---
            "textColorPrimary" -> textColorPrimary
            "textColorSecondary" -> textColorSecondary
            "textColorTertiary" -> textColorTertiary
            "textColorDisable" -> textColorDisable
            "textColorButton" -> textColorButton
            "textColorButtonDisabled" -> textColorButtonDisabled
            "textColorLink" -> textColorLink
            "textColorLinkHover" -> textColorLinkHover
            "textColorLinkActive" -> textColorLinkActive
            "textColorLinkDisabled" -> textColorLinkDisabled
            "textColorAntiPrimary" -> textColorAntiPrimary
            "textColorAntiSecondary" -> textColorAntiSecondary
            "textColorWarning" -> textColorWarning
            "textColorSuccess" -> textColorSuccess
            "textColorError" -> textColorError

            // --- Background ---
            "bgColorTopBar" -> bgColorTopBar
            "bgColorOperate" -> bgColorOperate
            "bgColorDialog" -> bgColorDialog
            "bgColorDialogModule" -> bgColorDialogModule
            "bgColorEntryCard" -> bgColorEntryCard
            "bgColorFunction" -> bgColorFunction
            "bgColorBottomBar" -> bgColorBottomBar
            "bgColorInput" -> bgColorInput
            "bgColorBubbleReciprocal" -> bgColorBubbleReciprocal
            "bgColorBubbleOwn" -> bgColorBubbleOwn
            "bgColorDefault" -> bgColorDefault
            "bgColorTagMask" -> bgColorTagMask
            "bgColorElementMask" -> bgColorElementMask
            "bgColorMask" -> bgColorMask
            "bgColorMaskDisappeared" -> bgColorMaskDisappeared
            "bgColorMaskBegin" -> bgColorMaskBegin
            "bgColorAvatar" -> bgColorAvatar

            // --- Border ---
            "strokeColorPrimary" -> strokeColorPrimary
            "strokeColorSecondary" -> strokeColorSecondary
            "strokeColorModule" -> strokeColorModule

            // --- Shadow ---
            "shadowColor" -> shadowColor

            // --- Status ---
            "listColorDefault" -> listColorDefault
            "listColorHover" -> listColorHover
            "listColorFocused" -> listColorFocused

            // --- Button ---
            "buttonColorPrimaryDefault" -> buttonColorPrimaryDefault
            "buttonColorPrimaryHover" -> buttonColorPrimaryHover
            "buttonColorPrimaryActive" -> buttonColorPrimaryActive
            "buttonColorPrimaryDisabled" -> buttonColorPrimaryDisabled
            "buttonColorSecondaryDefault" -> buttonColorSecondaryDefault
            "buttonColorSecondaryHover" -> buttonColorSecondaryHover
            "buttonColorSecondaryActive" -> buttonColorSecondaryActive
            "buttonColorSecondaryDisabled" -> buttonColorSecondaryDisabled
            "buttonColorAccept" -> buttonColorAccept
            "buttonColorHangupDefault" -> buttonColorHangupDefault
            "buttonColorHangupDisabled" -> buttonColorHangupDisabled
            "buttonColorHangupHover" -> buttonColorHangupHover
            "buttonColorHangupActive" -> buttonColorHangupActive
            "buttonColorOn" -> buttonColorOn
            "buttonColorOff" -> buttonColorOff

            // --- Dropdown ---
            "dropdownColorDefault" -> dropdownColorDefault
            "dropdownColorHover" -> dropdownColorHover
            "dropdownColorActive" -> dropdownColorActive

            // --- Scrollbar ---
            "scrollbarColorDefault" -> scrollbarColorDefault
            "scrollbarColorHover" -> scrollbarColorHover

            // --- Floating ---
            "floatingColorDefault" -> floatingColorDefault
            "floatingColorOperate" -> floatingColorOperate

            // --- Checkbox ---
            "checkboxColorSelected" -> checkboxColorSelected

            // --- Toast ---
            "toastColorWarning" -> toastColorWarning
            "toastColorSuccess" -> toastColorSuccess
            "toastColorError" -> toastColorError
            "toastColorDefault" -> toastColorDefault

            // --- Tag ---
            "tagColorLevel1" -> tagColorLevel1
            "tagColorLevel2" -> tagColorLevel2
            "tagColorLevel3" -> tagColorLevel3
            "tagColorLevel4" -> tagColorLevel4

            // --- Switch ---
            "switchColorOff" -> switchColorOff
            "switchColorOn" -> switchColorOn
            "switchColorButton" -> switchColorButton

            // --- Slider ---
            "sliderColorFilled" -> sliderColorFilled
            "sliderColorEmpty" -> sliderColorEmpty
            "sliderColorButton" -> sliderColorButton

            // --- Tab ---
            "tabColorSelected" -> tabColorSelected
            "tabColorUnselected" -> tabColorUnselected
            "tabColorOption" -> tabColorOption

            else -> android.graphics.Color.TRANSPARENT
        }
    }

    companion object {

        fun defaultLight(context: Context): ColorTokens {
            return ColorTokens(
                // text & icon
                textColorPrimary = ContextCompat.getColor(context, R.color.black_2),
                textColorSecondary = ContextCompat.getColor(context, R.color.black_4),
                textColorTertiary = ContextCompat.getColor(context, R.color.black_5),
                textColorDisable = ContextCompat.getColor(context, R.color.black_6),
                textColorButton = ContextCompat.getColor(context, R.color.white_1),
                textColorButtonDisabled = ContextCompat.getColor(context, R.color.white_1),
                textColorLink = ContextCompat.getColor(context, R.color.theme_light_6),
                textColorLinkHover = ContextCompat.getColor(context, R.color.theme_light_5),
                textColorLinkActive = ContextCompat.getColor(context, R.color.theme_light_7),
                textColorLinkDisabled = ContextCompat.getColor(context, R.color.theme_light_2),
                textColorAntiPrimary = ContextCompat.getColor(context, R.color.black_2),
                textColorAntiSecondary = ContextCompat.getColor(context, R.color.black_4),
                textColorWarning = ContextCompat.getColor(context, R.color.orange_light_6),
                textColorSuccess = ContextCompat.getColor(context, R.color.green_light_6),
                textColorError = ContextCompat.getColor(context, R.color.red_light_6),
                // background
                bgColorTopBar = ContextCompat.getColor(context, R.color.gray_light_1),
                bgColorOperate = ContextCompat.getColor(context, R.color.white_1),
                bgColorDialog = ContextCompat.getColor(context, R.color.white_1),
                bgColorDialogModule = ContextCompat.getColor(context, R.color.gray_light_2),
                bgColorEntryCard = ContextCompat.getColor(context, R.color.gray_light_2),
                bgColorFunction = ContextCompat.getColor(context, R.color.gray_light_2),
                bgColorBottomBar = ContextCompat.getColor(context, R.color.white_1),
                bgColorInput = ContextCompat.getColor(context, R.color.gray_light_2),
                bgColorBubbleReciprocal = ContextCompat.getColor(context, R.color.gray_light_2),
                bgColorBubbleOwn = ContextCompat.getColor(context, R.color.theme_light_2),
                bgColorDefault = ContextCompat.getColor(context, R.color.gray_light_2),
                bgColorTagMask = ContextCompat.getColor(context, R.color.white_4),
                bgColorElementMask = ContextCompat.getColor(context, R.color.black_6),
                bgColorMask = ContextCompat.getColor(context, R.color.black_4),
                bgColorMaskDisappeared = ContextCompat.getColor(context, R.color.white_7),
                bgColorMaskBegin = ContextCompat.getColor(context, R.color.white_1),
                bgColorAvatar = ContextCompat.getColor(context, R.color.theme_light_2),
                // border
                strokeColorPrimary = ContextCompat.getColor(context, R.color.gray_light_3),
                strokeColorSecondary = ContextCompat.getColor(context, R.color.gray_light_2),
                strokeColorModule = ContextCompat.getColor(context, R.color.gray_light_3),
                // shadow
                shadowColor = ContextCompat.getColor(context, R.color.black_8),
                // status
                listColorDefault = ContextCompat.getColor(context, R.color.white_1),
                listColorHover = ContextCompat.getColor(context, R.color.gray_light_1),
                listColorFocused = ContextCompat.getColor(context, R.color.theme_light_1),
                // button
                buttonColorPrimaryDefault = ContextCompat.getColor(context, R.color.theme_light_6),
                buttonColorPrimaryHover = ContextCompat.getColor(context, R.color.theme_light_5),
                buttonColorPrimaryActive = ContextCompat.getColor(context, R.color.theme_light_7),
                buttonColorPrimaryDisabled = ContextCompat.getColor(context, R.color.theme_light_2),
                buttonColorSecondaryDefault = ContextCompat.getColor(context, R.color.gray_light_2),
                buttonColorSecondaryHover = ContextCompat.getColor(context, R.color.gray_light_1),
                buttonColorSecondaryActive = ContextCompat.getColor(context, R.color.gray_light_3),
                buttonColorSecondaryDisabled = ContextCompat.getColor(
                    context,
                    R.color.gray_light_1
                ),
                buttonColorAccept = ContextCompat.getColor(context, R.color.green_light_6),
                buttonColorHangupDefault = ContextCompat.getColor(context, R.color.red_light_6),
                buttonColorHangupDisabled = ContextCompat.getColor(context, R.color.red_light_2),
                buttonColorHangupHover = ContextCompat.getColor(context, R.color.red_light_5),
                buttonColorHangupActive = ContextCompat.getColor(context, R.color.red_light_7),
                buttonColorOn = ContextCompat.getColor(context, R.color.white_1),
                buttonColorOff = ContextCompat.getColor(context, R.color.black_5),
                // dropdown
                dropdownColorDefault = ContextCompat.getColor(context, R.color.white_1),
                dropdownColorHover = ContextCompat.getColor(context, R.color.gray_light_1),
                dropdownColorActive = ContextCompat.getColor(context, R.color.theme_light_1),
                // scrollbar
                scrollbarColorDefault = ContextCompat.getColor(context, R.color.black_7),
                scrollbarColorHover = ContextCompat.getColor(context, R.color.black_6),
                // floating
                floatingColorDefault = ContextCompat.getColor(context, R.color.white_1),
                floatingColorOperate = ContextCompat.getColor(context, R.color.gray_light_2),
                // checkbox
                checkboxColorSelected = ContextCompat.getColor(context, R.color.theme_light_6),
                // toast
                toastColorWarning = ContextCompat.getColor(context, R.color.orange_light_1),
                toastColorSuccess = ContextCompat.getColor(context, R.color.green_light_1),
                toastColorError = ContextCompat.getColor(context, R.color.red_light_1),
                toastColorDefault = ContextCompat.getColor(context, R.color.theme_light_1),
                // tag
                tagColorLevel1 = ContextCompat.getColor(context, R.color.accent_turquoise_light),
                tagColorLevel2 = ContextCompat.getColor(context, R.color.theme_light_5),
                tagColorLevel3 = ContextCompat.getColor(context, R.color.accent_purple_light),
                tagColorLevel4 = ContextCompat.getColor(context, R.color.accent_magenta_light),
                // switch
                switchColorOff = ContextCompat.getColor(context, R.color.gray_light_4),
                switchColorOn = ContextCompat.getColor(context, R.color.theme_light_6),
                switchColorButton = ContextCompat.getColor(context, R.color.white_1),
                // slider
                sliderColorFilled = ContextCompat.getColor(context, R.color.theme_light_6),
                sliderColorEmpty = ContextCompat.getColor(context, R.color.gray_light_3),
                sliderColorButton = ContextCompat.getColor(context, R.color.white_1),
                // tab
                tabColorSelected = ContextCompat.getColor(context, R.color.theme_light_2),
                tabColorUnselected = ContextCompat.getColor(context, R.color.gray_light_2),
                tabColorOption = ContextCompat.getColor(context, R.color.gray_light_3)
            )
        }

        fun defaultDark(context: Context): ColorTokens {
            return ColorTokens(
                // text & icon
                textColorPrimary = ContextCompat.getColor(context, R.color.text_color_primary),
                textColorSecondary = ContextCompat.getColor(context, R.color.text_color_secondary),
                textColorTertiary = ContextCompat.getColor(context, R.color.text_color_tertiary),
                textColorDisable = ContextCompat.getColor(context, R.color.text_color_disable),
                textColorButton = ContextCompat.getColor(context, R.color.text_color_button),
                textColorButtonDisabled = ContextCompat.getColor(
                    context,
                    R.color.text_color_button_disabled
                ),
                textColorLink = ContextCompat.getColor(context, R.color.text_color_link),
                textColorLinkHover = ContextCompat.getColor(context, R.color.text_color_link_hover),
                textColorLinkActive = ContextCompat.getColor(
                    context,
                    R.color.text_color_link_active
                ),
                textColorLinkDisabled = ContextCompat.getColor(
                    context,
                    R.color.text_color_link_disabled
                ),
                textColorAntiPrimary = ContextCompat.getColor(
                    context,
                    R.color.text_color_anti_primary
                ),
                textColorAntiSecondary = ContextCompat.getColor(
                    context,
                    R.color.text_color_anti_secondary
                ),
                textColorWarning = ContextCompat.getColor(context, R.color.text_color_warning),
                textColorSuccess = ContextCompat.getColor(context, R.color.text_color_success),
                textColorError = ContextCompat.getColor(context, R.color.text_color_error),
                // background
                bgColorTopBar = ContextCompat.getColor(context, R.color.bg_color_top_bar),
                bgColorOperate = ContextCompat.getColor(context, R.color.bg_color_operate),
                bgColorDialog = ContextCompat.getColor(context, R.color.bg_color_dialog),
                bgColorDialogModule = ContextCompat.getColor(
                    context,
                    R.color.bg_color_dialog_module
                ),
                bgColorEntryCard = ContextCompat.getColor(context, R.color.bg_color_entry_card),
                bgColorFunction = ContextCompat.getColor(context, R.color.bg_color_function),
                bgColorBottomBar = ContextCompat.getColor(context, R.color.bg_color_bottom_bar),
                bgColorInput = ContextCompat.getColor(context, R.color.bg_color_input),
                bgColorBubbleReciprocal = ContextCompat.getColor(
                    context,
                    R.color.bg_color_bubble_reciprocal
                ),
                bgColorBubbleOwn = ContextCompat.getColor(context, R.color.bg_color_bubble_own),
                bgColorDefault = ContextCompat.getColor(context, R.color.bg_color_default),
                bgColorTagMask = ContextCompat.getColor(context, R.color.bg_color_tag_mask),
                bgColorElementMask = ContextCompat.getColor(context, R.color.bg_color_element_mask),
                bgColorMask = ContextCompat.getColor(context, R.color.bg_color_mask),
                bgColorMaskDisappeared = ContextCompat.getColor(
                    context,
                    R.color.bg_color_mask_disappeared
                ),
                bgColorMaskBegin = ContextCompat.getColor(context, R.color.bg_color_mask_begin),
                bgColorAvatar = ContextCompat.getColor(context, R.color.bg_color_avatar),
                // border
                strokeColorPrimary = ContextCompat.getColor(context, R.color.stroke_color_primary),
                strokeColorSecondary = ContextCompat.getColor(
                    context,
                    R.color.stroke_color_secondary
                ),
                strokeColorModule = ContextCompat.getColor(context, R.color.stroke_color_module),
                // shadow
                shadowColor = ContextCompat.getColor(context, R.color.shadow_color),
                // status
                listColorDefault = ContextCompat.getColor(context, R.color.list_color_default),
                listColorHover = ContextCompat.getColor(context, R.color.list_color_hover),
                listColorFocused = ContextCompat.getColor(context, R.color.list_color_focused),
                // button
                buttonColorPrimaryDefault = ContextCompat.getColor(
                    context,
                    R.color.button_color_primary_default
                ),
                buttonColorPrimaryHover = ContextCompat.getColor(
                    context,
                    R.color.button_color_primary_hover
                ),
                buttonColorPrimaryActive = ContextCompat.getColor(
                    context,
                    R.color.button_color_primary_active
                ),
                buttonColorPrimaryDisabled = ContextCompat.getColor(
                    context,
                    R.color.button_color_primary_disabled
                ),
                buttonColorSecondaryDefault = ContextCompat.getColor(
                    context,
                    R.color.button_color_secondary_default
                ),
                buttonColorSecondaryHover = ContextCompat.getColor(
                    context,
                    R.color.button_color_secondary_hover
                ),
                buttonColorSecondaryActive = ContextCompat.getColor(
                    context,
                    R.color.button_color_secondary_active
                ),
                buttonColorSecondaryDisabled = ContextCompat.getColor(
                    context,
                    R.color.button_color_secondary_disabled
                ),
                buttonColorAccept = ContextCompat.getColor(context, R.color.button_color_accept),
                buttonColorHangupDefault = ContextCompat.getColor(
                    context,
                    R.color.button_color_hangup_default
                ),
                buttonColorHangupDisabled = ContextCompat.getColor(
                    context,
                    R.color.button_color_hangup_disabled
                ),
                buttonColorHangupHover = ContextCompat.getColor(
                    context,
                    R.color.button_color_hangup_hover
                ),
                buttonColorHangupActive = ContextCompat.getColor(
                    context,
                    R.color.button_color_hangup_active
                ),
                buttonColorOn = ContextCompat.getColor(context, R.color.button_color_on),
                buttonColorOff = ContextCompat.getColor(context, R.color.button_color_off),
                // dropdown
                dropdownColorDefault = ContextCompat.getColor(
                    context,
                    R.color.dropdown_color_default
                ),
                dropdownColorHover = ContextCompat.getColor(context, R.color.dropdown_color_hover),
                dropdownColorActive = ContextCompat.getColor(
                    context,
                    R.color.dropdown_color_active
                ),
                // scrollbar
                scrollbarColorDefault = ContextCompat.getColor(
                    context,
                    R.color.scrollbar_color_default
                ),
                scrollbarColorHover = ContextCompat.getColor(
                    context,
                    R.color.scrollbar_color_hover
                ),
                // floating
                floatingColorDefault = ContextCompat.getColor(
                    context,
                    R.color.floating_color_default
                ),
                floatingColorOperate = ContextCompat.getColor(
                    context,
                    R.color.floating_color_operate
                ),
                // checkbox
                checkboxColorSelected = ContextCompat.getColor(
                    context,
                    R.color.checkbox_color_selected
                ),
                // toast
                toastColorWarning = ContextCompat.getColor(context, R.color.toast_color_warning),
                toastColorSuccess = ContextCompat.getColor(context, R.color.toast_color_success),
                toastColorError = ContextCompat.getColor(context, R.color.toast_color_error),
                toastColorDefault = ContextCompat.getColor(context, R.color.toast_color_default),
                // tag
                tagColorLevel1 = ContextCompat.getColor(context, R.color.tag_color_level1),
                tagColorLevel2 = ContextCompat.getColor(context, R.color.tag_color_level2),
                tagColorLevel3 = ContextCompat.getColor(context, R.color.tag_color_level3),
                tagColorLevel4 = ContextCompat.getColor(context, R.color.tag_color_level4),
                // switch
                switchColorOff = ContextCompat.getColor(context, R.color.switch_color_off),
                switchColorOn = ContextCompat.getColor(context, R.color.switch_color_on),
                switchColorButton = ContextCompat.getColor(context, R.color.switch_color_button),
                // slider
                sliderColorFilled = ContextCompat.getColor(context, R.color.slider_color_filled),
                sliderColorEmpty = ContextCompat.getColor(context, R.color.slider_color_empty),
                sliderColorButton = ContextCompat.getColor(context, R.color.slider_color_button),
                // tab
                tabColorSelected = ContextCompat.getColor(context, R.color.tab_color_selected),
                tabColorUnselected = ContextCompat.getColor(context, R.color.tab_color_unselected),
                tabColorOption = ContextCompat.getColor(context, R.color.tab_color_option)
            )
        }

        fun generateLightTokens(context: Context, palette: List<Int>): ColorTokens {
            val themeLight1 = palette[0]
            val themeLight2 = palette[1]
            val themeLight5 = palette[4]
            val themeLight6 = palette[5]
            val themeLight7 = palette[6]

            return defaultLight(context).copy(
                textColorLink = themeLight6,
                textColorLinkHover = themeLight5,
                textColorLinkActive = themeLight7,
                textColorLinkDisabled = themeLight2,
                bgColorBubbleOwn = themeLight2,
                bgColorAvatar = themeLight2,
                listColorFocused = themeLight1,
                buttonColorPrimaryDefault = themeLight6,
                buttonColorPrimaryHover = themeLight5,
                buttonColorPrimaryActive = themeLight7,
                buttonColorPrimaryDisabled = themeLight2,
                dropdownColorActive = themeLight1,
                checkboxColorSelected = themeLight6,
                toastColorDefault = themeLight1,
                tagColorLevel2 = themeLight5,
                switchColorOn = themeLight6,
                sliderColorFilled = themeLight6,
                tabColorSelected = themeLight2
            )
        }

        fun generateDarkTokens(context: Context, palette: List<Int>): ColorTokens {
            val themeDark2 = palette[1]
            val themeDark5 = palette[4]
            val themeDark6 = palette[5]
            val themeDark7 = palette[6]

            return defaultDark(context).copy(
                textColorLink = themeDark6,
                textColorLinkHover = themeDark5,
                textColorLinkActive = themeDark7,
                textColorLinkDisabled = themeDark2,
                bgColorBubbleOwn = themeDark7,
                bgColorAvatar = themeDark2,
                listColorFocused = themeDark2,
                buttonColorPrimaryDefault = themeDark6,
                buttonColorPrimaryHover = themeDark5,
                buttonColorPrimaryActive = themeDark7,
                buttonColorPrimaryDisabled = themeDark2,
                dropdownColorActive = themeDark2,
                checkboxColorSelected = themeDark5,
                toastColorDefault = themeDark2,
                tagColorLevel2 = themeDark5,
                switchColorOn = themeDark5,
                sliderColorFilled = themeDark5,
                tabColorSelected = themeDark5
            )
        }

        private val tokenNameToResIdMap = mapOf(
            "textColorPrimary" to R.color.text_color_primary,
            "textColorSecondary" to R.color.text_color_secondary,
            "textColorTertiary" to R.color.text_color_tertiary,
            "textColorDisable" to R.color.text_color_disable,
            "textColorButton" to R.color.text_color_button,
            "textColorButtonDisabled" to R.color.text_color_button_disabled,
            "textColorLink" to R.color.text_color_link,
            "textColorLinkHover" to R.color.text_color_link_hover,
            "textColorLinkActive" to R.color.text_color_link_active,
            "textColorLinkDisabled" to R.color.text_color_link_disabled,
            "textColorAntiPrimary" to R.color.text_color_anti_primary,
            "textColorAntiSecondary" to R.color.text_color_anti_secondary,
            "textColorWarning" to R.color.text_color_warning,
            "textColorSuccess" to R.color.text_color_success,
            "textColorError" to R.color.text_color_error,
            "bgColorTopBar" to R.color.bg_color_top_bar,
            "bgColorOperate" to R.color.bg_color_operate,
            "bgColorDialog" to R.color.bg_color_dialog,
            "bgColorDialogModule" to R.color.bg_color_dialog_module,
            "bgColorEntryCard" to R.color.bg_color_entry_card,
            "bgColorFunction" to R.color.bg_color_function,
            "bgColorBottomBar" to R.color.bg_color_bottom_bar,
            "bgColorInput" to R.color.bg_color_input,
            "bgColorBubbleReciprocal" to R.color.bg_color_bubble_reciprocal,
            "bgColorBubbleOwn" to R.color.bg_color_bubble_own,
            "bgColorDefault" to R.color.bg_color_default,
            "bgColorTagMask" to R.color.bg_color_tag_mask,
            "bgColorElementMask" to R.color.bg_color_element_mask,
            "bgColorMask" to R.color.bg_color_mask,
            "bgColorMaskDisappeared" to R.color.bg_color_mask_disappeared,
            "bgColorMaskBegin" to R.color.bg_color_mask_begin,
            "bgColorAvatar" to R.color.bg_color_avatar,
            "strokeColorPrimary" to R.color.stroke_color_primary,
            "strokeColorSecondary" to R.color.stroke_color_secondary,
            "strokeColorModule" to R.color.stroke_color_module,
            "shadowColor" to R.color.shadow_color,
            "listColorDefault" to R.color.list_color_default,
            "listColorHover" to R.color.list_color_hover,
            "listColorFocused" to R.color.list_color_focused,
            "buttonColorPrimaryDefault" to R.color.button_color_primary_default,
            "buttonColorPrimaryHover" to R.color.button_color_primary_hover,
            "buttonColorPrimaryActive" to R.color.button_color_primary_active,
            "buttonColorPrimaryDisabled" to R.color.button_color_primary_disabled,
            "buttonColorSecondaryDefault" to R.color.button_color_secondary_default,
            "buttonColorSecondaryHover" to R.color.button_color_secondary_hover,
            "buttonColorSecondaryActive" to R.color.button_color_secondary_active,
            "buttonColorSecondaryDisabled" to R.color.button_color_secondary_disabled,
            "buttonColorAccept" to R.color.button_color_accept,
            "buttonColorHangupDefault" to R.color.button_color_hangup_default,
            "buttonColorHangupDisabled" to R.color.button_color_hangup_disabled,
            "buttonColorHangupHover" to R.color.button_color_hangup_hover,
            "buttonColorHangupActive" to R.color.button_color_hangup_active,
            "buttonColorOn" to R.color.button_color_on,
            "buttonColorOff" to R.color.button_color_off,
            "dropdownColorDefault" to R.color.dropdown_color_default,
            "dropdownColorHover" to R.color.dropdown_color_hover,
            "dropdownColorActive" to R.color.dropdown_color_active,
            "scrollbarColorDefault" to R.color.scrollbar_color_default,
            "scrollbarColorHover" to R.color.scrollbar_color_hover,
            "floatingColorDefault" to R.color.floating_color_default,
            "floatingColorOperate" to R.color.floating_color_operate,
            "checkboxColorSelected" to R.color.checkbox_color_selected,
            "toastColorWarning" to R.color.toast_color_warning,
            "toastColorSuccess" to R.color.toast_color_success,
            "toastColorError" to R.color.toast_color_error,
            "toastColorDefault" to R.color.toast_color_default,
            "tagColorLevel1" to R.color.tag_color_level1,
            "tagColorLevel2" to R.color.tag_color_level2,
            "tagColorLevel3" to R.color.tag_color_level3,
            "tagColorLevel4" to R.color.tag_color_level4,
            "switchColorOff" to R.color.switch_color_off,
            "switchColorOn" to R.color.switch_color_on,
            "switchColorButton" to R.color.switch_color_button,
            "sliderColorFilled" to R.color.slider_color_filled,
            "sliderColorEmpty" to R.color.slider_color_empty,
            "sliderColorButton" to R.color.slider_color_button,
            "tabColorSelected" to R.color.tab_color_selected,
            "tabColorUnselected" to R.color.tab_color_unselected,
            "tabColorOption" to R.color.tab_color_option
        )

        private val resIdToTokenNameMap by lazy {
            tokenNameToResIdMap.entries.associate { it.value to it.key }
        }

        fun getTokenKeyFromColorResId(colorResId: Int): String? {
            return resIdToTokenNameMap[colorResId]
        }

        fun parseColorAttribute(
            attrs: AttributeSet?,
            attrId: Int,
            attrName: String,
        ): String? {
            if (attrs == null) return null

            for (i in 0 until attrs.attributeCount) {
                if (attrs.getAttributeNameResource(i) == attrId) {
                    val resourceId = attrs.getAttributeResourceValue(i, -1)
                    if (resourceId != -1) {
                        return try {
                            getTokenKeyFromColorResId(resourceId)
                        } catch (e: Exception) {
                            android.util.Log.e("ColorTokens", "Error parsing $attrName", e)
                            null
                        }
                    }
                    break
                }
            }
            return null
        }
    }
}