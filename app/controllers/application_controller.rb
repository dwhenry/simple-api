class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from ::StandardError, with: :json_error

  protected

  def authenticate
    @user = User.authenticate(params[:auth_token] || env['AUTH_TOKEN'])
    unless @user
      render json: { status: 'error', messages: ['user not authorised'] }, status: 400
    end
  end

  def json_error(e)
    if [RuntimeError].include?(e.class)
      render json: { status: 'error', messages: [e.message] }, status: 400
    elsif e.class.to_s == e.message
      render json: { status: 'error', messages: [e.class.to_s.split('::').last] }, status: 400
    else
      render json: { status: 'error', messages: ["#{e.class.to_s.split('::').last}: #{e.message}"] }, status: 400
    end
  end
end
