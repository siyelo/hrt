class User < ActiveRecord::Base
  include User::Upload
  include User::Roles
  include AttachmentHelper # gives private_url?

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable, :timeoutable,
  # :registerable, :omniauthable, :confirmable
  devise :database_authenticatable, :recoverable, :rememberable, :trackable,
         :validatable, :encryptable, :registerable

  ### Attributes
  attr_accessible :full_name, :email, :organization_id, :organization,
                  :password, :password_confirmation, :roles, :tips_shown,
                  :organization_ids, :location_id, :workplan

  ### Associations
  has_many :comments, :dependent => :destroy
  has_many :data_responses, :through => :organization
  belongs_to :organization, :counter_cache => true
  has_and_belongs_to_many :organizations, :join_table => "organizations_managers" # for activity managers
  belongs_to :location

  ### Validations
  # AuthLogic handles email uniqueness validation
  validates_presence_of :full_name, :email, :organization_id
  validates_length_of :password, :minimum => 6, :if => :password_required?

  ### Callbacks
  after_create :create_organization_responses

  ### Delegates
  delegate :responses, :to => :organization # instead of deprecated data_response
  delegate :latest_response, :to => :organization # find the last response in the org

  ### Attachments
  has_attached_file :workplan, path:
    AttachmentHelper.attachment_path("workplans/:user_id.:extension")

  ### Instance Methods

  def workplan_private_url
    if private_url?
      workplan.expiring_url(3600)
    else
      workplan.url
    end
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.password_reset_instructions(self).deliver
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

  def only_password_errors?
    errors.size == errors[:password].size +
      errors[:password_confirmation].size
  end

  def save_and_invite(inviter)
    self.valid? ## We need to call self.valid?
    if only_password_errors?
      self.invite_token = generate_token
      self.save(validate: false)
      send_user_invitation(inviter)
    end
  end

  def send_user_invitation(inviter)
    Notifier.send_user_invitation(self, inviter).deliver
  end

  def gravatar(size = 22)
    "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}.png?s=#{size}&d=mm"
  end

  # authlogic only updates last_login after youve signed in the 2nd time
  # if the user has only signed in once, return the current login date
  def last_signin_at
    current_sign_in_at
  end

  protected

  # admin create user ||
  #   - encrypted_password -> nil
  #   password.blank?
  # admin edit user ||
  # user edit themself
  # user accepts invitation
  #   -> enforce password required
  #   - encrypted_password -> nil

  # when user is not in database don't require


  # devise method override
  def password_required?
    (!persisted? || !password.nil? || !password_confirmation.nil?)# &&
      # (password.blank? || password_confirmation.blank? || encrypted_password.nil?)
  end

  # allow user to be created without a password
  # allow user to be updated without a password
  # but dont allow them to go active with an empty password
  # def require_password?
  #   self.active? && (!self.password.blank? || self.crypted_password.nil?)
  # end

  private

  def create_organization_responses
    organization.create_data_responses!
  end

end

# == Schema Information
#
# Table name: users
#
#  id                    :integer         not null, primary key
#  email                 :string(255)
#  crypted_password      :string(255)
#  password_salt         :string(255)
#  persistence_token     :string(255)
#  created_at            :datetime
#  updated_at            :datetime
#  roles_mask            :integer
#  organization_id       :integer
#  text_for_organization :text
#  full_name             :string(255)
#  perishable_token      :string(255)     default(""), not null
#  tips_shown            :boolean         default(TRUE)
#  invite_token          :string(255)
#  active                :boolean         default(FALSE)
#  location_id           :integer
#  current_sign_in_at    :datetime
#  last_login_at         :datetime
#

