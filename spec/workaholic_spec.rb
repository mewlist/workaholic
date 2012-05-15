require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


class TestJob < Workaholic::Job
  attr_accessor :counter
  def run
    self.class.count_up!
  end

  @count = 0
  def self.count; @count end
  def self.count_up!; @count+=1 end
end

describe Workaholic do
  let(:worker) { Workaholic::Worker.new }
  let(:job1) { TestJob.new }
  let(:job2) { TestJob.new }

  describe 'run parallel job' do
    subject { TestJob.count }
before do
      worker.start 100
      1000.times do
        worker.push job1
        worker.push job2
      end
      sleep 0.1 while worker.queue.size > 0
      worker.stop
    end

    it { should == 2000 }
  end
end
