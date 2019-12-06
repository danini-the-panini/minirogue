require_relative 'world'

class Generator
  attr_accessor :width, :height, :room_width, :room_height, :areas

  DIRECTIONS = [[-1, 0], [0, +1], [+1, 0], [0, -1]]

  def initialize(width, height, room_width, room_height)
    @width = width
    @height = height
    @room_width = room_width
    @room_height = room_height

    @areas = width.times.map do
      height.times.map { nil }
    end
  end

  def generate
    initial_row = height / 2
    initial_col = width / 2
    initial_area = areas[initial_row][initial_col] = Area.new(:room, initial_row, initial_col)

    fresh_areas = [initial_area]

    until fresh_areas.empty?
      next_fresh_areas = []
      fresh_areas.each do |area|
        DIRECTIONS.each do |row_offset, col_offset|
          next_row = area.row + row_offset
          next_col = area.col + col_offset
          next unless in_bounds?(next_row, next_col)
          next unless @areas[next_row][next_col].nil?

          new_type = rand > 0.5 ? :room : :passage
          new_area = @areas[next_row][next_col] = Area.new(new_type, next_row, next_col)

          DIRECTIONS.each_with_index do |(row_offset2, col_offset2), dir_index|
            next_row2 = new_area.row + row_offset2
            next_col2 = new_area.col + col_offset2
            unless in_bounds?(next_row2, next_col2)
              new_area.connections[dir_index] = :wall
              next
            end

            other_area = @areas[next_row2][next_col2]
            next if other_area.nil?

            opp_dir = (dir_index + 2) % 4

            connection = rand > 0.5 ? :wall : :open

            new_area.connections[dir_index] = connection
            other_area.connections[opp_dir] = connection
          end

          next_fresh_areas << new_area
        end
      end
      fresh_areas = next_fresh_areas
    end
  end

  def in_bounds?(row, col)
    row >= 0 && row < height && col >= 0 && col < width
  end

  def print_map
    print ' '
    @areas[0].each do |area|
      print area.connection_s(0)
      print ' '
    end
    puts
    @areas.each do |row|
      print row[0].connection_s(3)
      row.each do |area|
        print area.to_s
        print area.connection_s(1)
      end
      puts
      print ' '
      row.each do |area|
        print area.connection_s(2)
        print ' '
      end
      puts
    end
    nil
  end

  class Area
    attr_accessor :type, :row, :col, :connections

    def initialize(type, row, col)
      @type = type
      @row = row
      @col = col
      @connections = [nil, nil, nil, nil]
    end

    def to_s
      case type
      when :room then 'R'
      when :passage then 'P'
      else '.'
      end
    end

    def connection_s(i)
      case connections[i]
      when :wall then '#'
      when :open then 'o'
      else '.'
      end
    end
  end

  def create_world
    world = World.new(width * room_width + width + 1, height * room_height + height + 1)
    @areas.each do |row|
      row.each do |area|
        if area.type == :room
          world.generate_room(1 + area.row * (room_height + 1), 1 + area.col * (room_width + 1), room_width, room_height)
        end

        if area.connections[1] == :open
          world.generate_passage(
            1 + area.row * (room_height + 1) + (room_height / 2), 1 + area.col * (room_width + 1) + (room_width / 2),
            1 + area.row * (room_height + 1) + (room_height / 2), 1 + (area.col + 1) * (room_width + 1) + (room_width / 2)
          )
        end
        if area.connections[2] == :open
          world.generate_passage(
            1 + area.row * (room_height + 1) + (room_height / 2), 1 + area.col * (room_width + 1) + (room_width / 2),
            1 + (area.row + 1) * (room_height + 1) + (room_height / 2), 1 + area.col * (room_width + 1) + (room_width / 2)
          )
        end
      end
    end
    world
  end
end
