class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers] #требование входа для действий - вызов метода signed_in_user
  before_action :correct_user,   only: [:edit, :update] #требование правильного пользователя для доступа к методам edit и update
  before_action :admin_user,     only: :destroy #ограничение к действию destroy всем пользователям, кроме админов
  before_action :restrict_registration, only: [:new, :create] #ограничение регистрации для зарегистрированных пользователей
  
  
  def index #отображение пользователей
    @users = User.paginate(page: params[:page]) #:page параметр приходит из params[:page] который will_paginate сгенерировал автоматически
  end
  
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page]) #переменная @microposts для пагинации will_paginate @microposts
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Krutman App!"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end
  
  def destroy
    user = User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User deleted."
      redirect_to users_url
    else
      redirect_to users_url 
    end
  end
  
  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end
  
  private

    def user_params #разрешенные к передаче через params параметры
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # Before filters
    
    def correct_user
      @user = User.find(params[:id]) #также определяет @user для edit и update
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
    def restrict_registration
      redirect_to root_url, notice: "You are already regsitered." if signed_in?
    end
end
