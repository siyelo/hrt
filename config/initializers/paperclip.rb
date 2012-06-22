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
