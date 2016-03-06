class GamesController < ApplicationController
  before_action :authenticate

  def create
    game = GameApi.start((params[:players] || 4).to_i, @user)
    render json: { game_id: game.uuid, game: game.view(@user.id), actions: game.actions(@user.id) }
  end

  def index
    render json: {
      playing:              Game.playing.for_user(@user).count,
      won:                  Game.won(@user).count,
      lost:                 Game.lost(@user).count,
      waiting_for_players:  Game.waiting.for_user(@user).count,
      can_be_joined:        Game.waiting.without_user(@user).count,
    }
  end

  def show
    scope = {
      playing:              Game.playing.for_user(@user),
      won:                  Game.won(@user),
      lost:                 Game.lost(@user),
      waiting_for_players:  Game.waiting.for_user(@user),
      can_be_joined:        Game.waiting.without_user(@user),
    }[params[:id].to_sym] || raise("Unknown game state: #{params[:id]}")

    render json: {
      params[:id] => scope.all.map do |game|
        {
          id: game.uuid,
          max_players: game.max_players,
          players: game.users.map(&:name),
          winner: game.winner.try(:name)
        }
      end
    }
  end
end
