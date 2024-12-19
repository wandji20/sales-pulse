class UsersController < ApplicationController
  def edit
  end

  def update
    if current_user.update(user_params)
      flash[:success] = t("flash_update.success", name: t("users.edit.my_account").downcase)
      redirect_to account_path
    else
      render :update, status: :unprocessable_entity
    end
  end

  def preferences
    settings = current_user.settings
    option = params[:settings].keys[0]
    keys = [ option, params[:settings][option.to_sym] ]
    settings[option][params[:settings][option.to_sym]] = !settings.dig(*keys)
    current_user.update_column(:settings, settings)
  end

  def destroy; end

  private

  def user_params
    params.require(:user).permit(
      :full_name, :email_address, :password, :password_confirmation, :avatar)
  end
end
