module CodeVersion

  def last_version
    maximum(:version)
  end

  def with_last_version
    where(version: last_version)
  end

  def with_version(version)
    where(version: version)
  end

end
