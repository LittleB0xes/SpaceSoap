class Enemy
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
    when 2
      @x = rand(1280)
      @y = 760
    when 3
      @x = 1320
      @y = rand(720)
    end
  end

  def rest_in_screen
    @x = 1320 if @x < -40
    @x = -40 if @x > 1320
    @y = 760 if @y < -40
    @y = -40 if @y > 760

  end
end


class PurpleFighter < Enemy
  attr_sprite
  attr_accessor :active, :speed, :theta, :enemy_type, :life

  def initialize scale
    super
    @w = 42 * scale
    @h = 39 * scale
    @tile_w = 40
    @tile_h = 38
    @tile_x = 0
    @tile_y = 0
    @path = "sprites/enemy2.png"
    @angle = 0

    

    @enemy_type = :fighter
    @theta = 2 * Math::PI * rand()
    @active = true
    @rotation_speed = 10 * rand()

    @max_speed = (2 + 4 * rand()) * scale
    @vx = 0
    @vy = 0
    @scale = scale
    @rotation_speed = 5
    @life = 3
    @fire_rate = 50 + rand(10) 
  end

  def update frame, player, bullets_list

    # Anlge between fighter and player
    theta = (360 + Math.atan2(player.y - @y, player.x - @x) * 180 / Math::PI).round
    theta = theta % 360
    squared_dist = (@x - player.x)**2 + (@y - player.y)**2
    if @angle > theta
      @angle -= @rotation_speed
    elsif @angle < theta
      @angle += @rotation_speed
    end
    @angle = @angle % 360

    if squared_dist < 10000
      acc = 0
    else
      acc = 0.2
    end


    if @vx**2 + @vy**2 < @max_speed**2
      acc = 0.2     #PurpleFighter acceleration
      @vx += acc * Math.cos(Math::PI * @angle / 180)
      @vy += acc * Math.sin(Math::PI * @angle / 180)
      @tile_x = @tile_w * (frame % 5)
    else
      @vx *= 0.98
      @vy *= 0.98
      @tile_x = 0
    end

    @x += @vx 
    @y += @vy 
   
    
    # Shoot when player is in fire window
    if (theta - @angle).abs < 4 && frame % @fire_rate == 0 
      alpha = 15 * Math::PI / 180
      bullets_list.push(Rocket.new(
        @x +  0.5 * @w * (1 + 2 * Math.cos(Math::PI * @angle / 180 + alpha)),
        @y +  0.5 * @w * (1 + 2 * Math.sin(Math::PI * @angle / 180 + alpha)),
        @angle,
        @scale)
      )
      bullets_list.push(Rocket.new(
        @x + 0.5 *  @w * (1 + 2 * Math.cos(Math::PI * @angle / 180 - alpha)),
        @y + 0.5 * @w * (1 + 2 * Math.sin(Math::PI * @angle / 180 - alpha)),
        @angle,
        @scale)
      )
    end
    
    rest_in_screen
  end

end


class Meteor < Enemy
  attr_sprite
  attr_accessor :active, :big_one, :speed, :theta, :enemy_type
  def initialize scale
    
    super
  
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

  def update frame, player, _
    @x += @speed * Math.cos(@theta)
    @y += @speed * Math.sin(@theta)
    @angle += @rotation_speed

    rest_in_screen
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

