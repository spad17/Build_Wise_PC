class UsersController < ApplicationController
  before_action :redirect_authenticated_user, only: %i[new create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      log_in(@user)
      redirect_to root_path, notice: "Регистрация прошла успешно. Добро пожаловать, #{@user.username}!"
    else
      flash.now[:alert] = "Проверьте данные формы."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :email, :password, :password_confirmation)
  end

  def redirect_authenticated_user
    redirect_to root_path, notice: "Вы уже вошли в аккаунт." if logged_in?
  end
end
