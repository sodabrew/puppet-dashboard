require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Report do
  describe "on creation" do
    before do
      @now = Time.now
      Time.stubs(:now).returns(@now)
      @node = Node.generate
      YAML.stubs(:load).returns(mock(:host => 'localhost'))
    end

    it "finds a node by host if it exists" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      Report.create(:report => '')
    end

    it "creates a node by host if none exists" do
      lambda {
        Report.create(:report => '')
      }.should change { Node.count(:conditions => {:name => 'localhost'}) }.by(1)
    end

    it "assigns the node to the report" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      Report.create(:report => '').node.should == @node
    end

    it "updates the node's reported_at timestamp" do
      Node.expects(:find_or_create_by_name).with('localhost').returns(@node)
      lambda {
        Report.create(:report => '')
      }.should change { @node.reported_at }.to(Time.now)
    end
  end
end
