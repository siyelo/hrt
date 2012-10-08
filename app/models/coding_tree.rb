#  USAGE:
#
#  activity = Activity.find(889)
#  ct = CodingTree.new(activity, :purpose, :budget)
#
#  p ct.roots[0].code.name
#  p ct.roots[0].ca.cached_amount
#  p ct.roots[0].children[0].code.name
#  p ct.roots[0].children[0].children[0].code.name
#  p ct.roots[0].children[0].children[0].children[0].code.name

class CodingTree
  include AmountType

  # TODO: move coding_tree in lib and extract Tree class into separate file
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
  end #### END OF TREE CLASS



  attr_reader :activity, :code_type, :amount_type, :activity_amount

  def initialize(activity, code_type, amount_type)
    @activity        = activity
    @code_type       = code_type
    @amount_type     = amount_type
    @activity_amount = @activity.send(:"total_#{amount_type}") || 0
  end

  def roots
    inner_root.children
  end

  # CodingTree is valid:
  #   - if all root assignments are valid
  #   - if sum of children is same as activity classification amount
  def valid?
    children_sum    = roots.inject(0){|sum, tree| sum += tree.ca.cached_amount}

    variance = activity_amount * (0.5/100)
    (activity_amount.blank? && children_sum == 0) ||
    (inner_root.valid_children? &&
     (children_sum <= (activity_amount + variance)) &&
      children_sum >= (activity_amount - variance))
  end

  def root_codes
    if code_type == :location
      version = data_request.locations_version
      Location.with_version(version).national_level +
        Location.with_version(version).without_national_level.sorted.all
    else
      # data_request.purposes_version
      version = data_request.send(:"#{code_type.to_s.pluralize}_version")
      code_klass.with_version(version).roots
    end
  end

  def set_cached_amounts!
    codings_sum(root_codes, @activity, activity_amount)
  end

  def reload!
    rebuild_tree!
  end

  def total
    roots.inject(0){|total, root| total + root.ca.cached_amount}
  end

  def cached_children(code)
    return [] if code.is_a? Location
    all_codes.select{|c| c.parent_id == code.id}
  end

  protected
    def codings_sum(root_codes, activity, max)
      total         = 0
      cached_amount = 0
      descendants   = false

      root_codes.each do |code|
        ca = activity.code_splits.with_code_and_type(code, amount_type).first
        children = cached_children(code)
        if ca
          if ca.percentage.present? && ca.percentage > 0
            cached_amount = ca.percentage * max / 100
            bucket = codings_sum(children, activity, max)
            sum_of_children = bucket[:amount]
          else #TODO: remove - only percentages are used now
            bucket = codings_sum(children, activity, max)
            cached_amount = bucket[:amount]
            sum_of_children = bucket[:amount]
          end

          ca.update_attributes(:cached_amount => cached_amount,
                               :sum_of_children => sum_of_children)
          descendants = true # tell parents that it has descendants
        else
          bucket = codings_sum(children, activity, max)
          cached_amount = sum_of_children = bucket[:amount]

          if bucket[:descendants]
            CodeSplit.create!(:activity => activity, :code => code,
                              :is_spend => is_spend?(amount_type),
                              :cached_amount => cached_amount,
                              :sum_of_children => sum_of_children)
            descendants = true
          end
        end
        total += cached_amount
      end

      { :amount => total, :descendants => descendants }
    end

  private

    def inner_root
      @inner_root ||= build_tree
    end

    def build_tree
      @code_splits = @activity.code_splits.
                      send(code_type.to_s.pluralize).send(amount_type)
      @inner_root = Tree.new({})

      build_subtree(@inner_root, root_codes)

      return @inner_root
    end

    def build_subtree(root, codes)
      codes.each do |code|
        code_assignment = @code_splits.detect{|ca| ca.code_id == code.id}
        if code_assignment
          node = Tree.new({:ca => code_assignment, :code => code})
          root.children << node
          unless code_type == :location
            build_subtree(node, cached_children(code)) unless code.leaf?
          end
        end
      end
    end

    def rebuild_tree!
      @inner_root = build_tree
    end

    def all_codes
      @all_codes ||= code_klass.all
    end

    def code_klass
      @code_klass ||= code_type.to_s.capitalize.constantize
    end

    def data_request
      @data_request ||= activity.data_request
    end
end
