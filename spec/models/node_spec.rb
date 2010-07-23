require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. spec_helper]))

describe Node do
  describe 'attributes' do
    before :each do
      Node.generate!
      @node = Node.new
    end

    it { should have_many(:node_class_memberships) }
    it { should have_many(:node_classes).through(:node_class_memberships) }
    it { should have_many(:node_group_memberships) }
    it { should have_many(:node_groups).through(:node_group_memberships) }

    it { should have_db_column(:name).of_type(:string) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }

  end

  describe ".successful" do
    include DescribeReports

    it "should return all nodes whose latest report was successful" do
      report = Report.generate
      report.update_attribute(:success, true)

      Node.successful.should include(report.node)
    end

    it "should not return failed nodes" do
      successful_report = report_model_from_yaml('success.yml')
      successful_report.save!
      successful_node = successful_report.node

      failed_report = report_model_from_yaml('failure.yml')
      failed_report.save!
      failed_node = failed_report.node

      Node.successful.should_not include(failed_report.node)
    end
  end

  describe ".failed" do
    include DescribeReports

    it "should return all nodes whose latest report failed" do
      report = Report.generate
      report.update_attribute(:success, false)

      Node.failed.should include(report.node)
    end

    it "should not return successful nodes" do
      successful_report = report_model_from_yaml('success.yml')
      successful_report.save!
      successful_node = successful_report.node

      failed_report = report_model_from_yaml('failure.yml')
      failed_report.save!
      failed_node = failed_report.node

      Node.failed.should_not include(successful_report.node)
    end
  end

  describe ".unreported" do
    it "should return all nodes whose latest report was unreported" do
      node = Node.generate

      Node.unreported.should include(node)
    end
  end

  describe "no_longer_reporting" do
    it "should return all nodes whose latest report is more than 30 minutes ago" do
      old = node = Node.generate(:reported_at => 1.hour.ago)
      new = node = Node.generate(:reported_at => 10.minutes.ago)

      Node.no_longer_reporting.should include(old)
      Node.no_longer_reporting.should_not include(new)
    end
  end

  describe '#available_node_classes' do
    before do
      @node = Node.new
      @node_classes = Array.new(3){ NodeClass.generate! }
    end

    it "should include all available classes" do
      @node.available_node_classes.should == @node_classes
    end

    describe 'when the node has classes' do
      before { @node.node_classes << @node_classes.first }

      it "should not include the node's classes" do
        @node.available_node_classes.should_not include(@node_classes.first)
      end

    end
  end

  describe '#available_node_groups' do
    before do
      @node = Node.new
      @node_groups = Array.new(3){ NodeGroup.generate! }
    end

    it "should include all available groups" do
      @node.available_node_groups.should == @node_groups
    end

    describe 'when the node has groups' do
      before { @node.node_groups << @node_groups.first }

      it "should not include the node's groups" do
        @node.available_node_groups.should_not include(@node_groups.first)
      end

    end
  end

  it 'should be able to compute a configuration' do
    Node.new.should respond_to(:configuration)
  end

  describe 'when computing a configuration' do
    before :each do
      @node = Node.generate!
    end

    it 'should return a name and set of classes and parameters' do
      @node.configuration.keys.sort.should == ['classes', 'name', 'parameters']
    end

    it "should return the names of the node's classes in the returned class list" do
      @node.node_classes = @classes = Array.new(3) { NodeClass.generate! }
      @node.configuration['classes'].sort.should == @classes.collect(&:name).sort
    end

    it "should return the node's compiled parameters in the returned parameters list" do
      @node.stubs(:compiled_parameters).returns({'a' => 'b', 'c' => 'd'})
      @node.configuration['parameters'].should == { 'a' => 'b', 'c' => 'd' }  
    end
  end

  describe "#inherited_classes" do
    before do
      @node = Node.generate!
      @node_group = NodeGroup.generate!
      @inherited_class = NodeClass.generate!
      @node_group.node_classes << @inherited_class
      @node.node_groups << @node_group
    end

    it "should inherit classes from its groups" do
      @node.inherited_classes.should include(@inherited_class)
    end
  end

  describe "#all_classes" do
    before do
      @node = Node.generate!
      @node.stubs(:inherited_classes).returns([:inherited_class])
      @node.stubs(:node_classes).returns([:local_class])
    end

    it { @node.all_classes.should include(:inherited_class) }
    it { @node.all_classes.should include(:local_class) }
  end

  describe "#parameters=" do
    before { @node = Node.generate! }

    it "should create parameter objects for new parameters" do
      lambda {
        @node.parameter_attributes = [{:key => :key, :value => :value}]
        @node.save
      }.should change(Parameter, :count).by(1)
    end

    it "should create and destroy parameters based on updated parameters" do
      @node.parameter_attributes = [{:key => :key1, :value => :value1}]
      lambda {
        @node.parameter_attributes = [{:key => :key2, :value => :value2}]
        @node.save
      }.should_not change(Parameter, :count)
    end

    it "should create timeline events for creation and destruction" do
      @node.parameter_attributes = [{:key => :key1, :value => :value1}]
      lambda {
        @node.parameter_attributes = [{:key => :key2, :value => :value2}]
        @node.save
      }.should change(TimelineEvent, :count).by_at_least(2)
    end
  end

  describe "handling the node group graph" do
    before do
      @node = Node.generate!

      @node_group_a = NodeGroup.generate!
      @node_group_b = NodeGroup.generate!

      @param_1 = Parameter.generate(:key => 'foo', :value => '1')
      @param_2 = Parameter.generate(:key => 'bar', :value => '2')

      @node_group_a.parameters << @param_1
      @node_group_b.parameters << @param_2

      @node.node_groups << @node_group_a
      @node.node_groups << @node_group_b
    end

    it "should raise an error if the graph contains a cycle" do
      @node_group_a1 = NodeGroup.generate!
      @node_group_a1.node_groups << @node_group_a
      @node_group_a.node_groups << @node_group_a1

      lambda{@node.node_group_graph}.should raise_error(NodeGroupCycleError)
    end

    describe "handling parameters in the graph" do

      it "should return the compiled parameters" do
        @node.compiled_parameters.should == {'foo' => '1', 'bar' => '2'}
      end

      it "should ensure that parameters nearer to the node are retained" do
        @node_group_a1 = NodeGroup.generate!
        @node_group_a1.parameters << Parameter.create(:key => 'foo', :value => '2')
        @node_group_a.node_groups << @node_group_a1

        @node.compiled_parameters.should == {'foo' => '1', 'bar' => '2'}
      end

      it "should raise an error if there are parameter conflicts among children" do
        @param_2.update_attribute(:key, 'foo')
        lambda {@node.compiled_parameters}.should raise_error(ParameterConflictError)
      end

      it "should not raise an error if there are two sibling parameters with the same key and value" do
        @param_2.update_attributes(:key => @param_1.key, :value => @param_1.value)
        lambda {@node.compiled_parameters}.should_not raise_error(ParameterConflictError)
      end

      it "should include parameters of the node itself" do
        @node.parameters << Parameter.create(:key => "node_parameter", :value => "exist")
        @node.compiled_parameters["node_parameter"].should == "exist"
      end
    end
  end

  describe "assigning nodes and groups" do
    it "should not remove classes if node_class_names is unspecified" do
      @node = Node.generate!
      @node.node_classes << NodeClass.generate!
      lambda {@node.update_attribute(:name, 'new_name')}.should_not change{@node.node_classes.size}
    end

    it "should not remove groups if node_group_names is unspecified" do
      @node = Node.generate!
      @node.node_groups << NodeGroup.generate!
      lambda {@node.update_attribute(:name, 'new_name')}.should_not change{@node.node_groups.size}
    end

  end

  describe "destroying" do
    before do
      @node = Node.generate!(:name => 'sample_node')
      @report = Report.generate!
    end

    subject { lambda { @node.destroy } }

    it("destroys dependent reports") { should change(Report, :count).by(-1) }
  end


end
