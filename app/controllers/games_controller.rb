class GamesController < ApplicationController
  before_action :authenticate

  def create
    game = GameApi.start((params[:players] || 4).to_i, @user)

    render json: { game_id: game.id, data: game.view(@user.id), actions: game.actions(@user.id) }
  end

  def index
    render json: []
  end
end
