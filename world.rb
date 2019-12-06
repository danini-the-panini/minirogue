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
  attr_reader :tiles, :width, :height

  def initialize(width, height)
    @width = width
    @height = height
    @tiles = height.times.map do
      width.times.map { Tile.new('W', false) }
    end
  end

  def generate_room(top, left, width, height)
    width.times do |i|
      height.times do |j|
        @tiles[i + top][j + left] = Tile.new('.', true)
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
