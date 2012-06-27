### Environment configuration

case Rails.env
when 'development'
  # S3 - also change private_url? method
  #storage = :s3
  #bucket = 'us.assets.dev.hrtapp.com'
  # LOCAL
  storage = :filesystem
when 'staging'
  storage = :s3
  bucket = 'us.assets.staging.hrtapp.com'
when 'production'
  storage = :s3
  bucket = 'us.assets.hrtapp.com'
else
  storage = :filesystem
end

### Default options

Paperclip::Attachment.default_options[:s3_credentials] =
  {access_key_id: ENV['AMAZON_ACCESS_KEY_ID'],
   secret_access_key: ENV['AMAZON_SECRET_ACCESS_KEY']}
Paperclip::Attachment.default_options[:storage] = storage
Paperclip::Attachment.default_options[:bucket]  = bucket if bucket
Paperclip::Attachment.default_options[:s3_permissions] = 'authenticated-read'

### Interpolations

Paperclip.interpolates :key do |attachment, style|
  attachment.instance.key
end

Paperclip.interpolates :data_request_id do |attachment, style|
  attachment.instance.data_request_id
end

Paperclip.interpolates :document_file_name do |attachment, style|
  attachment.instance.document_file_name
end

Paperclip.interpolates :user_id do |attachment, style|
  attachment.instance.id
end
