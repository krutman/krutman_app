class StaticPagesController < ApplicationController
  def home
    if signed_in?
      @micropost = current_user.microposts.build #переменная для отображений
      @feed_items = current_user.feed.paginate(page: params[:page]) #переменная для погинорованного потока сообщений текущего пользователя в _feed
    end
  end

  def help
  end

  def about
  end
  
  def contact
  end
end
