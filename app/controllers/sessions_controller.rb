class SessionsController < ApplicationController
  def create
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
      render json: { status: 'success', auth_token: SecureRandom.uuid }
    else
      render json: { status: 'error', messages: ['Incorrect username or password'] }, status: 400
    end
  end
end
