module Admin::DocumentsHelper

  def current_document_name(document)
    "Current file: #{document.document_file_name}" unless document.new_record?
  end
end
