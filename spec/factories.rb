FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" } #метод при следующем вызове увеличит n+1
    sequence(:email) { |n| "person_#{n}@example.com"}
    password "foobar"
    password_confirmation "foobar"
    
    factory :admin do #теперь FactoryGirl.create(:admin) позволяет создавать администраторов
      admin true
    end
  end
  
  factory :micropost do
    content "Hello world"
    user #сообщаем FactoryGirl, что микропосты связаны с пользователем
  end
end