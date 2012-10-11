FactoryGirl.define do
  factory :comment, class: Comment do |f|
    f.comment     { 'comment' }
    f.user        { FactoryGirl.create(:reporter) }
  end
end
