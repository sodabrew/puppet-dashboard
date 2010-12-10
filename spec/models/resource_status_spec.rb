require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ResourceStatus do
  describe "#name" do
    it "should combine type and title" do
      resource_status = ResourceStatus.create!(:resource_type => "File", :title => "/tmp/foo", :report_id => 142857)
      resource_status.name.should == "File[/tmp/foo]"
    end
  end
end

