class Game < ActiveRecord::Base
  belongs_to :winner, class_name: 'User'
  has_many :players
  has_many :users, through: :players

  validates_presence_of :max_players, :state, :uuid

  scope :waiting, -> { where(state: "CoEngine::WaitingForPlayers") }
  scope :finished, -> { where(state: "CoEngine::Completed") }
  scope :playing, -> { where.not(state: ["CoEngine::WaitingForPlayers", "CoEngine::Completed"]) }

  scope :for_user, ->(user) { includes(:players).where(players: { user_id: user.id })}
  scope :without_user, ->(user) { current_scope.where.not(id: current_scope.for_user(user).pluck(:id)) }

  scope :won, ->(user) { finished.where(winner_id: user.id) }
  scope :lost, ->(user) { finished.for_user(user).where.not(id: won(user).pluck(:id)) }
end
