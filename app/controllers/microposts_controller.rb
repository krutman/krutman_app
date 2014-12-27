class MicropostsController < ApplicationController
  before_action :signed_in_user #требование входа для действий контроллера
  before_action :correct_user,   only: :destroy #только автор может удалять свои сообщения

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = [] #пустой массив для отображения страницы при неудачной отправке сообщения. страница ожидает переменную @feed_items
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    redirect_to root_url
  end
  
  private

    def micropost_params #строгие параеметры - для редактирования через веб только контента микросообщения
      params.require(:micropost).permit(:content)
    end
    
    def correct_user #выполненеи поиска через ассоциацию, а не через модель Micropost более безопасно
      @micropost = current_user.microposts.find_by(id: params[:id]) #find_by, т к find вызывает исключение, а не nil
      redirect_to root_url if @micropost.nil?
    end
end