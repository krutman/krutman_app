class UsersController < ApplicationController
  before_action :signed_in_user, only: [:index, :edit, :update] #требование входа для действий - вызов метода signed_in_user
  before_action :correct_user,   only: [:edit, :update] #требование правильного пользователя для доступа к методам edit и update
  before_action :admin_user,     only: :destroy #ограниение к действию destroy всем пользователям, кроме админов
  
  def index #отображение пользователей
    @users = User.paginate(page: params[:page]) #:page параметр приходит из params[:page] который will_paginate сгенерировал автоматически
  end
  
  def show
    @user = User.find(params[:id])
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
    User.find(params[:id]).destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end
  
  private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # Before filters

    def signed_in_user
      unless signed_in?
        store_location #помещает запрашиваемый URL в переменную session[:return_to] для GET-запросов
        redirect_to signin_url
        flash[:warning] = "Please sign in."
      end
    end
    
    def correct_user
      @user = User.find(params[:id]) #также определяет @user для edit и update
      redirect_to(root_url) unless current_user?(@user)
    end
    
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
