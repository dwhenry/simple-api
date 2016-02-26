class UsersController < ApplicationController
  def create
    user = User.new(name: params[:name], password: params[:password])
    if user.save
      render json: { status: 'success' }
    else
      render json: { status: 'error', messages: user.errors.full_messages }, status: 400
    end
  end
end
