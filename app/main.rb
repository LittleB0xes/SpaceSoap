require 'app/enemies.rb'
require 'app/objects.rb'
require 'app/player.rb'

class Game
  attr_accessor :bullets_list, :enemies_list, :state
  def initialize
    @scale = 0.6
    @state = :intro
    @player = Player.new(1280 / 2, 720 / 2, @scale)
    @galaxy_background = []
    @enemies_list = []
    @bullets_list = []
    @explosions_list = []
    50.times {@enemies_list.push(Meteor.new @scale)}
    100.times {@galaxy_background.push(Star.new @scale)}
  end



  def state_manager args
    control_manager args
    case @state
    when :intro
      intro_render args
    when :level_one
      game_update args.tick_count
      game_render args
      display_info args
      @state = :end if @player.energy_level <= 0
    when :end
      end_render args
      @galaxy_background.each {|star| star.update args.tick_count}

      # Reset game data
      @player = Player.new(1280 / 2, 720 / 2, @scale)
      @enemies_list = []
      @bullets_list = []
      @explosions_list = []
      50.times {@enemies_list.push(Meteor.new @scale)}
    when :info
    end
  end
  
  def intro_render args
      @galaxy_background.map {|star| args.outputs.sprites << star.sprite}
      args.outputs.labels << {
        x: 640,
        y: 360,
        text: "Space shooter",
        size_enum: 10,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/8-bit-pusab.ttf"
      }
      alpha = 125 * (1.25 + 0.75 * Math.cos(args.tick_count / 10))
      args.outputs.labels << {
        x: 640,
        y: 300,
        text: "Press start",
        size_enum: 0,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: alpha,
        font: "fonts/8-bit-pusab.ttf"
      }
  end

  def end_render args
      @galaxy_background.map {|star| args.outputs.sprites << star.sprite}
      args.outputs.labels << {
        x: 640,
        y: 360,
        text: "Game Over",
        size_enum: 10,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: 255,
        font: "fonts/8-bit-pusab.ttf"
      }
      alpha = 125 * (1.25 + 0.75 * Math.cos(args.tick_count / 10))
      args.outputs.labels << {
        x: 640,
        y: 300,
        text: "Press start",
        size_enum: 0,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: alpha,
        font: "fonts/8-bit-pusab.ttf"
      }
  end

  def display_info args
    bar_color = Array.new(3,0)
    if @player.energy_level > 50
      bar_color = [67, 102, 194]
    elsif @player.energy_level > 20
      bar_color = [247, 188, 62]
    else 
      bar_color =[170, 75, 109]
    end
   # background_bar1 = {
   #   x: 20,
   #   y: 640,
   #   w: 100,
   #   h: 16,
   #   r: 21,
   #   g: 15,
   #   b: 10,
   #   a: 255
   # }.solid

    energy_bar = {
      x: 20,
      y: 640,
      w: @player.energy_level,
      h: 16,
      r: bar_color[0],
      g: bar_color[1],
      b: bar_color[2],
      a: 255
    }.solid

    if @player.shield.shield_level > 50
      bar_color = [67, 102, 194]
    elsif @player.shield.shield_level > 20
      bar_color = [247, 188, 62]
    else 
      bar_color =[170, 75, 109]
    end
   # background_bar2 = {
   #   x: 20,
   #   y: 608,
   #   w: 100,
   #   h: 16,
   #   r: 21,
   #   g: 15,
   #   b: 10,
   #   a: 255
   # }.solid

    shield_bar = {
      x: 20,
      y: 608,
      w: @player.shield.shield_level,
      h: 16,
      r: bar_color[0],
      g: bar_color[1],
      b: bar_color[2],
      a: 255
    }.solid

    score = {
      x: 1200,
      y: 640,
      text: "#{@player.score}",
      r: 255,
      g: 255,
      b: 255,
      font: "fonts/8-bit-pusab.ttf"
    }.label
      
   # args.outputs.primitives << [background_bar1, energy_bar, background_bar2, shield_bar, score] 
    args.outputs.primitives << [energy_bar, shield_bar, score] 
    
  end

  def game_render args
    args.outputs.sprites << @galaxy_background.map do |star|
      star.sprite
    end


    args.outputs.sprites << @player.sprite
    if @player.shield.shield_on
      args.outputs.sprites << @player.shield.sprite
    end


    args.outputs.sprites << @bullets_list.map do |bullet|
      bullet.sprite if bullet.active
    end

    args.outputs.sprites << @enemies_list.map do |meteor|
      meteor.sprite if meteor.active
    end
    
    args.outputs.sprites << @explosions_list.map do |explosion|
      explosion.sprite if explosion.active
    end
    
    debug_outputs args

  end

  def game_update tick_count
    @player.update tick_count, @bullets_list
    @galaxy_background.each do |star|
      star.update tick_count
    end

    @bullets_list.each do |bullet|
      bullet.update
    end

    @enemies_list.each do |meteor|
      meteor.update
    end

    @explosions_list.each do |explosion|
      explosion.update tick_count
    end

    collision_bullet_enemy
    @bullets_list.delete_if{|bullet| !bullet.active}
    @enemies_list.delete_if{|meteor| !meteor.active}
    @explosions_list.reject!{|explosion| !explosion.active}
  end
  
  def control_manager args
    case @state
    when :intro, :end
      if args.inputs.keyboard.key_down.space || args.inputs.controller_one.key_down.start
        @state = :level_one
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

      if args.inputs.keyboard.key_held.w || args.inputs.controller_one.key_down.x
        @player.shield.shield_on = true 
      elsif !args.inputs.keyboard.key_held.w #|| args.inputs.controller_one.key_down.x
        @player.shield.shield_on = false 
      end
    end
  end

  def collision_bullet_enemy
    @bullets_list.product(@enemies_list).find_all{|bullet, enemy| [bullet.x, bullet.y, bullet.w, bullet.h].intersect_rect?([enemy.x, enemy.y, enemy.w, enemy.h])}.map do |bullet, enemy|
      bullet.active = false

      if enemy.enemy_type == :meteor      # If big meteor then fragmentation
        @enemies_list.push(enemy.fragmentation)
        @player.score += 1
      else
        enemy.active = false
        @player.score += 1
      end
      @explosions_list.push(Explosion.new(enemy.x, enemy.y, @scale))
    end

    if @player.shield.shield_on && @player.shield.shield_level > 0
      @enemies_list.find_all{|meteor| [@player.x + @player.w / 2, @player.y + @player.h / 2, @player.shield.h].intersect_circle?( [meteor.x + meteor.w / 2, meteor.y + meteor.h / 2, meteor.w / 2])}.map do |meteor|
        meteor.active = false
        @explosions_list.push(Explosion.new(meteor.x, meteor.y, @scale))
      end
    else
      @enemies_list.find_all{|meteor| [@player.x, @player.y, @player.w, @player.h].intersect_rect?([meteor.x, meteor.y, meteor.w, meteor.h])}.map do |meteor|
        meteor.active = false
        @explosions_list.push(Explosion.new(meteor.x, meteor.y, @scale))
        @player.energy_level -= 5
      end
    end
  end
  
  def debug_outputs args
    args.outputs.labels << [20,80,"FPS : #{$gtk.current_framerate.to_i}", 255, 255, 255,255]
    args.outputs.labels << [20,60,"Meteors : #{@enemies_list.length}", 255, 255, 255,255]
  end
end

class Array
  def intersect_circle? circle
    (self[0] - circle[0])**2 + (self[1] - circle[1])**2 < (self[2] - circle[2])**2 ? true : false
  end
end


$game = Game.new

def tick args
  args.outputs.static_background_color = [21,15,10]
  args.outputs.solids << [0,0,1280,720,21,15,10,255]
  $game.state_manager args
end
