class SessionsController < ApplicationController
  before_action :redirect_authenticated_user, only: %i[new create]

  def new
  end

  def create
    email = params.dig(:session, :email).to_s.strip.downcase
    password = params.dig(:session, :password).to_s
    user = User.find_by(email: email)

    if user&.authenticate(password)
      return_to = session[:return_to]
      log_in(user)
      redirect_to return_to.presence || root_path, notice: "Вы вошли в аккаунт."
    else
      flash.now[:alert] = "Неверный email или пароль."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    log_out
    redirect_to root_path, notice: "Вы вышли из аккаунта."
  end

  private

  def redirect_authenticated_user
    redirect_to root_path, notice: "Вы уже вошли в аккаунт." if logged_in?
  end
end
