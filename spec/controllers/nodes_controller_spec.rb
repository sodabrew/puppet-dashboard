require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe NodesController do
  describe "#index" do
    before do
      @node = Node.generate!
    end

    context "as HTML" do
      before { get :index }
      specify { response.should be_success }
    end

    context "as JSON" do
      before { get :index, :format => "json" }
      specify { response.should be_success }
      it "should return JSON" do
        struct = json_from_response_body
        struct.size.should == 1
        struct.first["name"].should == @node.name
      end
    end

    context "as YAML" do
      it "should return YAML when the nodes are valid" do
        get :index, :format => "yaml"

        response.should be_success
        struct = yaml_from_response_body
        struct.size.should == 1
        struct.first["name"].should == @node.name
      end

      it "should propagate errors encountered when a node is invalid" do
        Node.any_instance.stubs(:compiled_parameters).raises ParameterConflictError
        lambda {get :index, :format => "yaml"}.should raise_error(ParameterConflictError)
      end
    end
  end

  describe '#edit' do
    before :each do
      @node = Node.generate!
    end

    def do_get
      get :edit, :id => @node.name
    end

    it 'should make the requested node available to the view' do
      do_get
      assigns[:node].should == @node
    end

    it 'should render the edit template' do
      do_get
      response.should render_template('edit')
    end
  end

  describe '#update' do
    before :each do
      @node = Node.generate!
      @params = { :id => @node.name, :node => @node.attributes }
    end

    def do_put
      put :update, @params
    end

    it 'should fail when an invalid node id is given' do
      @params[:id] = 'unknown'
      lambda { do_put }.should raise_error(ActiveRecord::RecordNotFound)
    end

    describe 'when a valid node id is given' do

      describe 'and the data provided would make the node invalid' do
        before :each do
          @params[:node]['name'] = nil
        end

        it 'should make the node available to the view' do
          do_put
          assigns[:node].should == @node
        end

        it 'should not save the node' do
          do_put
          Node.find(@node.id).name.should_not be_nil
        end

        it 'should have errors on the node' do
          do_put
          assigns[:node].errors[:name].should_not be_blank
        end

        it 'should render the update action' do
          do_put
          response.should render_template('update')
        end
      end

      describe 'and the data provided make the node valid' do
        it 'should note the update success in flash' do
          do_put
          flash[:notice].should match(/success/i)
        end

        it 'should update the node with the data provided' do
          @params[:node]['name'] = 'new name'
          do_put
          Node.find(@node.id).name.should == 'new name'
        end

        it 'should have a valid node' do
          do_put
          assigns[:node].should be_valid
        end
      end
    end
  end

  describe "#reports" do
    shared_examples_for "a successful reports rendering" do
      specify { response.should be_success }
    end

    shared_examples_for "an un-paginated reports collection" do
      it "should not be paginated" do
        assigns[:reports].should_not be_a_kind_of(WillPaginate::Collection)
      end
    end

    before do
      @node = Node.generate!
      Node.stubs(:find_by_name! => @node)
      Report.stubs(:assign_to_node => false)
      @report = Report.generate!(:node => @node)
      @node.reports = [@report]
    end

    context "for HTML" do
      before { get :reports, :node => 123 }

      it_should_behave_like "a successful reports rendering"
      it_should_behave_like "an un-paginated reports collection"
    end

    context "for YAML" do
      before { get :reports, :node => 123, :format => "yaml" }

      it_should_behave_like "a successful reports rendering"
      it_should_behave_like "an un-paginated reports collection"

      it "should return YAML" do
        response.body.should =~ %r{ruby/object:Report}
        struct = yaml_from_response_body
        struct.size.should == 1
        struct.first.should == @report
      end
    end

    context "for JSON" do
      before { get :reports, :node => 123, :format => "json" }

      it_should_behave_like "a successful reports rendering"
      it_should_behave_like "an un-paginated reports collection"

      it "should return JSON" do
        struct = json_from_response_body
        struct.size.should == 1

        for key in %w[host id node_id success]
          struct.first[key].should == @report.send(key)
        end

        struct.first['report']['metrics']['resources']['values'].tap do |values|
          @report.total_resources.should == values.find{|t| t.first['total']}[2]
          @report.failed_resources.should == values.find{|t| t.first['failed']}[2]
        end

        struct.first['report']['metrics']['time']['values'].tap do |values|
          @report.total_time.should == (Report::TOTAL_TIME_FORMAT % values.find{|t| t.first['total']}[2].to_s)
        end
      end
    end
  end

  # Relies on #action returning name of a NodesController action, e.g. as "successful".
  describe "#scoped_index" do
    shared_examples_for "a successful scoped_index rendering" do
      specify { response.should be_success }

      it "should assign only appropriate records" do
        assigns[:nodes].size.should == 1
        assigns[:nodes].first.name.should == action
      end
    end

    shared_examples_for "a paginated nodes collection" do
      it "should be paginated" do
        assigns[:nodes].should be_a_kind_of(WillPaginate::Collection)
      end
    end

    shared_examples_for "an un-paginated nodes collection" do
      it "should not be paginated" do
        assigns[:nodes].should_not be_a_kind_of(WillPaginate::Collection)
      end
    end

    shared_examples_for "a scope_index action" do
      before do
        @results = [Node.generate!(:name => action)]
        @results.stubs(:with_last_report => @results, :by_report_date => @results)
        Node.stubs(action => @results)
        Node.stubs(:by_currentness_and_successfulness => @results)
      end

      context "as HTML" do
        before { get action, action_params }

        it_should_behave_like "a successful scoped_index rendering"
        # NOTE: Once upon a time, these were paginated but were breaking the graphs
        # it_should_behave_like "a paginated nodes collection"
        it_should_behave_like "an un-paginated nodes collection"
      end

      context "as YAML" do
        before { get action, action_params.merge(:format => "yaml") }

        it_should_behave_like "a successful scoped_index rendering"
        it_should_behave_like "an un-paginated nodes collection"

        it "should return YAML" do
          struct = yaml_from_response_body
          struct.size.should == 1
          struct.first["name"].should == action
        end
      end

      context "as JSON" do
        before { get action, action_params.merge(:format => "json") }

        it_should_behave_like "a successful scoped_index rendering"
        it_should_behave_like "an un-paginated nodes collection"

        it "should return JSON" do
          struct = json_from_response_body
          struct.size.should == 1
          struct.first["name"].should == action
        end
      end
    end

    for action in %w[unreported no_longer_reporting]
      describe action do
        let(:action) { action }
        let(:action_params) { {} }
        it_should_behave_like "a scope_index action"
      end
    end

    describe "#successful" do
      it "should redirect to current and successful" do
        get :successful

        response.should redirect_to(nodes_path(:current => true.to_s, :successful => true.to_s))
      end
    end

    describe "#failed" do
      it "should redirect to current and failed" do
        get :failed

        response.should redirect_to(nodes_path(:current => true.to_s, :successful => false.to_s))
      end
    end

    describe "current and successful" do
      let(:action) { "index" }
      let(:action_params) { {:current => true, :successful => true} }

      it_should_behave_like "a scope_index action"
    end
  end
end
