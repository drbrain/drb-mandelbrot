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

    @lines = Queue.new
    @image = nil
    @pids  = []
  end

  def start_mandels
    drb_lines = DRb::DRbObject.new @lines
    drb_image = DRb::DRbObject.new @image

    8.times do
      start_mandel drb_lines, drb_image
    end
  end

  def start_mandel drb_lines, drb_image
    pid = fork do
      $0 = "drb_mandelbrot: mandel"

      DRb.start_service nil, nil

      Thread.new do
        Thread.current.report_on_exception = false

        mandel = DRbMandelbrot::Mandel.new drb_lines, drb_image, @max
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

      image = DRbMandelbrot::Image.new @height

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
      @lines.enq [@height, @width, y]
    end

    @image.draw $stdout
  end

  def shutdown
    @pids.each do |pid|
      Process.kill :TERM, pid
    end

    Process.waitall
  end

end

require 'drb_mandelbrot/image'
require 'drb_mandelbrot/mandel'
