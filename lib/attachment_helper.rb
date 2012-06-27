module AttachmentHelper

  def private_url?
    Rails.env == 'production' || Rails.env == 'staging'
  end

  def self.attachment_path(path)
    if Paperclip::Attachment.default_options[:storage] == :filesystem
      Paperclip::Attachment.default_options[:path]
    else
      path
    end
  end
end
