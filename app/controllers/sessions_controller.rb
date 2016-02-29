class SessionsController < ApplicationController
  def create
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
      session[:auth_token] = SecureRandom.uuid
      render json: { status: 'success', auth_token: session[:auth_token] }
    else
      render json: { status: 'error', messages: ['Incorrect username or password'] }, status: 400
    end
  end
end
