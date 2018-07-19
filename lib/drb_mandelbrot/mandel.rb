class DRbMandelbrot::Mandel

  def initialize points, image, max
    @points = points
    @image  = image
    @max    = max
  end

  def run
    loop do
      y, x, c = @points.deq

      score = mandel c, @max

      @image.fill y, x, score
    end
  end

  def mandel z, max
    c = z

    max.times do |score|
      z = (z ** 2) + c

      break score if z.magnitude > 2
    end
  end

end

