class GameApi
  class GameNotFound < StandardError; end

  attr_reader :uuid
  delegate :actions, :view, to: :@game

  def self.start(player_count, user)
    game = new(players: player_count.times.map { nil })
    game.perform(:join, user.id, name: user.name)
    game
  end

  def initialize(uuid: SecureRandom.uuid, players: nil)
    @uuid = uuid
    if players
      @game = CoEngine.load(players: players)
      Game.create!(uuid: uuid, state: @game.state, max_players: players.count)
    else
      game_data = read
      raise GameNotFound if game_data.blank?
      @game = CoEngine.load(read)
    end
  end

  def perform(action, player_id, *args)
    @game.perform(action, player_id, *args)
    # any additional post action items then are required
    case action.to_sym
    when :join
      Player.create!(user_id: player_id, game: Game.find_by(uuid: uuid))
    end
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
    @redis ||= begin
      if ENV["REDISCLOUD_URL"]
        Redis.new(:url => ENV["REDISCLOUD_URL"])
      else
        Redis.new # use local version..
      end
    end
  end
end
