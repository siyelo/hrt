Paperclip.interpolates :key do |attachment, style|
  attachment.instance.key
end

Paperclip.interpolates :document_file_name do |attachment, style|
  attachment.instance.document_file_name
end
