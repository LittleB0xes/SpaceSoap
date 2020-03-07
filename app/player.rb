
class Player
  attr_sprite
  attr_accessor :engine_on, :rotation_factor, :fire_one, :fire_two, :fire_three, :shield, :energy_level, :score, :alt_weapon, :alt_amo

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
    @path = "sprites/spaceship.png"
    
    # Other player properties
    @scale = scale
    @vx = 0
    @vy = 0
    @rotation_factor = 0
    @rotation_speed = 5
    @speed_max = 10 * scale
    @max_energy = 100
    @energy_level = @max_energy
    @score = 0
    @turn_right = false
    @turn_left = false
    @engine_on = false
    @fire_one = false

    @fire_two = false
    @alt_weapon = :none
    @alt_amo = 0

    @shield = Shield.new @x, @y, @w, @h, @scale
  end

  def update args, bullets_list
    @angle -= @rotation_speed * @rotation_factor
    if @engine_on && @vx**2 + @vy**2 < @speed_max**2
      acc = 0.2
      @vx += acc * Math.cos(Math::PI * @angle / 180)
      @vy += acc * Math.sin(Math::PI * @angle / 180)

      @tile_x = 45 * (args.tick_count % 5 + 1)
    else
      @vx *= 0.98
      @vy *= 0.98
      @tile_x = 0
    end
    if @fire_one && !@shield.shield_on
      args.outputs.sounds << "sounds/blaster.wav"

      bullets_list.push(Bullet.new(
                         @x + 0.5 * @w * (1 + 1.5 * Math.cos(Math::PI * @angle / 180)),
                         @y + 0.5 * @h * (1 + 1.5 * Math.sin(Math::PI * @angle / 180)),
        @angle,
        @scale)
      )
    end


    @x += @vx
    @y += @vy
    @rotation_factor = 0
    @engine_on = false

    # infinte screen
    if @x < -@w * @scale 
      @x = 1280
    elsif @x > 1280
      @x = -@w * @scale
    end
    if @y < -@h * @scale
      @y = 720
    elsif @y > 720
      @y = -@h * @scale
    end

    @shield.update(@x, @y, args.tick_count) 
  end
  
  def energy_up
    @energy_level = @max_energy
  end

end

class Shield
  attr_sprite
  attr_accessor :shield_level, :shield_on
  def initialize player_x, player_y, player_w, player_h, scale
    @w = 75 * scale
    @h = 75 * scale
    @tile_w = 75
    @tile_h = 75
    @tile_x = 0
    @tile_y = 0
    @angle = 0
    @path = "sprites/shield.png"
    @delta_x = player_w / 2 - @w / 2
    @delta_y = player_h / 2 - @h / 2
    @x = player_x + @delta_x
    @y = player_y + @delta_y
    @a = 255

    @shield_on = false
    @max_shield = 100
    @shield_level = @max_shield
    @scale = scale
  end
  
  def update player_x, player_y, frame
    @tile_x = (frame / 4).to_i % 4 * @tile_w
    @x = player_x + @delta_x
    @y = player_y + @delta_y
    @a = 225 + 12 * (1 +  Math.cos(frame / 10))
    @angle += 1
    @shield_on = false if @shield_level <= 0

    if @shield_on && @shield_level >= 0 
     @shield_level -= 1
    elsif !@shield_on && @shield_level <= @max_shield
      @shield_level += 0.01
    end
  end

  def shield_up
    @shield_level = @max_shield
  end
end
