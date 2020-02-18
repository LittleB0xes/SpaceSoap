
class Meteor
  attr_sprite
  attr_accessor :active, :big_one, :speed, :theta, :enemy_type
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

    @enemy_type = :meteor
    @theta = 2 * Math::PI * rand()
    @active = true
    @rotation_speed = 5 * rand()
    @speed = 10 * rand() * scale
    @scale = scale
  end
  def update
    @x += @speed * Math.cos(@theta)
    @y += @speed * Math.sin(@theta)
    @x = 1320 if @x < -40
    @x = -40 if @x > 1320
    @y = 760 if @y < -40
    @y = -40 if @y > 760
    @angle += @rotation_speed
  end
  def fragmentation
    meteor_fragment = Meteor.new @scale
    meteor_fragment.x = @x
    meteor_fragment.y = @y
    meteor_fragment.enemy_type = :little_meteor
    meteor_fragment.speed = @speed
    meteor_fragment.theta = @theta - Math::PI / 3
    meteor_fragment.w = 22 * @scale
    meteor_fragment.h = 20 * @scale
    @w = 22 * @scale
    @h = 20 * @scale
    @theta += Math::PI / 3
    @enemy_type = :little_meteor
    meteor_fragment
  end
end

