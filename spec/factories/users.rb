FactoryGirl.define do
  factory :user do
    username "user1"
    email "user1@is3.com"
    password "password"
    password_confirmation "password"
  end
end
