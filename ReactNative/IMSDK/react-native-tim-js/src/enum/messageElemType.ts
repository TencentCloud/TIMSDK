/**
 * @module enum
 */
export enum MessageElemType {
    /**
     * 没有元素
     */
    V2TIM_ELEM_TYPE_NONE = 0,
    /**
     * 文本消息
     */
    V2TIM_ELEM_TYPE_TEXT = 1,

    /**
     * 自定义消息
     */
    V2TIM_ELEM_TYPE_CUSTOM = 2,

    /**
     * 图片消息
     */
    V2TIM_ELEM_TYPE_IMAGE = 3,

    /**
     * 语音消息
     */
    V2TIM_ELEM_TYPE_SOUND = 4,

    /**
     * 视频消息
     */
    V2TIM_ELEM_TYPE_VIDEO = 5,

    /**
     * 文件消息
     */
    V2TIM_ELEM_TYPE_FILE = 6,

    /**
     * 地理位置消息
     */
    V2TIM_ELEM_TYPE_LOCATION = 7,

    /**
     * 表情消息
     */
    V2TIM_ELEM_TYPE_FACE = 8,

    /**
     * 群 Tips 消息（存消息列表）
     */
    V2TIM_ELEM_TYPE_GROUP_TIPS = 9,

    /**
     * 合并消息
     */
    V2TIM_ELEM_TYPE_MERGER = 10,
}
