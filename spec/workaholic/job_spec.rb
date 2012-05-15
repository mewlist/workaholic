require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Workaholic::Job do
  describe '#run' do
    subject { Workaholic::Job.new }
    it { should respond_to :run}
  end
end
