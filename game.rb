#! /usr/bin/env ruby

require 'io/console'

class Player
  attr_accessor :row, :col

  def initialize(row, col)
    @row = row
    @col = col
  end

  def draw
    print '@'
  end
end

class Tile
  attr_reader :traversable

  def initialize(char, traversable)
    @explored = false
    @traversable = traversable
    @char = char
  end

  def draw
    print @char
  end
end

class Game
  def initialize
    @world = 24.times.map do
      80.times.map { Tile.new('.', true) }
    end

    (37..42).each do |r|
      @world[10][r] = Tile.new('W', false)
    end

    @player = Player.new(12, 40)
    @running = true
  end

  def clear_screen
    print "\033[3J"
    print "\033[0;0H"
  end

  def draw
    clear_screen
    @world.each_with_index do |tiles, row|
      tiles.each_with_index do |tile, col|
        if @player.row == row && @player.col == col
          @player.draw
        else
          tile.draw
        end
      end
      puts
    end
  end

  def handle_input
    ch = STDIN.getch

    case ch
    when 'q' then @running = false
    when 'h' then move_player_left
    when 'j' then move_player_down
    when 'k' then move_player_up
    when 'l' then move_player_right
    end
  end

  def move_player_up
    if tile(@player.row-1, @player.col)&.traversable
      @player.row -= 1
    end
  end

  def move_player_down
    if tile(@player.row+1, @player.col)&.traversable
      @player.row += 1
    end
  end

  def move_player_left
    if tile(@player.row, @player.col-1)&.traversable
      @player.col -= 1
    end
  end

  def move_player_right
    if tile(@player.row, @player.col+1)&.traversable
      @player.col += 1
    end
  end

  def tile(row, col)
    return nil if row < 0 || col < 0
    @world.dig(row, col)
  end

  def run
    draw
    while @running
      handle_input
      draw
    end
  end
end

Game.new.run
