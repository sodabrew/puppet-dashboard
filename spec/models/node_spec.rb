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

  describe "::by_currentness_and_successfulness" do
    before do
      Node.destroy_all

      later = 1.week.ago.to_date
      sooner = Date.today

      @always_suceeding = Node.generate!(:name => 'always_suceeding').tap do |node|
        Report.generate_for(node, later, true)
        Report.generate_for(node, sooner, true)
        node.reload
      end

      @currently_succeeding = Node.generate!(:name => 'currently_succeeding').tap do |node|
        Report.generate_for(node, later, false)
        Report.generate_for(node, sooner, true)
        node.reload
      end

      @always_failing = Node.generate!(:name => 'always_failing').tap do |node|
        Report.generate_for(node, later, false)
        Report.generate_for(node, sooner, false)
        node.reload
      end

      @currently_failing = Node.generate!(:name => 'currently_failing').tap do |node|
        Report.generate_for(node, later, true)
        Report.generate_for(node, sooner, false)
        node.reload
      end
    end

    after do
      Node.destroy_all
    end

    [
      [true,  true,  %w[always_suceeding currently_succeeding]],
      [true,  false, %w[always_failing currently_failing]],
      [false, true,  %w[always_suceeding currently_succeeding currently_failing]],
      [false, false, %w[currently_succeeding always_failing currently_failing]],
    ].each do |currentness, successfulness, inclusions|
      context "when #{currentness ? 'current' : 'ever'} and #{successfulness ? 'successful' : 'failed'}" do
        let(:currentness) { currentness }
        let(:successfulness) { successfulness }
        let(:inclusions) { inclusions }

        subject { Node.by_currentness_and_successfulness(currentness, successfulness).map(&:name).sort }

        it "should exactly match: #{inclusions.join(', ')}" do
          should == inclusions.sort
        end
      end
    end
  end

  # describe ".successful" do
    # include DescribeReports

    # it "should return all nodes whose latest report was successful" do
      # report = Report.generate
      # report.update_attribute(:success, true)

      # Node.successful.should include(report.node)
    # end

    # it "should not return failed nodes" do
      # successful_report = report_model_from_yaml('success.yml')
      # successful_report.save!
      # successful_node = successful_report.node

      # failed_report = report_model_from_yaml('failure.yml')
      # failed_report.save!
      # failed_node = failed_report.node

      # Node.successful.should_not include(failed_report.node)
    # end
  # end

  # describe ".failed" do
    # include DescribeReports

    # it "should return all nodes whose latest report failed" do
      # report = Report.generate
      # report.update_attribute(:success, false)

      # Node.failed.should include(report.node)
    # end

    # it "should not return successful nodes" do
      # successful_report = report_model_from_yaml('success.yml')
      # successful_report.save!
      # successful_node = successful_report.node

      # failed_report = report_model_from_yaml('failure.yml')
      # failed_report.save!
      # failed_node = failed_report.node

      # Node.failed.should_not include(successful_report.node)
    # end
  # end

  describe ".unreported" do
    it "should return all nodes whose latest report was unreported" do
      node = Node.generate

      Node.unreported.should include(node)
    end
  end

  describe "no_longer_reporting" do
    it "should return all nodes whose latest report is more than 1 hour ago" do
      old = node = Node.generate(:reported_at => 2.hours.ago)
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

      @node_group_a = NodeGroup.generate! :name => "A"
      @node_group_b = NodeGroup.generate! :name => "B"

      @param_1 = Parameter.generate(:key => 'foo', :value => '1')
      @param_2 = Parameter.generate(:key => 'bar', :value => '2')

      @node_group_a.parameters << @param_1
      @node_group_b.parameters << @param_2

      @node.node_groups << @node_group_a
      @node.node_groups << @node_group_b
    end

    describe "when a group is included twice" do
      before do
        @node_group_c = NodeGroup.generate!
        @node_group_a.node_groups << @node_group_c
        @node_group_b.node_groups << @node_group_c
      end

      it "should return the correct graph" do
        @node.node_group_graph.should == {@node_group_a => {@node_group_c => {}}, @node_group_b => {@node_group_c => {}}}
      end

      it "should return the correct list" do
        @node.node_group_list.should == [@node, @node_group_a, @node_group_c, @node_group_b]
      end
    end

    it "should handle cycles gracefully" do
      NodeGroupEdge.new(:from => @node_group_a, :to => @node_group_b).save(false)
      NodeGroupEdge.new(:from => @node_group_b, :to => @node_group_a).save(false)

      @node.node_group_graph.should == {
        @node_group_a => {
          @node_group_b => {
            @node_group_a => {} }},
        @node_group_b => {
          @node_group_a => {
            @node_group_b => {} }}}
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
        @node.errors.on(:parameters).should == "foo"
      end

      it "should not raise an error if there are two sibling parameters with the same key and value" do
        @param_2.update_attributes(:key => @param_1.key, :value => @param_1.value)

        lambda {@node.compiled_parameters}.should_not raise_error(ParameterConflictError)
        @node.errors.on(:parameters).should be_nil
      end

      it "should not raise an error if there are parameter conflicts that can be resolved at a higher level" do
        @param_3 = Parameter.generate(:key => 'foo', :value => '3')
        @param_4 = Parameter.generate(:key => 'foo', :value => '4')
        @node_group_c = NodeGroup.generate!
        @node_group_c.parameters << @param_3
        @node_group_d = NodeGroup.generate!
        @node_group_d.parameters << @param_4
        @node_group_a.node_groups << @node_group_c << @node_group_d

        lambda {@node.compiled_parameters}.should_not raise_error(ParameterConflictError)
        @node.errors.on(:parameters).should be_nil
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
      @node = Node.generate!(:name => 'gonnadienode')
    end

    it("should destroy dependent reports") do
      @report = Report.generate_for(@node)
      @node.destroy
      Report.all.should_not include(@report)
    end

    it "should remove class memberships" do
      node_class = NodeClass.generate!()
      @node.node_classes << node_class

      @node.destroy

      node_class.nodes.should be_empty
      node_class.node_class_memberships.should be_empty
    end

    it "should remove group memberships" do
      node_group = NodeGroup.generate!()
      @node.node_groups << node_group

      @node.destroy

      node_group.nodes.should be_empty
      node_group.node_group_memberships.should be_empty
    end
  end

end
