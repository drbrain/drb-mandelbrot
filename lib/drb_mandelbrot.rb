require 'complex'
require 'drb'
require 'pp'
require 'thread'

class DRbMandelbrot

  attr_accessor :image

  def initialize width, height, max: 24
    @width  = width
    @height = height
    @max    = max

    @points = Queue.new
    @image  = nil
    @pids   = []
  end

  def start_mandels
    drb_points = DRb::DRbObject.new @points
    drb_image  = DRb::DRbObject.new @image

    8.times do
      start_mandel drb_points, drb_image
    end
  end

  def start_mandel drb_points, drb_image
    pid = fork do
      $0 = "drb_mandelbrot: mandel"

      DRb.start_service nil, nil

      Thread.new do
        Thread.current.report_on_exception = false

        mandel = DRbMandelbrot::Mandel.new drb_points, drb_image, @max
        mandel.run
      end

      DRb.thread.join
    end

    @pids << pid
  end

  def start_image
    drb_self = DRb::DRbObject.new self

    pid = fork do
      $0 = "drb_mandelbrot: image"

      image = DRbMandelbrot::Image.new @width, @height

      DRb.start_service nil, image

      drb_image = DRb::DRbObject.new image

      # LOL HACKS!!
      drb_self.image = drb_image

      DRb.thread.join
    end

    @pids << pid

    # LOL HACKS!!
    sleep 0.001 until @image
  end

  def draw
    DRb.start_service nil, nil

    Thread.new do
      DRb.thread.join
    end

    start_image
    start_mandels

    @height.times do |y|
      i = scale y, @height, 3, -1.5

      @width.times do |x|
        r = scale x, @width, 3, -2

        c = Complex r, i

        @points.enq [y, x, c]
      end
    end

    @image.draw $stdout
  end

  def shutdown
    @pids.each do |pid|
      Process.kill :TERM, pid
    end

    Process.waitall
  end

  def scale(val, input_range, output_range, offset)
    val.to_f / input_range * output_range + offset
  end

end

require 'drb_mandelbrot/image'
require 'drb_mandelbrot/mandel'
