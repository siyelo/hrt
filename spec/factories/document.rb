Factory.define :document do |f|
  f.title  "Document title"
  f.document { File.open(File.join(RAILS_ROOT, 'spec', 'fixtures', 'activities.csv')) }
end
