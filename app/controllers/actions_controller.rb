class ActionsController < ApplicationController
  class MissingParam < StandardError; end

  before_action :authenticate

  def update
    game = GameApi.new(uuid: params[:id])

    game.perform(
      params[:perform] || raise(MissingParam, :perform),
      @user.id,
      params
    )

    render json: { game_id: game.uuid, game: game.view(@user.id), actions: game.actions(@user.id) }
  end
end
