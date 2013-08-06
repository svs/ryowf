class Game

  include DataMapper::Resource

  property :id, Serial

  property :moves, Json

  validates_with_method :moves_valid?

  def add_move=(move)
    self.moves ||= []
    self.moves << move
  end


  private

  def moves_valid?
    return true if moves.nil? || moves.empty?
    begin
      game.moves = moves
    rescue
      return false
    end
    true
  end

  def game
    Chess::Game.new
  end

end
