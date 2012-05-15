require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Workaholic do
  let(:worker) { Workaholic.new }

  describe '#start' do
    subject { worker.start( 1 ) }

    it 'should start threads' do
      Thread.should_receive(:start)
      subject
    end

    it 'should raise error when worker is already running' do
      worker.start 2
      expect { subject }.to raise_error( Workaholic::RunningError )
    end

    it 'should call stop when block given' do
      worker.should_receive(:stop)
      worker.start 2 do
        worker.push Workaholic::Job.new
      end
    end
  end

  describe '#run' do
    subject { worker.run job }
    let(:job) { Workaholic::Job.new }

    it 'should run job' do
      job.should_receive(:run)
      subject
    end
  end

  describe '#push' do
    subject { worker.push job }
    let(:job) { Workaholic::Job.new }

    it 'should push job in queue' do
      expect{ subject }.to change( worker.queue, :size ).by(1)
    end
  end
end
