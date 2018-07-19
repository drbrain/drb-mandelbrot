class DRbMandelbrot::Image
  def initialize width, height
    @image = Array.new height do
      Array.new width
    end

    @filled = 0
    @total  = width * height
  end

  def complete?
    @total == @filled
  end

  def fill y, x, score
    @image[y][x] = score
    @filled += 1
  end

  def draw output
    Thread.pass until complete?

    @image.each do |row|
      line = row.map do |score|
        "\e[48;5;#{232 + score}m "
      end

      line << "\e[0m"

      puts line.join
    end
  end
end
