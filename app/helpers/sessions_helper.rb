module SessionsHelper #необходимо сделать include в application_controller.rb для доступа в контроллерах

  def sign_in(user)
    remember_token = User.new_remember_token
    cookies.permanent[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end
  
  def signed_in?
      !current_user.nil?
  end
  
  def current_user=(user)
    @current_user = user
  end
  
  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end
  
  #булевый метод для ограничения доступа пользователей не к своим страницам
  def current_user?(user)
    user == current_user
  end
  
  def signed_in_user
    unless signed_in?
      store_location #помещает запрашиваемый URL в переменную session[:return_to] для GET-запросов
      redirect_to signin_url
      flash[:warning] = "Please sign in."
    end
  end
  
  def sign_out
    current_user.update_attribute(:remember_token, User.encrypt(User.new_remember_token))
    cookies.delete(:remember_token)
    self.current_user = nil
  end
  
  def redirect_back_or(default) #дружественная переадресация на сохраненный путь session[:return_to]
    redirect_to(session[:return_to] || default)
    session.delete(:return_to)
  end

  def store_location #session - экземпляр переменной cookies
    session[:return_to] = request.url if request.get? #создается переменная, если запрос get
  end
end