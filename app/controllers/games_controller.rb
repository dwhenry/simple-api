class GamesController < ApplicationController
  before_action :authenticate

  def create
    game = GameApi.start((params[:players] || 4).to_i, @user)
    render json: { uuid: game.uuid, game: game.view(@user.id), actions: game.actions(@user.id) }
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
    }[params[:id].to_sym]

    if scope
      render json: {
        params[:id] => scope.all.map do |game|
          {
            uuid: game.uuid,
            max_players: game.max_players,
            players: game.users.map(&:name),
            winner: game.winner.try(:name)
          }
        end
      }
    elsif params[:id] =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
      game = GameApi.new(uuid: params[:id])
      render json: { uuid: game.uuid, game: game.view(@user.id), actions: game.actions(@user.id) }
    else
      raise("Unknown game state: #{params[:id]}")
    end
  end
end
