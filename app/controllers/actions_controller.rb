class ActionsController < ApplicationController
  class MissingParam < StandardError; end

  before_action :authenticate

  def update
    game = GameApi.new(uuid: params[:id])

    args = params[:args] || {}
    if args[:player]
      args[:player_id] = Game.find_by(uuid: params[:id]).users.find_by(name: args[:player]).id
    end

    args = nil if args == {}

    game.perform(
      params[:perform] || raise(MissingParam, :perform),
      @user.id,
      args
    )

    render json: { uuid: game.uuid, game: game.view(@user.id), actions: game.actions(@user.id) }
  end
end
