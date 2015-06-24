require 'spec_helper'

describe "Authentication" do

  subject { page }
  
  describe "signin page" do
      before { visit signin_path }

      it { should have_content('Sign in') }
      it { should have_title('Sign in') }
  end

  describe "signin" do
    before { visit signin_path }
    
    it { should_not have_link('Users') }
    it { should_not have_link('Profile') }
    it { should_not have_link('Settings') }
    it { should_not have_link('Sign out', href: signout_path) }
    
    describe "with invalid information" do
      before { click_button "Sign in" }

      it { should have_title('Sign in') }
      it { should have_selector('div.alert.alert-danger') }
        
        describe "after visiting another page" do
          before { click_link "Home" }
            it { should_not have_selector('div.alert.alert-danger') }
          end
    end
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

      it { should have_title(user.name) }
      it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should have_link('Sign out',    href: signout_path) }
      it { should_not have_link('Sign in', href: signin_path) }
      
      describe "followed by signout" do
        before { click_link "Sign out" }
        it { should have_link('Sign in') }
      end
    end
  end
  
  describe "authorization" do
    
    describe "as signed user" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user, no_capybara:true } #!!при использовании HTTP-запросов напрямую, необходим флаг no_capybara:true
      
      describe "cannot access #new action" do
        before { get new_user_path }
        specify { expect(response).to redirect_to(root_url) }
      end
      
      describe "cannot access #create action" do
        before { post users_path(user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end

    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "in the Relationships controller" do
        describe "submitting to the create action" do
          before { post relationships_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete relationship_path(1) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
      
      describe "when attempting to visit a protected page" do #дружелюбная переадресация на запрашиваемую страницу
        before do
          visit edit_user_path(user) #посещаем страницу редактирования, выполняется переадресация на страницу входа
          fill_in "Email",    with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in" #выполняется вход
        end

        describe "after signing in" do

          it "should render the desired protected page" do #проверка переадресации
              expect(page).to have_title('Edit user')
          end
          
          describe "when signing in again" do
            before do
              click_link "Sign out"
              sign_in user
            end
            
            it "should render the default (profile) page" do
              expect(page).to have_title(user.name)
            end
          end
        end
      end

      describe "in the Users controller" do

        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_title('Sign in') }
        end

        describe "submitting to the update action" do #тестирование update patch-запросом
          before { patch user_path(user) }
          specify { expect(response).to redirect_to(signin_path) } #отвечает ли переадресацией на страницу входа
        end
        
        describe "visiting the user index" do
          before { visit users_path }
          it { should have_title('Sign in') }
        end
      end
      
      describe "in the Microposts controller" do
        #требование входа для действий create и destroy
        describe "submitting to the create action" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
      end
    end
    
    describe "as wrong user" do #имеют ли действия edit и update правильного пользователя
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") } #создание пользователя с адресом, отличающегося от дефолтного
      before { sign_in user, no_capybara: true }

      describe "submitting a GET request to the Users#edit action" do
        before { get edit_user_path(wrong_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

      describe "submitting a PATCH request to the Users#update action" do
        before { patch user_path(wrong_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
    
    describe "as non-admin user" do #не-администратор не может удалять других пользователей
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }

      before { sign_in non_admin, no_capybara: true } #no_capybara - потому что вход в обход вылидации

      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) } #непосредственная выдача DELETE к указанному URL
        specify { expect(response).to redirect_to(root_url) } #перенаправление в root при запросе delete
      end
    end
    
    describe "as admin user" do #админ не может направить запрос DELETE и удалить сам себя
      let(:admin) { FactoryGirl.create(:admin) }
      
      before {sign_in admin, no_capybara: true }
      
      describe "should not be able to delete themselves via #destroy action" do
        specify do
          expect { delete user_path(admin) }.not_to change(User, :count).by(-1)
        end
      end
    end
  end
end