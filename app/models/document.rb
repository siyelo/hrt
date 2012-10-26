class Document < ActiveRecord::Base
  include AttachmentHelper # gives private_url?

  ### Constants
  VISIBILITY_OPTIONS = %w[sysadmins reporters public]

  ### Attributes
  attr_accessible :title, :document, :visibility, :description

  ### Attachments
  has_attached_file :document, path:
    AttachmentHelper.attachment_path("documents/:attachment/:document_file_name.:extension")

  ### Validations
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_attachment_presence :document
  validates_attachment_size :document, less_than: 50.megabytes,
                            message: "must be less than 50MB"
  validates_inclusion_of :visibility, in: VISIBILITY_OPTIONS

  ### Named Scopes
  scope :latest_first, {order: "created_at DESC" }
  scope :limited, {limit: 5}
  scope :visible_to_reporters, conditions: ["visibility = ? OR visibility = ?",
                                                     'public', 'reporters']
  scope :visible_to_public, conditions: ["visibility = ?", 'public']

  def private_document_url
    if private_url?
      document.expiring_url(3600)
    else
      document.url
    end
  end
end
