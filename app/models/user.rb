class User < ActiveRecord::Base
  include User::Upload
  include User::Roles

  acts_as_authentic do |c|
    c.validates_length_of_password_field_options = {:minimum => 6,
      :if => :require_password? }
    c.validates_confirmation_of_password_field_options = {:minimum => 6,
      :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 6,
      :if => :require_password?}
  end

  ### Attributes
  attr_accessible :full_name, :email, :organization_id, :organization,
                  :password, :password_confirmation, :roles, :tips_shown,
                  :organization_ids, :location_id

  ### Associations
  has_many :comments, :dependent => :destroy
  has_many :data_responses, :through => :organization
  belongs_to :organization, :counter_cache => true
  has_and_belongs_to_many :organizations, :join_table => "organizations_managers" # for activity managers
  belongs_to :location

  ### Validations
  # AuthLogic handles email uniqueness validation
  validates_presence_of :full_name, :email, :organization_id

  ### Callbacks
  after_create :create_organization_responses

  ### Delegates
  delegate :responses, :to => :organization # instead of deprecated data_response
  delegate :latest_response, :to => :organization # find the last response in the org

  ### Instance Methods

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def to_s
    name
  end

  def name
    full_name.present? ? full_name : email
  end

  # assign organization association so that counter cache is updated
  def organization_id=(organization_id)
    self.organization = Organization.find_by_id(organization_id) if organization_id.present?
  end

  def generate_token
    Digest::SHA1.hexdigest("#{self.email}#{Time.now}")[24..38]
  end

  def activate
    self.active = true
    self.invite_token = nil
    self.save
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def only_password_errors?
    errors.length == errors.on(:password).to_a.length +
      errors.on(:password_confirmation).to_a.length
  end

  def save_and_invite(inviter)
    self.valid? ## We need to call self.valid?
    if only_password_errors?
      self.invite_token = generate_token
      self.save(false)
      send_user_invitation(inviter)
    end
  end

  def send_user_invitation(inviter)
    Notifier.deliver_send_user_invitation(self, inviter)
  end

  def gravatar(size = 30)
    "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}.png?s=#{size}&d=mm"
  end

  # authlogic only updates last_login after youve signed in the 2nd time
  # if the user has only signed in once, return the current login date
  def last_signin_at
    current_login_at
  end

  private

    # allow user to be created without a password
    # allow user to be updated without a password
    # but dont allow them to go active with an empty password
    def require_password?
      self.active? && (!self.password.blank? || self.crypted_password.nil?)
    end

    def create_organization_responses
      organization.create_data_responses!
    end
end


# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  roles_mask               :integer
#  organization_id          :integer
#  data_response_id_current :integer
#  text_for_organization    :text
#  full_name                :string(255)
#  perishable_token         :string(255)     default(""), not null
#  tips_shown               :boolean         default(TRUE)
#  invite_token             :string(255)
#  active                   :boolean         default(FALSE)
#  location_id              :integer
#  current_login_at         :datetime
#  last_login_at            :datetime
#

