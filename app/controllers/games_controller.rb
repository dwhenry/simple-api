class GamesController < ApplicationController
  before_action :authenticate

  def create
    render json: {}
  end

  def index
    render json: []
  end
end
