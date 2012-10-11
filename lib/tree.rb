class Tree
  def initialize(object)
    @object = object
    @children = []
  end

  def <<(object)
    subtree = Tree.new(object)
    @children << subtree
    return subtree
  end

  def children
    @children
  end

  def code
    @object[:code]
  end

  def ca
    @object[:ca]
  end

  # Tree is valid if:
  #   - node is valid
  #   - all children of the node are valid
  def valid?
    valid_node? && valid_children?
  end

  # Node is valid if:
  #   - cached_amount is equal to activity if root code
  #   - cached_amount and sum_of_children have same amount,
  #     except for the leaf code assignments
  def valid_node?
    (ca.cached_amount >= ca.sum_of_children) ||
      (ca.sum_of_children == 0 && children.empty?)
  end

  def valid_children?
    children.detect{|node| node.valid? == false} == nil
  end
end
