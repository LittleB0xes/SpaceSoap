# Shooter

class Game
  def initialize
    @state = :intro
    @player = Player.new(1280 / 2, 720 / 2)
  end

  def state_manager
    case @state
    when :intro
      #
    when :level_one
      #
    when :level_two
      #
    when :end
    end
  end

end

class Player
  attr_sprite
  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Meteor
  attr_sprite
  def initialize
  end
end

class Enemy
  attr_sprite
  def initialize
  end
end

def tick args

end
