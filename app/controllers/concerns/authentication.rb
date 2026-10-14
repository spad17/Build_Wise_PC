module Authentication
  extend ActiveSupport::Concern

  included do
    helper_method :current_user, :logged_in?
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_login
    return if logged_in?

    store_location
    redirect_to login_path, alert: "Войдите в аккаунт, чтобы открыть эту страницу."
  end

  def log_in(user)
    reset_session
    session[:user_id] = user.id
    @current_user = user
  end

  def log_out
    reset_session
    @current_user = nil
  end

  private

  def store_location
    return unless request.get? && request.format.html?

    session[:return_to] = request.fullpath
  end
end
