Factory.define :document do |f|
  f.sequence(:title)   { |i| "document_#{i}_#{rand(100_000_000)}" }
  f.document { File.open(File.join(RAILS_ROOT, 'spec', 'fixtures', 'activities.csv')) }
  f.visibility "public"
end
