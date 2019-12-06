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

class World
  attr_reader :tiles

  def initialize(width, height)
    @width = width
    @height = height
    @tiles = height.times.map do
      width.times.map { Tile.new('W', false) }
    end

    generate_room(12, 40)
    generate_passage(12, 40, 20, 60)
  end

  def generate_room(r, c)
    (r-2..r+2).each do |r|
      (c-2..c+2).each do |c|
        @tiles[r][c] = Tile.new('.', true)
      end
    end
  end

  def generate_passage(r1, c1, r2, c2)
    (r1..r2).each do |r|
      @tiles[r][c1] = Tile.new('.', true)
    end
    (c1..c2).each do |c|
      @tiles[r2][c] = Tile.new('.', true)
    end
  end

  def [](r, c)
    return nil if r < 0 || c < 0
    @tiles.dig(r, c)
  end

  def []=(r, c, tile)
    @tiles[r][c] = tile
  end
end

class Game
  def initialize
    @world = World.new(100, 50)

    @player = Player.new(12, 40)
    @running = true
  end

  def clear_screen
    print "\033[3J"
    print "\033[0;0H"
  end

  def draw
    clear_screen
    @world.tiles.each_with_index do |tiles, row|
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
    if @world[@player.row-1, @player.col]&.traversable
      @player.row -= 1
    end
  end

  def move_player_down
    if @world[@player.row+1, @player.col]&.traversable
      @player.row += 1
    end
  end

  def move_player_left
    if @world[@player.row, @player.col-1]&.traversable
      @player.col -= 1
    end
  end

  def move_player_right
    if @world[@player.row, @player.col+1]&.traversable
      @player.col += 1
    end
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
