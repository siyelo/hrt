module User::Upload

  FILE_UPLOAD_COLUMNS = %w[organization_name email full_name roles password
                           password_confirmation]

  def self.included( klass )
    klass.extend ClassMethods
  end

  module ClassMethods
    def create_from_file(doc)
      saved, errors = 0, 0
      doc.each do |row|
        attributes = row.to_hash
        organization = Organization.find_by_name(attributes.delete('organization_name'))
        attributes.merge!(:organization_id => organization.id) if organization
        user = User.new(attributes)
        user.save ? (saved += 1) : (errors += 1)
      end
      return saved, errors
    end
  end
end

