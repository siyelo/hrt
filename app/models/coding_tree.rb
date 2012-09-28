#  USAGE:
#
#  activity    = Activity.find(889)
#  coding_type = PurposeBudgetSplit

#  ct = CodingTree.new(activity, coding_type)
#
#  p ct.roots[0].code.short_display
#  p ct.roots[0].ca.cached_amount
#  p ct.roots[0].children[0].code.short_display
#  p ct.roots[0].children[0].children[0].code.short_display
#  p ct.roots[0].children[0].children[0].children[0].code.short_display

class CodingTree
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

  attr_reader :activity, :coding_klass

  def initialize(activity, coding_klass)
    @activity     = activity
    @coding_klass = coding_klass
    @data_request = activity.data_request
  end

  def roots
    inner_root.children
  end

  # CodingTree is valid:
  #   - if all root assignments are valid
  #   - if sum of children is same as activity classification amount
  def valid?
    children_sum    = roots.inject(0){|sum, tree| sum += tree.ca.cached_amount}
    activity_amount = @activity.classification_amount(@coding_klass.to_s) || 0

    variance = activity_amount * (0.5/100)
    (activity_amount.blank? && children_sum == 0) ||
    (inner_root.valid_children? &&
     (children_sum <= (activity_amount + variance)) &&
      children_sum >= (activity_amount - variance))
  end

  def root_codes
    case @coding_klass.to_s
    when 'PurposeBudgetSplit', 'PurposeSpendSplit'
      Code.purposes.with_version(@data_request.purposes_version).roots
    when 'InputBudgetSplit', 'InputSpendSplit'
      Input.with_version(@data_request.inputs_version).roots
    when 'LocationBudgetSplit', 'LocationSpendSplit'
      Location.with_version(@data_request.locations_version).national_level +
        Location.with_version(@data_request.locations_version).without_national_level.sorted.all
    else
      raise "Invalid coding_klass #{@coding_klass.to_s}".to_yaml
    end
  end

  def set_cached_amounts!
    codings_sum(root_codes, @activity, @activity.classification_amount(@coding_klass.to_s))
  end

  def reload!
    rebuild_tree!
  end

  def total
    roots.inject(0){|total, root| total + root.ca.cached_amount}
  end

  def cached_children(code)
    all_codes.select{|c| c.parent_id == code.id}
  end

  protected
    def codings_sum(root_codes, activity, max)
      total         = 0
      max           = 0 if max.nil?
      cached_amount = 0
      descendants   = false
      root_codes.each do |code|
        ca = @coding_klass.with_activity(activity).with_code_id(code.id).first
        children = cached_children(code)
        if ca
          if ca.percentage.present? && ca.percentage > 0
            cached_amount = ca.percentage * max / 100
            bucket = self.codings_sum(children, activity, max)
            sum_of_children = bucket[:amount]
          else #TODO: remove - only percentages are used now
            bucket = self.codings_sum(children, activity, max)
            cached_amount = bucket[:amount]
            sum_of_children = bucket[:amount]
          end

          ca.update_attributes(:cached_amount => cached_amount,
                               :sum_of_children => sum_of_children)
          descendants = true # tell parents that it has descendants
        else
          bucket = self.codings_sum(children, activity, max)
          cached_amount = sum_of_children = bucket[:amount]

          if bucket[:descendants]
            @coding_klass.create!(:activity => activity, :code => code,
                                  :cached_amount => cached_amount,
                                  :sum_of_children => sum_of_children)
            descendants = true
          end
        end
        total += cached_amount
      end

      # return total and if there were descendant code assignments
      #puts "about to return from #{root_codes.map(&:name).join(',')}"
      #puts "total of #{total}"
      #puts "descendants of #{descendants}"
      {:amount => total, :descendants => descendants}
    end

  private

    def inner_root
      @inner_root ||= build_tree
    end

    def build_tree
      @code_splits = @coding_klass.with_activity(@activity)
      @inner_root       = Tree.new({})

      build_subtree(@inner_root, root_codes)

      return @inner_root
    end

    def build_subtree(root, codes)
      codes.each do |code|
        code_assignment = @code_splits.detect{|ca| ca.code_id == code.id}
        if code_assignment
          node = Tree.new({:ca => code_assignment, :code => code})
          root.children << node
          build_subtree(node, cached_children(code)) unless code.leaf?
        end
      end
    end

    def rebuild_tree!
      @inner_root = build_tree
    end

    def all_codes
      @all_codes ||= case @coding_klass.to_s
      when 'PurposeBudgetSplit', 'PurposeSpendSplit'
        Code.all
      when 'InputBudgetSplit', 'InputSpendSplit'
        Input.all
      when 'LocationBudgetSplit', 'LocationSpendSplit'
        Location.all
      else
        raise "Invalid coding_klass #{@coding_klass.to_s}".to_yaml
      end
    end
end
