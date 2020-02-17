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
      @galaxy_background.each {|star| star.update args.tick_count}
    when :level_one
      game_update args.tick_count
      game_render args
    when :end
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
        text: "Press Fire to start",
        size_enum: 0,
        alignment_enum: 1,
        r: 255,
        g: 255,
        b: 255,
        a: alpha,
        font: "fonts/8-bit-pusab.ttf"
      }
  end

  def game_render args
    args.outputs.sprites << @galaxy_background.map do |star|
      star.sprite
    end
    args.outputs.sprites << @player.sprite
    args.outputs.sprites << @bullets_list.map do |bullet|
      bullet.sprite if bullet.active
    end

    args.outputs.sprites << @enemies_list.map do |meteor|
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
    when :intro
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
    end
  end

  def collision_bullet_enemy
    @bullets_list.product(@enemies_list).find_all{|bullet, enemy| [bullet.x, bullet.y, bullet.w, bullet.h].intersect_rect?([enemy.x, enemy.y, enemy.w, enemy.h])}.map do |bullet, enemy|
      bullet.active = false
      enemy.active = false
      @explosions_list.push(Explosion.new(enemy.x, enemy.y, @scale))
    end
    @enemies_list.find_all{|meteor| [@player.x, @player.y, @player.w, @player.h].intersect_rect?([meteor.x, meteor.y, meteor.w, meteor.h])}.map do |meteor|
      meteor.active = false
      @explosions_list.push(Explosion.new(meteor.x, meteor.y, @scale))
      # @player.energy -= 1
    end
  end

end



$game = Game.new

def tick args
  args.outputs.static_background_color = [21,15,10]
  args.outputs.solids << [0,0,1280,720,21,15,10,255]
  $game.state_manager args
  args.outputs.labels << [20,680,"FPS : #{$gtk.current_framerate.to_i}", 255, 255, 255,255]
  args.outputs.labels << [20,660,"Meteors : #{$game.enemies_list.length}", 255, 255, 255,255]
  args.outputs.labels << [20,640,"Bullets : #{$game.bullets_list.length}", 255, 255, 255,255]
end
