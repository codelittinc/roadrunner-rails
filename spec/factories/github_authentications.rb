FactoryBot.define do
  factory :github_authentication do
    access_token { "MyString" }
    refresh_token { "MyString" }
    refresh_token_expires_in { 1 }
  end
end
