class DRbMandelbrot::Image
  def initialize height
    @image = Array.new height

    @filled_mutex = Mutex.new
    @filled = 0
    @total  = height
  end

  def complete?
    @total == @filled
  end

  def fill_row y, row
    p filling: y
    @image[y] = row

    @filled_mutex.synchronize do
      @filled += 1
    end
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

    nil
  end
end
