module User::Roles

  ### Constants
  ROLES = %w[admin reporter activity_manager]

  def self.included(klass)
    klass.send(:include, InstanceMethods)

    klass.class_eval do
      ### Validations
      validate :validate_inclusion_of_roles

      ### Callbacks
      before_save :unassign_organizations, :if => Proc.new{|m| m.roles.exclude?('activity_manager') }
    end
  end

  module InstanceMethods
    def roles=(roles)
      new_roles = roles.collect {|r| r.to_s} # allows symbols to be passed in
      self.roles_mask = (new_roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
    end

    def roles
      @roles || ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
    end

    def sysadmin?
      role?('admin')
    end

    def reporter?
      role?('reporter') || sysadmin?
    end

    def activity_manager?
      role?('activity_manager') || sysadmin?
    end

    private

    def unassign_organizations
      self.organizations = []
    end

    def role?(role)
      roles.include?(role.to_s)
    end

    def validate_inclusion_of_roles
      if roles.blank? || roles.detect{|role| ROLES.exclude?(role)}
        errors.add(:roles, "is not included in the list")
      end
    end
  end
end
