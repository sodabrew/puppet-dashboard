require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  describe "on creation" do
    before do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @node = Node.generate
      @report_yaml ="--- !ruby/object:Puppet::Transaction::Report \nhost: localhost\nlogs: []\n\nmetrics: {}\n\nrecords: {}\n\ntime: 2009-12-17 14:18:13.225235 -08:00\n"
      @report_data = YAML.load @report_yaml
    end

    it "is not created if a report for the same host exists with the same time" do
      Report.create(:report => @report_yaml)
      lambda {
        Report.create(:report => @report_yaml)
      }.should_not change(Report, :count)
    end

    it "finds a node by host if it exists" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      Report.create(:report => @report_yaml)
    end

    it "creates a node by host if none exists" do
      lambda {
        Report.create(:report => @report_yaml)
      }.should change { Node.count(:conditions => {:name => 'localhost'}) }.by(1)
    end

    it "assigns the node to the report" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      Report.create(:report => @report_yaml).node.should == @node
    end

    it "updates the node's reported_at timestamp" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      lambda {
        Report.create(:report => @report_yaml)
      }.should change { @node.reported_at }.to(@report_data.time)
    end
  end
end
