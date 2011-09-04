require "spec_helper"

describe Antilles do
  SAMPLE_PID = 12345
  SAMPLE_PORT = 12346
  SAMPLE_MIMIC_ARGS = {:fork => false,
                       :host => 'localhost',
                       :port => SAMPLE_PORT,
                       :remote_configuration_path => "/api"}


  describe ".configure" do
    it "should yield an object that can set port and log" do
      Antilles.configure do |server|
        server.port = 9875
        server.log = STDERR
      end
      Antilles.server.port.should == 9875
      Antilles.server.log.should == STDERR
    end
  end

  describe ".server" do
    it "should return an Antilles" do
      Antilles.server.should be_a(Antilles)
    end

    it "should save what it creates" do
      s1 = Antilles.server
      s2 = Antilles.server
      s1.should == s2
    end
  end

  describe ".start" do
    let(:server) { mock(Antilles) }
    it "should start a server" do
      server.stub(:start)
      server.stub(:started?) { false }
      server.should_receive(:start)
      Antilles.stub(:server) { server }

      Antilles.start
    end

    it "should not start a server if it's already started" do
      server.stub(:start)
      server.stub(:started?) { true }
      server.should_not_receive(:start)
      Antilles.stub(:server) { server }

      Antilles.start
    end
  end

  describe "#new" do
    it "should set port and log" do
      s = Antilles.new(10)
      s.port.should == 10
      s = Antilles.new(10, STDERR)
      s.port.should == 10
      s.log.should == STDERR
    end
  end

  def stub_start
    Kernel.stub(:fork) { SAMPLE_PID }
    Process.stub(:kill).with("TERM", SAMPLE_PID)
    Kernel.stub(:exit!)
    Mimic.stub(:mimic)
    Antilles.any_instance.stub(:wait)
  end

  describe "#started?" do
    before { stub_start }
    it "should start false" do
      subject.should_not be_started
    end

    it "should be true after starting the server" do
      subject.start
      subject.should be_started
    end

    it "should be false after stopping the server" do
      subject.start
      subject.stop
      subject.should_not be_started
    end
  end

  describe "#start" do
    subject { Antilles.new(SAMPLE_PORT) }

    before do
      Kernel.stub(:fork) { nil }
      Mimic.stub(:mimic)
      Kernel.stub(:exit!)
      subject.stub(:wait)
    end

    it "should start mimic on the right port" do
      Mimic.should_receive(:mimic).with(SAMPLE_MIMIC_ARGS)
      subject.start
    end

    it "should start mimic with the log set" do
      Mimic.should_receive(:mimic).with(SAMPLE_MIMIC_ARGS.merge(:log=>STDERR))
      subject.log = STDERR
      subject.start
    end
  end

  describe "#wait" do
    before { Kernel.stub(:sleep) }
    it "should ping" do
      subject.stub(:ping) { true }
      subject.should_receive(:ping).once
      subject.wait
    end

    it "should retry" do
      subject.stub(:ping) { false }
      subject.should_receive(:ping).exactly(5).times
      subject.wait
    end
  end
end
