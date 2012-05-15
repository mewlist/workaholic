require 'thread'

class Workaholic
  class RunningError < StandardError; end
  attr_reader :queue
  attr_reader :state
  attr_reader :running

  def initialize
    @queue = Queue.new
    @state = :stopped
    @threads ||= []
    @running = 0
  end

  def start( thread_count = 2 )
    raise RunningError unless state == :stopped

    @state = :running
    thread_count.times do |i|
      t = Thread.start do
        while [:running, :stopping].include? @state
          begin
            @running += 1
            run @queue.pop( true )
          rescue ThreadError # when queue is empty
          rescue
            puts $!
            puts caller.join("\n")
          ensure
            @running -= 1
          end
          sleep 0.016
          break if @state == :stopping
        end
      end
      @threads.push t
    end

    if block_given?
      yield self
      sleep 0.1 while queue.size > 0
      stop
    end
  end

  def running?
    @queue.size > 0 || @running > 0
  end

  def stop
    @state = :stopping
    while !@threads.select{ |t| t.alive? }.empty?
      sleep 1
    end
    @state = :stopped
    @threads = []
  end

  def run( job )
    begin
      job.run
    rescue
      puts $!
      puts caller.join("\n")
    end
  end

  def push( job )
    @queue.push job
  end
end
