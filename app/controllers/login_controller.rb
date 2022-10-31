class LoginController < ApplicationController
  before_action :user_exist?, only: [:login]
  skip_before_action :authorized?
  def login
    run User::Operation::Login::Present
  end

  def action_login
    run User::Operation::Login do |result|
      if params[:user][:remember_me].to_i == 1
        cookies.permanent[:auth_token] = result[:user][:auth_token]
      elsif params[:user][:remember_me].to_i == 0
        cookies[:auth_token] = result[:user][:auth_token]
      end
      redirect_to posts_path, notice: 'Login Successfully'
      return
    end
    if result.failure? && result[:email_pwd_fail]
      flash[:alert] = 'Email or Password invalid'
      render :login
    elsif result[:failed_attempts] < 3
      params[:user][:failed_attempts] = result[:failed_attempts]
      flash[:alert] = 'Email or Password invalid'
      render :login
    elsif result[:failed_attempts] == 3
      flash[:alert] = 'Too many failed attempts'
      countdown(10)
    else
      render :login
    end
  end

  def logout
    cookies.delete(:auth_token)
    redirect_to root_path, notice: 'Logout Successfully'
  end

  def password_reset
    run User::Operation::PasswordResetSend::Present
  end

  def password_reset_send
    run User::Operation::PasswordResetSend do |result|
      return redirect_to root_path, notice: 'Check your email, We have sent a link to reset your password'
    end
    if result.failure?
      redirect_to password_reset_path, alert: 'Something is wrong. Please try again'
    end
  end

  def reset_password
    run User::Operation::ResetPassword::Present
    if result.failure?
      redirect_to root_path, alert: 'Your token has expired. Please try again'
    end
  end
  
  def reset_password_send
    run User::Operation::ResetPassword do |result|
      return redirect_to root_path, notice: 'Your Password was reset successfully. Please sign in'
    end
      render :reset_password, status: :unprocessable_entity
  end
end
