


class Bullet

  attr_sprite
  attr_accessor :active
  def initialize x, y, angle, scale
    @w = 10 * scale
    @h = 10 * scale
    @x = x - @w / 2
    @y = y - @h / 2
    @tile_w = 10
    @tile_h = 10
    @angle = angle
    @tile_x = 0
    @tile_y = 0
    @path = "sprites/bullet1.png"

    @speed = 15 * scale
    @active = true
  end
  def update
    @x += @speed * Math.cos(Math::PI * @angle / 180)
    @y += @speed * Math.sin(Math::PI * @angle / 180)
    @active = false if @x < -@w || @x > 1280 || @y < -@h || @y > 720
  end
end

class Rocket
  attr_sprite
  attr_accessor :active
  def initialize x, y, angle, scale
    @w = 17 * scale
    @h = 8 * scale
    @angle = angle
    @x = x - @w / 2 
    @y = y - @h / 2
    @path = "sprites/bullet2.png"
    @tile_w = 17
    @tile_h = 8
    @tile_x = 0
    @tile_y = 0

    @speed = 10 * scale
    @active = true
  end
  def update
    @x += @speed * Math.cos(Math::PI * @angle / 180)
    @y += @speed * Math.sin(Math::PI * @angle / 180)
    @active = false if @x < -@w || @x > 1280 || @y < -@h || @y > 720
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

