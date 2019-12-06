#! /usr/bin/env ruby

require 'io/console'

require_relative 'world'
require_relative 'generator'

class Terminal
  def hide_cursor
    print "\033[?25l"
  end

  def show_cursor
    print "\033[?25h"
  end

  def clear_screen
    clear_rect(0, 0, width, height)
    reset_cursor
  end

  def clear_rect(top, left, w, h)
    fill_rect(top, left, w, h, ' ')
  end

  def fill_rect(top, left, w, h, char)
    h.times do |i|
      move_cursor(top + i, left)
      print char * w
    end
  end

  def reset_cursor
    print "\033[3J"
    move_cursor(0, 0)
  end

  def width
    80
  end

  def height
    24
  end

  def size
    [width, height]
  end

  def move_cursor(top, left)
    print "\033[#{top};#{left}H"
  end

  def draw_box(top, left, w, h)
    move_cursor(top, left)
    print "╭#{'─' * (w - 2)}╮"

    [0, (h - 2)].max.times do |i|
      move_cursor(top + i + 1, left)
      print '│'
      move_cursor(top + i + 1, left + w - 1)
      print '│'
    end

    move_cursor(top + h - 1, left)
    print "╰#{'─' * (w - 2)}╯"
  end
end

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

class Game
  attr_accessor :terminal, :world, :player, :running, :world_viewport

  def initialize
    @terminal = Terminal.new
    generator = Generator.new(11, 11, 5, 5)
    generator.generate
    @world = generator.create_world

    @player = Player.new(world.height / 2, world.width / 2)
    @running = true

    @world_viewport = [2, 22, terminal.width - 22, terminal.height - 2]
  end

  def draw_initial
    terminal.clear_screen
    terminal.hide_cursor

    terminal.draw_box(1, 1, 20, terminal.height)
    terminal.draw_box(1, 21, terminal.width - 20, terminal.height)
    terminal.fill_rect(*world_viewport, '#')
  end

  def clear_world
    terminal.clear_rect(*world_viewport)
  end

  def draw_world
    clear_world

    top, left, w, h = world_viewport

    world_top = player.row - (h / 2)
    world_left = player.col - (w / 2)

    h.times do |row|
      w.times do |col|
        terminal.move_cursor(top + row, left + col)
        r = world_top + row
        c = world_left + col
        if player.row == r && player.col == c
          player.draw
        else
          world[r, c]&.draw
        end
      end
    end
    # world.tiles.each_with_index do |tiles, row|
    #   tiles.each_with_index do |tile, col|
    #     if player.row == row && player.col == col
    #       player.draw
    #     else
    #       tile.draw
    #     end
    #   end
    #   puts
    # end
  end

  def handle_input
    ch = STDIN.getch

    case ch
    when 'q' then self.running = false
    when 'h' then move_player_left
    when 'j' then move_player_down
    when 'k' then move_player_up
    when 'l' then move_player_right
    end
  end

  def move_player_up
    if world[player.row-1, player.col]&.traversable
      player.row -= 1
    end
  end

  def move_player_down
    if world[player.row+1, player.col]&.traversable
      player.row += 1
    end
  end

  def move_player_left
    if world[player.row, player.col-1]&.traversable
      player.col -= 1
    end
  end

  def move_player_right
    if world[player.row, player.col+1]&.traversable
      player.col += 1
    end
  end

  def run
    draw_initial
    draw_world
    while running
      handle_input
      draw_world
    end
    terminal.clear_screen
    terminal.show_cursor
  end
end

Game.new.run
