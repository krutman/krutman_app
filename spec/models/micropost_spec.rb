require 'spec_helper'

describe Micropost do

  let(:user) { FactoryGirl.create(:user) }
  before { @micropost = user.microposts.build(content: "Hello world") } #создает микропост, привязанный к пользователю

  subject { @micropost }

  it { should respond_to(:content) }
  it { should respond_to(:user_id) }
  it { should respond_to(:user) } #откликается на user, который возвращает пользователя, которому принадлежит микропост
  its(:user) { should eq user } #its тестирует атрибут :user, а не объект @microposts
  
  it { should be_valid } #объект должен быть валидным. видимо, это проверка true валидации в модели
  
  describe "when user_id is not present" do #невалидное, если в сообщении отсутствует user.id
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end
  
  describe "when user_id is not present" do
    before { @micropost.user_id = nil }
    it { should_not be_valid }
  end

  describe "with blank content" do
    before { @micropost.content = " " }
    it { should_not be_valid }
  end

  describe "with content that is too long" do
    before { @micropost.content = "a" * 141 }
    it { should_not be_valid }
  end
end