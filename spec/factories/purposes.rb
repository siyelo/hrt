# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :purpose do
    name "Human Resources For Health"
    description "Increasing the availability and quality of human resources for health"
    version 1
    official_name "02  HUMAN RESOURCES FOR HEALTH"
    sub_account "HRFH"
    mtef_code "Human Resources For Health"
    nsp_code nil
    nasa_code nil
    nha_code nil
    hssp2_stratprog_val "Human Resources For Health"
    hssp2_stratobj_val "Across all 3 objectives"
  end
end
