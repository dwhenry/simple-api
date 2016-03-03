class SessionsController < ApplicationController
  def create
    user = User.by_name(params[:name])
    user && user.authenticate!(params[:password])
    render json: { status: 'success', auth_token: user.auth_token }
  end
end
