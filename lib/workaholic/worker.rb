require 'thread'

module Workaholic
  class RunningError < StandardError; end
  class Worker
    attr_reader :queue
    attr_reader :state

    def initialize
      @queue = Queue.new
      @state = :stopped
      @threads ||= []
    end

    def start( thread_count = 2 )
      raise RunningError unless state == :stopped

      @state = :running
      thread_count.times do |i|
        t = Thread.start do
          while [:running, :stopping].include? @state
            run @queue.pop( true )
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
      rescue ThreadError # when queue is empty
        sleep 0.1
      rescue e
        raise e
      end
    end

    def push( job )
      @queue.push job
    end
  end
end
