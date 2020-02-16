
# Shooter
# TODO
#  - Add moving sky

class Game
  attr_accessor :bullets_list, :meteors_list
  def initialize
    @scale = 0.7
    @state = :level_one
    @player = Player.new(1280 / 2, 720 / 2, @scale)
    @galaxy_background = []
    @meteors_list = []
    @bullets_list = []
    @explosions_list = []
    50.times {@meteors_list.push(Meteor.new @scale)}
    100.times {@galaxy_background.push(Star.new @scale)}
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
    args.outputs.sprites << @galaxy_background.map do |star|
      star.sprite
    end
    args.outputs.sprites << @player.sprite
    args.outputs.sprites << @bullets_list.map do |bullet|
      bullet.sprite if bullet.active
    end

    args.outputs.sprites << @meteors_list.map do |meteor|
      meteor.sprite if meteor.active
    end
    
    args.outputs.sprites << @explosions_list.map do |explosion|
      explosion.sprite if explosion.active
    end

  end

  def game_update tick_count
    @player.update tick_count, @bullets_list
    @galaxy_background.each do |star|
      star.update tick_count
    end

    @bullets_list.each do |bullet|
      bullet.update
    end

    @meteors_list.each do |meteor|
      meteor.update
    end

    @explosions_list.each do |explosion|
      explosion.update tick_count
    end

    collision_bullet_enemy
    @bullets_list.delete_if{|bullet| !bullet.active}
    @meteors_list.delete_if{|meteor| !meteor.active}
    @explosions_list.reject!{|explosion| !explosion.active}
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
      if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.r1
        @player.fire_one = true
      else
        @player.fire_one = false
      end
    end
  end

  def collision_bullet_enemy
    @bullets_list.product(@meteors_list).find_all{|bullet, enemy| [bullet.x, bullet.y, bullet.w, bullet.h].intersect_rect?([enemy.x, enemy.y, enemy.w, enemy.h])}.map do |bullet, enemy|
      bullet.active = false
      enemy.active = false
      @explosions_list.push(Explosion.new(enemy.x, enemy.y, @scale))
    end
    @meteors_list.find_all{|meteor| [@player.x, @player.y, @player.w, @player.h].intersect_rect?([meteor.x, meteor.y, meteor.w, meteor.h])}.map do |meteor|
      meteor.active = false
      @explosions_list.push(Explosion.new(meteor.x, meteor.y, @scale))
      # @player.energy -= 1
    end
  end

end

class Player
  attr_sprite
  attr_accessor :engine_on, :rotation_factor, :fire_one
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
    @speed_max = 20 * scale
    @turn_right = false
    @turn_left = false
    @engine_on = false
    @fire_one = false
    @scale = scale
  end

  def update frame, bullets_list
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
    if @fire_one
      bullets_list.push(Bullet.new(
        @x + 0.5 * @w * (1 + Math.cos(Math::PI * @angle / 180)),
        @y + 0.5 * @h * (1 + Math.sin(Math::PI * @angle / 180)),
        @angle,
        @scale)
      )
    end

    @x += @vx
    @y += @vy
    @rotation_factor = 0
    @engine_on = false

    # Smooth stop when border approch
    offset = 50
    if (@x < offset && @vx  < 0) || (@x > 1280 - offset - @w && @vx > 0) || (@y < offset &&  @vy  < 0) || (@y > 720 - offset - @h &&  @vy > 0)
      @vx *= 0.7
      @vy *= 0.7
    end

    # Stay on th screen please !
    if @x < 0 
      @vx = 0 
      @x = 0
    elsif @x > 1280 - @w
      @vx = 0
      @x = 1280 - @w
    end
    if @y < 0
      @y = 0
      @vy = 0
    elsif @y > 720 - @h
      @y = 720 - @h
      @vy = 0
    end
  end
end

class Bullet
  attr_sprite
  attr_accessor :active
  def initialize x, y, angle, scale
    @x = x
    @y = y
    @w = 10 * scale
    @h = 10 * scale
    @tile_w = 10
    @tile_h = 10
    @angle = angle
    @tile_x = 0
    @tile_y = 0
    @path = "sprites/bullet1.png"

    @speed_max = 15 * scale
    @active = true
  end
  def update
    @x += @speed_max * Math.cos(Math::PI * @angle / 180)
    @y += @speed_max * Math.sin(Math::PI * @angle / 180)
    @active = false if @x < -@w || @x > 1280 || @y < -@h || @y > 720
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

class Enemy
  attr_sprite
  def initialize
  end
end

class Star
  attr_sprite
  def initialize scale
    @x = 1280 * rand()
    @y = 720 * rand()
    dist_scale = 1 - 0.5 * rand()
    @w = 16 * dist_scale * scale
    @h = 16 * dist_scale * scale
    @path = "sprites/star.png"
    @r = 255
    @g = 255 * rand()
    @b = 255
    @a = 255 * rand()
    @a_max = 255 * rand()
    @g_max = 255 * rand()
    @phi = Math::PI * rand()
    @vx = 0.1
    @vy = 0.1
  end
  def update frame
    # Star luminosity oscillation
    @a = @a_max * (0.7 + 0.3 * Math.cos(frame / 60 + @phi))
    @g = @g_max * (0.7 + 0.3 * Math.cos(frame / 60))
    # Star mouvement around a center
    @x += 0.309 
    @y += 0.359

    @x = 0 if @x > 1280
    @y = 0 if @y > 720

  end
end

class Explosion
  
  attr_sprite
  attr_accessor :active
  
  def initialize x, y, scale
    @x = x
    @y = y
    @w = 32 * scale
    @h = 32 * scale
    @path = "sprites/explosion.png"
    @tile_x = 0
    @tile_y = 0
    @tile_w = 32
    @tile_h = 32
    @angle = 360 * rand()

    @frame_number = 0
    @active = true
  end

  def update frame

    @tile_x = 32 * @frame_number
    @frame_number += 1 if frame % 2 == 0
    @active = false if @frame_number > 6

  end

end



$game = Game.new
def tick args
  $game.state_manager args
  args.outputs.labels << [20,680,"FPS : #{$gtk.current_framerate.to_i}", 255, 255, 255,255]
  args.outputs.labels << [20,660,"Meteors : #{$game.meteors_list.length}", 255, 255, 255,255]
  args.outputs.labels << [20,640,"Bullets : #{$game.bullets_list.length}", 255, 255, 255,255]
end
