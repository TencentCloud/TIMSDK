package com.tencent.qcloud.tuikit.tuicommunity.bean;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class TreeNode<T extends Comparable<T>> implements Serializable, Comparable<TreeNode<T>> {
    private String nodeName;
    private int level = 0;
    private boolean isCollapse = false;
    private List<TreeNode<T>> childList;
    private TreeNode<T> parent;
    private T data;

    public void setData(T data) {
        this.data = data;
    }

    public T getData() {
        return data;
    }

    public void setChildList(List<TreeNode<T>> childList) {
        this.childList = childList;
    }

    public void setCollapse(boolean collapse) {
        isCollapse = collapse;
    }

    public void setNodeName(String nodeName) {
        this.nodeName = nodeName;
    }

    public int getLevel() {
        return level;
    }

    public List<TreeNode<T>> getChildList() {
        return childList;
    }

    public String getNodeName() {
        return nodeName;
    }

    public boolean isCollapse() {
        return isCollapse(this);
    }

    private boolean isCollapse(TreeNode<T> node) {
        if (node.isCollapse) {
            return true;
        } else {
            if (node.parent != null) {
                return isCollapse(node.parent);
            }
        }
        return false;
    }

    public int getNodeCount() {
        return getChildCount(this) + 1;
    }

    public void setParent(TreeNode<T> parent) {
        this.parent = parent;
    }

    public TreeNode<T> getParent() {
        return parent;
    }

    public boolean hasChild() {
        return childList != null && !childList.isEmpty();
    }

    public int getChildCount() {
        return getChildCount(this);
    }

    private int getChildCount(TreeNode<T> treeNode) {
        if (treeNode.childList == null) {
            return 0;
        }
        int count = treeNode.childList.size();
        for (TreeNode<T> node : treeNode.childList) {
            count += getChildCount(node);
        }
        return count;
    }

    public void addNodes(List<TreeNode<T>> nodeList) {
        if (nodeList == null) {
            return;
        }
        for (TreeNode<T> node : nodeList) {
            addNode(node);
        }
    }

    public void addNode(TreeNode<T> node) {
        if (node == null) {
            return;
        }
        if (childList == null) {
            childList = new ArrayList<>();
        }
        node.parent = this;
        node.level = this.level + 1;
        childList.add(node);
        Collections.sort(childList);
    }

    public boolean remove() {
        return remove(false);
    }

    public boolean delete(TreeNode<T> node) {
        return delete(node, false);
    }

    public void clear() {
        childList = null;
        isCollapse = false;
        parent = null;
        data = null;
        level = 0;
    }

    public boolean remove(boolean deleteChildren) {
        return delete(this, deleteChildren);
    }

    public boolean delete(TreeNode<T> node, boolean deleteChildren) {
        if (node == null) {
            return true;
        }
        return delete(this, node, deleteChildren);
    }

    private boolean delete(TreeNode<T> parent, TreeNode<T> node, boolean deleteChildren) {
        if (parent.nodeEquals(node)) {
            TreeNode<T> parentParent = parent.getParent();
            if (parentParent != null) {
                return delete(parentParent, parent, deleteChildren);
            }
            // if root node, return false
            return false;
        }
        List<TreeNode<T>> nodeList = parent.childList;
        if (nodeList == null || nodeList.isEmpty()) {
            return false;
        }
        for (TreeNode<T> treeNode : nodeList) {
            if (node.nodeEquals(treeNode)) {
                if (!deleteChildren) {
                    if (node.hasChild()) {
                        List<TreeNode<T>> deleteNodeChildList = node.childList;
                        parent.addNodes(deleteNodeChildList);
                    }
                }
                return nodeList.remove(treeNode);
            }
            if (treeNode.hasChild()) {
                boolean treeNodeDelete = delete(treeNode, node, deleteChildren);
                if (treeNodeDelete) {
                    return true;
                }
            }
        }
        return false;
    }

    public boolean containsNode(TreeNode<T> node) {
        if (node == null) {
            return false;
        }
        return containsNode(this, node);
    }

    private boolean containsNode(TreeNode<T> parent, TreeNode<T> node) {
        if (parent.nodeEquals(node)) {
            return true;
        }
        List<TreeNode<T>> nodeList = parent.childList;
        if (nodeList == null || nodeList.isEmpty()) {
            return false;
        }
        for (TreeNode<T> treeNode : nodeList) {
            if (node.nodeEquals(treeNode)) {
                return true;
            }
            if (treeNode.hasChild()) {
                boolean treeNodeContains = containsNode(treeNode, node);
                if (treeNodeContains) {
                    return true;
                }
            }
        }
        return false;
    }

    public TreeNode<T> getRoot() {
        return getRoot(this);
    }

    private TreeNode<T> getRoot(TreeNode<T> node) {
        if (node.parent != null) {
            return getRoot(node.parent);
        }
        return node;
    }

    public int indexOf(TreeNode<T> node) {
        List<TreeNode<T>> list = getRoot().toList();
        return list.indexOf(node);
    }

    public List<TreeNode<T>> toList() {
        List<TreeNode<T>> nodeList = new ArrayList<>();
        visitNode(nodeList, this);
        nodeList.remove(this);
        return nodeList;
    }

    public void visitNode(List<TreeNode<T>> list, TreeNode<T> node) {
        list.add(node);
        if (!node.hasChild()) {
            return;
        }
        for (TreeNode<T> child : node.childList) {
            visitNode(list, child);
        }
    }

    protected boolean nodeEquals(TreeNode<T> node1, TreeNode<T> node2) {
        return node1 == node2;
    }

    public final boolean nodeEquals(TreeNode<T> node) {
        return nodeEquals(this, node);
    }

    @Override
    public int compareTo(TreeNode<T> o) {
        return compareDataTo(o.getData());
    }

    public int compareDataTo(T data) {
        if (this.data != null && data != null) {
            return this.data.compareTo(data);
        } else if (this.data == null && data != null) {
            return -1;
        } else if (this.data != null && data == null) {
            return 1;
        } else {
            return 0;
        }
    }
}