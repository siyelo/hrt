class Document < ActiveRecord::Base

  ### Attributes
  attr_accessible :title, :document

  ### Attachments
  has_attached_file :document, Settings.paperclip.to_options

  ### Validations
  validates_presence_of :title
  validates_uniqueness_of :title
  validates_attachment_presence :document
  validates_attachment_size :document, :less_than => 10.megabytes,
                            :message => "must be less than 10MB"
end
