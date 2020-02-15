
# Shooter

class Game
  def initialize
    @scale = 0.6
    @state = :level_one
    @player = Player.new(1280 / 2, 720 / 2, @scale)
    @meteors_list = []
    50.times {@meteors_list.push(Meteor.new @scale)}
  end

  def state_manager args
    case @state
    when :intro
      #
    when :level_one
      control_manager args
      game_update args.tick_count
      game_render args
    when :end
    end
  end
  def game_render args
    args.outputs.static_background_color = [21,15,10]
    args.outputs.solids << [0,0,1280,720,21,15,10,255]
    args.outputs.sprites << @player.sprite
    args.outputs.sprites << @meteors_list.map do |meteor|
      meteor.sprite
    end
  end

  def game_update tick_count
    @player.update tick_count
    @meteors_list.each do |meteor|
      meteor.update
    end
  end
  
  def control_manager args
    case @state
    when :intro
      if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.start
        @state = :game
      end
    when :level_one
      if args.inputs.keyboard.key_held.left || args.inputs.controller_one.key_held.directional_left
        @player.rotation_factor = -1
      elsif args.inputs.keyboard.key_held.right || args.inputs.controller_one.key_held.directional_right
        @player.rotation_factor = 1
      else
        @player.rotation_factor = args.inputs.controller_one.left_analog_x_raw / 32000
      end
      if args.inputs.keyboard.key_held.up || args.inputs.controller_one.key_held.a
        @player.engine_on = true
      end
      #
    end
  end

end

class Player
  attr_sprite
  attr_accessor :engine_on, :rotation_factor
  def initialize x, y, scale 
    #Sprite properties
    @x = x
    @y = y
    @w = 45 * scale
    @h = 46 * scale
    @tile_w = 45
    @tile_h = 46
    @angle = 0
    @tile_w = 45
    @tile_h = 46
    @tile_x = 0
    @tile_y = 0
    @path = "sprites/SpaceShip.png"
    
    # Other player properties
    @vx = 0
    @vy = 0
    @rotation_factor = 0
    @rotation_speed = 5
    @speed_max = 10
    @turn_right = false
    @turn_left = false
    @engine_on = false
  end

  def update frame
    @angle -= @rotation_speed * @rotation_factor
    if @engine_on && @vx**2 + @vy**2 < @speed_max**2
      acc = 0.2
      @vx += acc * Math.cos(Math::PI * @angle / 180)
      @vy += acc * Math.sin(Math::PI * @angle / 180)

      @tile_x = 45 * (frame % 5 + 1)
    else
      @vx *= 0.98
      @vy *= 0.98
      @tile_x = 0
    end

    @x += @vx
    @y += @vy
    @rotation_factor = 0
    @engine_on = false
    if @x < 0 
      @vx = 0
      @x = 0
    elsif @x > 1280
      @vx = 0
      @x = 1280
    end
    if @y < 0
      @y = 0
      @vy = 0
    elsif @y > 720
      @y = 720
      @vy = 0
    end

    
  end
end

class Meteor
  attr_sprite
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

    @rotation_speed = 5 * rand()
    @speed = 5 * rand()
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

class Enemy
  attr_sprite
  def initialize
  end
end

class Star
  attr_sprite
  def initialize
  end
end




$game = Game.new
def tick args
  $game.state_manager args
  args.outputs.labels << [20,680,"FPS : #{$gtk.current_framerate.to_i}", 255, 255, 255,255]
end
