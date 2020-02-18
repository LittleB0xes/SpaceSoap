
class Player
  attr_sprite
  attr_accessor :engine_on, :rotation_factor, :fire_one, :shield_on, :shield
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
    @turn_right = false
    @turn_left = false
    @engine_on = false
    @fire_one = false
    @shield_on = false
    @shield = Shield.new @x, @y, @w, @h, @scale
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
    if @fire_one && !@shield_on
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

    @shield.update(@x, @y, frame) if @shield_on
  end
end

class Shield
  attr_sprite
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

    @scale = scale
  end
  
  def update player_x, player_y, frame
    @tile_x = (frame / 4).to_i % 4 * @tile_w
    @x = player_x + @delta_x
    @y = player_y + @delta_y
    @angle += 1
  end
end
