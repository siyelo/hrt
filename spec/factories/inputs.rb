# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :input do
    name "In service training and workshops"
    description "It includes all costs related to the implementation of the training (per diems, transport allowances, hall rent, coffee breaks), workshops and similar activities. On-the-job training and/or recurrent training for professionals"
    external_id "code1"
    version 1
  end
end
