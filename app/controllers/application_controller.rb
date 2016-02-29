class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def authenticate
    @user = User.authenticate(params[:auth_token] || env['AUTH_TOKEN'])
    unless @user
      render json: { status: 'error', messages: ['user not authorised'] }, status: 400
    end
  end
end
