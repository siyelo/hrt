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
      roles = [roles] if roles.is_a?(String)
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

    # deprecated
    def activity_manager?
      manager?
    end

    # True if a user has the 'activity' manager role
    # Inclusive of sysadmins too
    def manager?
      manager_or_sysadmin?
    end

    def manager_or_sysadmin?
      role?('activity_manager') || sysadmin?
    end

    def role?(role)
      roles.include?(role.to_s)
    end

    private

    def unassign_organizations
      self.organizations = []
    end

    def validate_inclusion_of_roles
      if roles.blank? || roles.detect{|role| ROLES.exclude?(role)}
        errors.add(:roles, "is not included in the list")
      end
    end
  end
end
