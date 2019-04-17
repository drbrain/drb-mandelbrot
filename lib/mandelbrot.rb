require 'complex'
require 'pp'

class Mandelbrot

  attr_reader :image

  def initialize width, height
    @width  = width
    @height = height

    @image = Array.new @height do
      Array.new @width
    end
  end

  # main drawing method
  def draw
    @height.times do |y|
      i = scale y, @height, 3, -1.5

      @width.times do |x|
        r = scale x, @width, 3, -2

        c = Complex r, i

        score = mandel c, 24

        @image[y][x] = score
      end
    end
  end

  def scale val, input_range, output_range, offset
    val.to_f / input_range * output_range + offset
  end

  def mandel z, max
    c = z

    max.times do |score|
      z = (z ** 2) + c

      break score if z.magnitude > 2
    end
  end

end

