class AdminController < ApplicationController
  before_action :auth

  def index

  end

  def reset
    GameApi.reset

    render json: { status: 'game state reset' }
  end

  private

  def auth
    unless params[:username] == 'skynet' && params[:password] = 'overlord'
      authenticate
    end
  end
end
