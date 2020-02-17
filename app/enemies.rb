
class Enemy
  attr_sprite
  def initialize
  end
end

class Meteor
  attr_sprite
  attr_accessor :active
  def initialize scale
  
    @x = 0
    @y = 0
    case rand(4)
    when 0
      @x = rand(1280)
      @y = -40
    when 1
      @x = -40
      @y = rand(720)
      #
    when 2
      @x = rand(1280)
      @y = 760
    when 3
      @x = 1320
      @y = rand(720)
    end

    @w = 42 * scale
    @h = 39 * scale
    @path = "sprites/enemy1.png"
    @angle = 0

    @theta = 360 * rand()
    @active = true
    @rotation_speed = 5 * rand()
    @speed = 10 * rand() * scale
  end
  def update
    @x += @speed * Math.cos(180 * @theta / Math::PI)
    @y += @speed * Math.sin(180 * @theta / Math::PI)
    @x = 1320 if @x < -40
    @x = -40 if @x > 1320
    @y = 760 if @y < -40
    @y = -40 if @y > 760
    @angle += @rotation_speed
  end
end

