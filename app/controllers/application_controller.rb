class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def authenticate
    unless session[:auth_token].present? && [params[:auth_token], env['AUTH_TOKEN']].include?(session[:auth_token])
      render json: { status: 'error', messages: ['user not authorised'] }, status: 400
    end
  end
end
