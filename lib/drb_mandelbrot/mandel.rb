class DRbMandelbrot::Mandel

  def initialize points, image, max
    @points = points
    @image  = image
    @max    = max
  end

  def run
    loop do
      height, width, y = @points.deq

      mandel_row height, width, y
    end
  end

  def mandel z, max
    c = z

    max.times do |score|
      z = (z ** 2) + c

      break score if z.magnitude > 2
    end
  end

  def mandel_row height, width, y
    i = scale y, height, 3, -1.5

    row = width.times.map do |x|
      r = scale x, width, 3, -2

      c = Complex r, i

      score = mandel c, @max

      score
    end

    p fill_row: y
    @image.fill_row y, row
  end

  def scale val, input_range, output_range, offset
    val.to_f / input_range * output_range + offset
  end

end

