class Projectile
  attr_sprite
  attr_accessor :active, :exploded
  def initialize x, y, angle, scale
    @active = true
    @exploded = false
  end

  def update _
    @x += @speed * Math.cos(Math::PI * @angle / 180)
    @y += @speed * Math.sin(Math::PI * @angle / 180)
    @active = false if @x < -@w || @x > 1280 || @y < -@h || @y > 720
  end
end

class Bullet < Projectile
  def initialize x, y, angle, scale
    super
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
  end

  def update _
    super
  end
end

class Rocket < Projectile
  attr_sprite
  attr_accessor :active
  def initialize x, y, angle, scale
    super
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
  end
  def update _
    super
  end
end

class Fireball < Projectile
  attr_sprite
  attr_accessor :active
  def initialize x, y, angle, scale
    super
    @w = 18 * scale
    @h = 16 * scale
    @angle = angle
    @x = x + @w / 2
    @y = y + @h / 2
    @path = "sprites/bullet3.png"
    @tile_w = 18
    @tile_h = 16

    @speed = 8 * scale
  end

  def update _
    super
  end
end

class MultiRocket < Projectile
  attr_sprite
  attr_accessor :multi
  def initialize x, y, angle, scale
    super
    @w = 18 * scale
    @h = 16 * scale
    @angle = angle
    @x = x + @w / 2
    @y = y + @h / 2
    @tile_h = 18
    @tile_w = 16
    @path = "sprites/bullet3.png"

    @multi = false
    @speed = 8 * scale
  end

  def update player
    super

    dist_squared = (@x - player.x)**2 + (@y - player.y)**2
    if dist_squared < 10000 && !@multi
      @exploded = true
    end
  end

end



class Bonus
  attr_sprite
  attr_accessor :active
  def initialize x, y, angle, scale
    @x = x
    @y = y
    @w = 24
    @h = 19
    @angle = angle + [-1, 1].sample * rand(30)
    @type = [:energy, :shield].sample
    case @type
    when :energy
      @path = "sprites/power-up-4.png"
    when :shield
      @path = "sprites/power-up-5.png"
    end

    @speed = 5 * rand() * scale
    @active = true
    @theta = @angle
    @rotation_speed = (5 + rand(@speed)) * [-1, 1].sample
  end

  def effect player
    case @type
    when :energy
      player.energy_up
    when :shield
      player.shield.shield_up
    end
  end

  def update _
    @x += @speed * Math.cos(Math::PI * @theta / 180)
    @y += @speed * Math.sin(Math::PI * @theta / 180)
    @angle += @rotation_speed
    @active = false if @x < -@w || @x > 1280 || @y < -@h || @y > 720
  end
end

class Star
  attr_sprite
  def initialize scale, args
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
    args.outputs.static_sprites << self
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
