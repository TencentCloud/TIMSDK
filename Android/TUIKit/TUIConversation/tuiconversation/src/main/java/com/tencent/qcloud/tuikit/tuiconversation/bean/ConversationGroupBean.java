package com.tencent.qcloud.tuikit.tuiconversation.bean;

public class ConversationGroupBean {
    public static final int CONVERSATION_GROUP_TYPE_DEFAULT = 101;
    public static final int CONVERSATION_GROUP_TYPE_MARK = 102;
    public static final int CONVERSATION_GROUP_TYPE_GROUP = 103;

    public static final int CONVERSATION_ALL_GROUP_WEIGHT = 0;
    public static final int CONVERSATION_DEFAULT_GROUP_WEIGHT = 2;
    public static final int CONVERSATION_MARK_START_GROUP_WEIGHT = 4;
    public static final int CONVERSATION_GROUP_START_GROUP_WEIGHT = 5;

    private transient String title;
    private int weight = 0;
    private boolean isHide;
    private transient int groupType;
    private transient long unReadCount;
    private transient long markType = -1;

    public long getUnReadCount() {
        return unReadCount;
    }

    public void setUnReadCount(long unReadCount) {
        this.unReadCount = unReadCount;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public long getMarkType() {
        return markType;
    }

    public void setMarkType(long markType) {
        this.markType = markType;
    }

    public int getWeight() {
        return weight;
    }

    public void setWeight(int weight) {
        this.weight = weight;
    }

    public int getGroupType() {
        return groupType;
    }

    public void setGroupType(int groupType) {
        this.groupType = groupType;
    }

    public boolean getIsHide() {
        return isHide;
    }

    public void setIsHide(boolean head) {
        this.isHide = head;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        ConversationGroupBean bean = (ConversationGroupBean) o;
        // return Objects.equals(title, bean.title);
        return beanEquals(title, bean.title);
    }

    private boolean beanEquals(Object a, Object b) {
        if (a == b) {
            return true;
        }
        if (a == null || b == null) {
            return false;
        }
        return a.equals(b);
    }

    @Override
    public int hashCode() {
        // return Objects.hash(title);
        int result = 17;
        result = 31 * result + ((title == null) ? 0 : title.hashCode());
        result = 31 * result + (int) unReadCount;
        result = 31 * result + (int) markType;
        result = 31 * result + weight;
        result = 31 * result + groupType;
        return result;
    }

    @Override
    public String toString() {
        return "ConversationGroupBean{"
            + "title=" + title + ", unReadCount=" + unReadCount + ", markType='" + markType + '\'' + ", weight='" + weight + '\'' + ", groupType='" + groupType
            + '\'' + ", isHide='" + isHide + '\'' + '}';
    }
}
