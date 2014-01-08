require 'spec_helper'

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
    it { pending 'problem with attr_readonly and inherited_resources'; should have_readonly_attribute(:name) }

  end

  describe "statuses" do
    before :each do
      later = 1.week.ago.to_date
      sooner = Date.today

      @ever_changed = Node.generate!(:name => 'ever_changed').tap do |node|
        Report.generate!(:host => node.name, :time => later, :status => 'changed')
        Report.generate!(:host => node.name, :time => sooner, :status => 'changed')
        node.reload
      end

      @ever_unchanged = Node.generate!(:name => 'ever_unchanged').tap do |node|
        Report.generate!(:host => node.name, :time => later, :status => 'unchanged')
        Report.generate!(:host => node.name, :time => sooner, :status => 'unchanged')
        node.reload
      end

      @just_changed = Node.generate!(:name => 'just_changed').tap do |node|
        Report.generate!(:host => node.name, :time => later, :status => 'failed')
        Report.generate!(:host => node.name, :time => sooner, :status => 'changed')
        node.reload
      end

      @just_unchanged = Node.generate!(:name => 'just_unchanged').tap do |node|
        Report.generate!(:host => node.name, :time => later, :status => 'failed')
        Report.generate!(:host => node.name, :time => sooner, :status => 'unchanged')
        node.reload
      end

      @ever_failed = Node.generate!(:name => 'ever_failed').tap do |node|
        Report.generate!(:host => node.name, :time => later, :status => 'failed')
        Report.generate!(:host => node.name, :time => sooner, :status => 'failed')
        node.reload
      end

      @just_failed = Node.generate!(:name => 'just_failed').tap do |node|
        Report.generate!(:host => node.name, :time => later, :status => 'unchanged')
        Report.generate!(:host => node.name, :time => sooner, :status => 'failed')
        node.reload
      end

      @only_inspections = Node.generate!(:name => 'only_inspections').tap do |node|
        Report.generate!(:host => node.name, :time => later, :kind => 'inspect', :status => "unchanged")
        node.reload
      end

      @never_reported = Node.generate!(:name => 'never_reported')
    end
  end

  describe "status named_scopes" do
    it "should find nodes with the appropriate statuses on the latest report" do
      [:failed, :pending, :changed, :unchanged].each do |node_status|
        node = Node.create!(:name => node_status.to_s)
        node.reports.generate!(:status => 'bogus', :time => Time.now - 1)
        node.reports.generate!(:status => node_status.to_s, :time => Time.now)

        node = Node.create!(:name => "#{node_status}-unresponsive")
        node.reports.generate!(
          :status => node_status.to_s, 
          :time => SETTINGS.no_longer_reporting_cutoff.seconds.ago - 1
        )
      end

      Node.pending.map(&:name).should   == ['pending']
      Node.changed.map(&:name).should   == ['changed']
      Node.unchanged.map(&:name).should == ['unchanged']
      Node.failed.map(&:name).should    == ['failed']

      Node.unresponsive.map(&:name).should =~ [
        'failed-unresponsive',
        'pending-unresponsive',
        'changed-unresponsive',
        'unchanged-unresponsive'
      ]
    end
  end

  describe "::find_from_inventory_search" do
    before :each do
      @foo = Node.generate :name => "foo"
      @bar = Node.generate :name => "bar"
    end

    it "should find the nodes that match the list of names given" do
      PuppetHttps.stubs(:get).returns('["foo", "bar"]')
      Node.find_from_inventory_search.should =~ [@foo, @bar]
    end

    it "should create nodes that don't exist" do
      PuppetHttps.stubs(:get).returns('["foo", "bar", "baz"]')
      Node.find_from_inventory_search.map(&:name).should =~ ['foo', 'bar', 'baz']
    end

    it "should look-up nodes case-insensitively" do
      baz = Node.generate :name => "BAZ"
      PuppetHttps.stubs(:get).returns('["foo", "BAR", "baz"]')
      Node.find_from_inventory_search.should =~ [@foo, @bar, baz]
    end
  end

  describe ".unreported" do
    it "should return all nodes whose latest report was unreported" do
      unreported_node = Node.generate
      reported_node = Node.generate
      Report.generate!(:host => reported_node.name)

      Node.unreported.should == [unreported_node]
    end
  end

  describe "" do
    before :each do
      @nodes = {:hidden   => Node.generate!(:hidden => true),
                :unhidden => Node.generate!(:hidden => false)
      }
    end

    [:hidden, :unhidden].each do |hiddenness|
      describe hiddenness do
        it "should find all #{hiddenness} nodes" do
          nodes = Node.send(hiddenness)
          nodes.length.should == 1
          nodes.first.should == @nodes[hiddenness]
        end
      end
    end
  end

  describe 'when computing a configuration' do
    before :each do
      @node = Node.generate!
    end

    it 'should return a name and set of classes and parameters' do
      @node.configuration.keys.should =~ ['classes', 'name', 'parameters']
    end

    it "should return the names of the node's classes in the keys of the returned class list" do
      @node.node_classes = @classes = Array.new(3) { NodeClass.generate! }
      @node.configuration['classes'].keys.should =~ @classes.collect(&:name)
    end

    it "should return the node's compiled parameters in the returned parameters list" do
      @node.stubs(:compiled_parameters).returns [
        { :name => 'a', :value => 'b', :sources => Set[:foo] },
        { :name => 'c', :value => 'd', :sources => Set[:bar] }
      ]
      @node.configuration['parameters'].should == { 'a' => 'b', 'c' => 'd' }
    end
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
    before :each do
      @node = Node.generate! :name => "Sample"

      @node_group_a = NodeGroup.generate! :name => "A"
      @node_group_b = NodeGroup.generate! :name => "B"

      @param_1 = Parameter.generate(:key => 'foo', :value => '1')
      @param_2 = Parameter.generate(:key => 'bar', :value => '2')

      @node_group_a.parameters << @param_1
      @node_group_b.parameters << @param_2

      @node.node_groups << @node_group_a
      @node.node_groups << @node_group_b
    end

    describe "collecting global parameters conflicts" do
      it "should find 1 conflict" do
        param_3 = Parameter.generate(:key => 'foo', :value => '2')
        @node_group_b.parameters << param_3
        @node.global_conflicts.length.should == 1
      end

      it "should not find any conflicts when the parameter is overridden" do
        node_group_a1 = NodeGroup.generate! :name => "A1"
        @node_group_a.node_groups << node_group_a1
        param_3 = Parameter.generate(:key => 'foo', :value => '2')
        node_group_a1.parameters << param_3
        @node.global_conflicts.length.should == 0
      end

      it "should find 1 conflict" do
        node_group_b1 = NodeGroup.generate! :name => "B1"
        @node_group_b.node_groups << node_group_b1
        param_3 = Parameter.generate(:key => 'foo', :value => '2')
        node_group_b1.parameters << param_3
        @node.global_conflicts.length.should == 1
      end
    end

    describe "collecting class parameters conflicts" do
      before :each do
        @node_class_a = NodeClass.generate :name => "a"
        @node_class_b = NodeClass.generate :name => "b"
        @node_class_c = NodeClass.generate :name => "c"

        @node_group_a.node_classes << @node_class_a
        @node_group_b.node_classes << @node_class_b

        @node_group_a1 = NodeGroup.generate! :name => "A1"
        @node_group_a2 = NodeGroup.generate! :name => "A2"

        @node_group_a.node_groups << @node_group_a1
        @node_group_a.node_groups << @node_group_a2

        @node_group_a_class_memberships_a = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_a.id, @node_class_a.id)
        @node_group_a_class_memberships_a.parameters << Parameter.generate(:key => 'p1', :value => '1')
        @node_group_b_class_memberships_b = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_b.id, @node_class_b.id)
        @node_group_b_class_memberships_b.parameters << Parameter.generate(:key => 'p1', :value => '2')
      end

      it "should not find any conflicts when different classes use the same parameter with different values" do
        @node.class_conflicts.length.should == 0
      end

      it "should find 1 conflict" do
        @node_group_b.node_classes << @node_class_a
        node_group_b_class_memberships_a = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_b.id, @node_class_a.id)
        node_group_b_class_memberships_a.parameters << Parameter.generate(:key => 'p1', :value => '2')
        
        @node.class_conflicts.length.should == 1
      end

      it "should not find any conflicts when the competing parameters have the same value" do
        @node_group_b.node_classes << @node_class_a
        node_group_b_class_memberships_a = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_b.id, @node_class_a.id)
        node_group_b_class_memberships_a.parameters << Parameter.generate(:key => 'p1', :value => '1')

        @node.class_conflicts.length.should == 0
      end

      describe "on a tree with more levels" do
        before :each do
          @node_group_a1.node_classes << @node_class_c
          @node_group_a2.node_classes << @node_class_c

          node_group_a1_class_memberships_c = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_a1.id, @node_class_c.id)
          node_group_a1_class_memberships_c.parameters << Parameter.generate(:key => 'p1', :value => '1')

          node_group_a2_class_memberships_c = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_a2.id, @node_class_c.id)
          node_group_a2_class_memberships_c.parameters << Parameter.generate(:key => 'p1', :value => '2')
        end

        it "should find 1 conflict" do
          @node.class_conflicts.length.should == 1
        end

        it "should not find any conflicts when the conflicting parameter is overridden" do
          @node_group_a.node_classes << @node_class_c
          node_group_a_class_memberships_c = NodeGroupClassMembership.find_by_node_group_id_and_node_class_id(@node_group_a.id, @node_class_c.id)
          node_group_a_class_memberships_c.parameters << Parameter.generate(:key => 'p1', :value => '3')

          @node.class_conflicts.length.should == 0
        end
      end
    end

    describe "when a group is included twice" do
      before :each do
        @node_group_c = NodeGroup.generate! :name => "C"
        @node_group_d = NodeGroup.generate! :name => "D"
        @node_group_c.node_groups << @node_group_d
        @node_group_a.node_groups << @node_group_c
        @node_group_b.node_groups << @node_group_c
      end

      it "should return the correct groups and sources" do
        @node.node_groups_with_sources.should == {@node_group_a => Set[@node], @node_group_c => Set[@node_group_a,@node_group_b], @node_group_b => Set[@node], @node_group_d => Set[@node_group_c]}
      end
    end

    describe "handling parameters in the graph" do

      it "should return the compiled parameters" do
        @node.compiled_parameters.should =~ [
          { :name => 'foo', :value => '1', :sources => Set[@node_group_a] },
          { :name => 'bar', :value => '2', :sources => Set[@node_group_b] }
        ]
      end

      it "should ensure that parameters nearer to the node are retained" do
        @node_group_a1 = NodeGroup.generate!
        @node_group_a1.parameters << Parameter.create(:key => 'foo', :value => '2')
        @node_group_a.node_groups << @node_group_a1

        @node.compiled_parameters.should =~ [
          { :name => 'foo', :value => '1', :sources => Set[@node_group_a] },
          { :name => 'bar', :value => '2', :sources => Set[@node_group_b] }
        ]
      end

      it "should raise an error if there are parameter conflicts among children" do
        @param_2.update_attribute(:key, 'foo')

        expect {@node.compiled_parameters}.to raise_error(ParameterConflictError)
        @node.errors[:parameters].should =~ ["foo"]
      end

      it "should not raise an error if there are two sibling parameters with the same key and value" do
        @param_2.update_attributes(:key => @param_1.key, :value => @param_1.value)

        expect {@node.compiled_parameters}.to_not raise_error(ParameterConflictError)
        @node.errors[:parameters].should be_empty
      end

      it "should not raise an error if there are parameter conflicts that can be resolved at a higher level" do
        param_3 = Parameter.generate(:key => 'foo', :value => '3')
        param_4 = Parameter.generate(:key => 'foo', :value => '4')
        @node_group_c = NodeGroup.generate!
        @node_group_c.parameters << param_3
        @node_group_d = NodeGroup.generate!
        @node_group_d.parameters << param_4
        @node_group_a.node_groups << @node_group_c << @node_group_d

        expect {@node.compiled_parameters}.to_not raise_error(ParameterConflictError)
        @node.errors[:parameters].should be_empty
      end

      it "should include parameters of the node itself" do
        @node.parameters << Parameter.create(:key => "node_parameter", :value => "exist")

        @node.compiled_parameters.should be_any {|p| p[:name] == "node_parameter" && p[:value] == "exist"}
      end

      it "should retain the history of its parameters" do
        @node_group_c = NodeGroup.generate! :name => "C"
        @node_group_d = NodeGroup.generate! :name => "D"
        @node_group_c.parameters << Parameter.generate(:key => 'foo', :value => '3')
        @node_group_d.parameters << Parameter.generate(:key => 'foo', :value => '4')
        @node_group_a.node_groups << @node_group_c
        @node_group_a.node_groups << @node_group_d

        @node.compiled_parameters.should =~ [
          { :name => 'foo', :value => '1', :sources => Set[@node_group_a] },
          { :name => 'bar', :value => '2', :sources => Set[@node_group_b] }
        ]
      end
    end
  end

  describe "when assigning classes" do
    before :each do
      @node    = Node.generate!
      @classes = Array.new(3) { NodeClass.generate! }
    end

    it "should not remove classes if node_class_ids and node_class_names are unspecified" do
      @node.node_classes << @classes.first
      lambda {@node.update_attribute(:description, 'new_desc')}.should_not change{@node.node_classes.size}
    end

    describe "via node_class_ids" do
      it "should be able to assign a single class" do
        @node.assigned_node_class_ids = @classes.first.id

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_classes.size.should == 1
        @node.node_classes.should include(@classes.first)
      end

      it "should be able to assign multiple classes" do
        @node.assigned_node_class_ids = [@classes.first.id, @classes.last.id]

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_classes.size.should == 2
        @node.node_classes.should include(@classes.first, @classes.last)
      end
    end

    describe "via node_class_names" do
      it "should be able to assign a single class" do
        @node.assigned_node_class_names = @classes.first.name

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_classes.size.should == 1
        @node.node_classes.should include(@classes.first)
      end

      it "should be able to assign multiple classes" do
        @node.assigned_node_class_names = [@classes.first.name, @classes.last.name]

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_classes.size.should == 2
        @node.node_classes.should include(@classes.first, @classes.last)
      end
    end

    describe "via node_class_ids, and node_class_names" do
      it "should assign all specified classes" do
        @node.assigned_node_class_names = @classes.first.name
        @node.assigned_node_class_ids   = @classes.last.id

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_classes.size.should == 2
        @node.node_classes.should include(@classes.first, @classes.last)
      end
    end
  end

  describe "when assigning groups" do
    before :each do
      @node   = Node.generate!
      @groups = Array.new(3) { NodeGroup.generate! }
    end

    it "should not remove groups if node_group_ids and node_group_names are unspecified" do
      @node.node_groups << @groups.first
      lambda {@node.update_attribute(:description, 'new_desc')}.should_not change{@node.node_groups.size}
    end

    describe "via node_group_ids" do
      it "should be able to assign a single group" do
        @node.assigned_node_group_ids = @groups.first.id

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_groups.size.should == 1
        @node.node_groups.should include(@groups.first)
      end

      it "should be able to assign multiple groups" do
        @node.assigned_node_group_ids = [@groups.first.id, @groups.last.id]

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_groups.size.should == 2
        @node.node_groups.should include(@groups.first, @groups.last)
      end
    end

    describe "via node_group_names" do
      it "should be able to assign a single group" do
        @node.assigned_node_group_names = @groups.first.name

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_groups.size.should == 1
        @node.node_groups.should include(@groups.first)
      end

      it "should be able to assign multiple groups" do
        @node.assigned_node_group_names = [@groups.first.name, @groups.last.name]

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_groups.size.should == 2
        @node.node_groups.should include(@groups.first, @groups.last)
      end
    end

    describe "via node_group_ids, and node_group_names" do
      before :each do
        @groups = Array.new(3) { NodeGroup.generate! }
      end

      it "should assign all specified groups" do
        @node.assigned_node_group_names = @groups.first.name
        @node.assigned_node_group_ids   = @groups.last.id

        @node.should be_valid
        @node.errors.should be_empty
        @node.node_groups.size.should == 2
        @node.node_groups.should include(@groups.first, @groups.last)
      end
    end
  end

  describe "destroying" do
    before :each do
      @node = Node.generate!(:name => 'gonnadienode')
    end

    it("should destroy dependent reports") do
      @report = Report.generate!(:host => @node.name)
      @node.destroy
      Report.all.should_not include([@report])
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

  describe "facts" do
    before :each do
      @node = Node.generate!(:name => 'gonaddynode')
      @sample_pson = '{"name":"foo","timestamp":"Fri Oct 29 10:33:53 -0700 2010","expiration":"Fri Oct 29 11:03:53 -0700 2010","values":{"a":"1","b":"2"}}'
      @sample_pson_without_timestamp = '{"name":"foo","expiration":"Fri Oct 29 11:03:53 -0700 2010","values":{"a":"1","b":"2"}}'
      @sample_pson_with_malformed_timestamp = '{"name":"foo","expiration":"Fri Oct 29 11:03:53 -0700 2010","values":{"a":"1","b":"2","--- !ruby/sym _timestamp":"Sat Oct 30 10:33:53 -0700 2010"}}'
      SETTINGS.stubs(:inventory_server).returns('fred')
      SETTINGS.stubs(:inventory_port).returns(12345)
    end

    it "should return facts from an external REST call" do
      PuppetHttps.stubs(:get).with("https://fred:12345/production/facts/gonaddynode", 'pson').returns(
        @sample_pson)
      timestamp = Time.parse("Fri Oct 29 10:33:53 -0700 2010")
      @node.facts.should == { :timestamp => timestamp, :values => { "a" => "1", "b" => "2" }}
    end

    it "should properly CGI escape the node name in the REST call" do
      @node.name = '&/='
      PuppetHttps.expects(:get).with("https://fred:12345/production/facts/%26%2F%3D", 'pson').returns(
        @sample_pson)
      @node.facts
    end

    it "should return facts from an external REST call when timestamp is missing" do
      PuppetHttps.stubs(:get).with("https://fred:12345/production/facts/gonaddynode", 'pson').returns(
        @sample_pson_without_timestamp)
      @node.facts.should == {:timestamp => nil, :values => {"a" => "1", "b" => "2"}}
    end

    # The malformed timestamp can come back with Puppet 2.6.7 when both
    # storedconfigs and the inventory service are enabled.  See #6835
    it "should return facts from an external REST call when timestamp is malformed" do
      PuppetHttps.stubs(:get).with("https://fred:12345/production/facts/gonaddynode", 'pson').returns(
        @sample_pson_with_malformed_timestamp)
      timestamp = Time.parse("Sat Oct 30 10:33:53 -0700 2010")
      @node.facts.should == {:timestamp => timestamp, :values => {"a" => "1", "b" => "2"}}
    end
  end

  describe '.to_csv' do
    before :each do
      @node = Node.generate!
      @report = Report.generate!(:host => @node.name)
      @node.reload

      @custom_node_properties = [:name, :status, :resource_count, :pending_count, :failed_count, :compliant_count]
      @custom_resource_properties = [:resource_type, :title, :evaluation_time, :file, :line, :time, :change_count, :out_of_sync_count, :skipped, :failed]
    end

    let(:node_values) { @custom_node_properties.map {|prop| @node.send(prop)} }

    it 'should export one row per resource status with both node, and resource data' do
      pending_resource = Factory(:pending_resource, :title => 'pending', :report => @report)
      successful_resource = Factory(:successful_resource, :title => 'successful', :report => @report)
      failed_resource = Factory(:failed_resource, :title => 'failed', :report => @report)

      csv_lines = Node.find(:all).to_csv.split("\n")
      csv_lines.first.should == (@custom_node_properties + @custom_resource_properties).join(',')
      csv_lines[1..-1].should =~ [pending_resource, failed_resource, successful_resource].map do |res|
        line = node_values + @custom_resource_properties.map { |field| res.send(field) }
        line.join(',')
      end
    end

    it 'should export nulls for the resource status values when there are no resource statuses' do
      Node.find(:all).to_csv.split("\n").should == [
        (@custom_node_properties + @custom_resource_properties).join(','),
        (node_values + ([nil] * @custom_resource_properties.count)).join(',')
      ]
    end
  end

  describe 'self.resource_status_totals' do
    before :each do
      @pending_node = Factory(:pending_node)
      @unchanged_node = Factory(:unchanged_node)

      Metric.create!(:report => @pending_node.last_apply_report, :category => "resources", :name => "pending", :value => 27)
      Metric.create!(:report => @pending_node.last_apply_report, :category => "resources", :name => "unchanged", :value => 48)
      Metric.create!(:report => @pending_node.last_apply_report, :category => "resources", :name => "changed", :value => 4)
      Metric.create!(:report => @unchanged_node.last_apply_report, :category => "resources", :name => "unchanged", :value => 25)
    end
    it 'should calculate the correct totals for default scope' do
      Node.resource_status_totals("pending").should == 27
      Node.resource_status_totals("unchanged").should == 73
      Node.resource_status_totals("changed").should == 4
    end

    it 'should calculate the correct totals for specific scopes' do
      Node.resource_status_totals("unchanged","pending").should == 48
      Node.resource_status_totals("unchanged","unchanged").should == 25
    end
 
    it 'should raise an error if passed a scope that does not exist' do
      expect { Node.resource_status_totals("unchanged","not_a_scope") }.to raise_error(NoMethodError, /undefined method/)
    end

    it 'should default to all scope if nil is passed as scope' do
      Node.resource_status_totals("pending", nil).should == 27
      Node.resource_status_totals("unchanged", nil).should == 73
      Node.resource_status_totals("changed", nil).should == 4
    end

    it 'should raise an error if passed an invalid status' do
      expect { Node.resource_status_totals("not_a_status") }.to raise_error(ArgumentError, /No such status/)
    end
  end
end
