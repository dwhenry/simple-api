class GameApi
  attr_reader :id

  delegate :actions, :view,
    to: :@game

  def self.start(player_count, user)
    game = new(players: player_count.times.map { nil })
    game.join(user)
    game
  end

  def initialize(id: SecureRandom.uuid, players: nil)
    @id = id
    if players
      @game = CoEngine.load(players: players)
      Game.create(uuid: id, state: @game.state, max_players: players.count)
    elsif players
      @game = CoEngine.load(read)
    end
  end

  def join(user)
    @game.perform(:join, user.id, name: user.name)
    Player.create(user: user, game: Game.find_by(uuid: id))
    write
  end

private

  def write
    redis.set(id, @game.export)
    Game.where(uuid: id).update_all(state: @game.state)
    Game.where(uuid: id).update_all(winner_id: @game.winner[:id]) if @game.winner
    id
  end

  def read
    redis.get(id)
  end

  def redis
    @redis ||= Redis.new
  end
end
