class GameApi
  class GameNotFound < StandardError; end

  attr_reader :uuid
  delegate :actions, :view, to: :@game

  def self.start(player_count, user)
    game = new(players: player_count.times.map { nil })
    game.join(user)
    game
  end

  def initialize(uuid: SecureRandom.uuid, players: nil)
    @uuid = uuid
    if players
      @game = CoEngine.load(players: players)
      Game.create(uuid: uuid, state: @game.state, max_players: players.count)
    else
      game_data = read
      raise GameNotFound if game_data.blank?
      @game = CoEngine.load(read)
    end
  end

  def join(user)
    @game.perform(:join, user.id, name: user.name)
    Player.create(user: user, game: Game.find_by(uuid: uuid))
    write
  end

  def perform(*args)
    @game.perform(*args)
    write
  end

private

  def write
    redis.set(uuid, @game.export)
    Game.where(uuid: uuid).update_all(state: @game.state)
    Game.where(uuid: uuid).update_all(winner_id: @game.winner[:id]) if @game.winner
    uuid
  end

  def read
    redis.get(uuid)
  end

  def redis
    @redis ||= Redis.new
  end
end
