require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(ApplicationHelper)
  end

  describe "#truncated_sentence" do
    describe "when there are less items than the max" do
      it "should return the items sentence" do
        helper.truncated_sentence(5, [1,2,3,4]).should == [1,2,3,4].to_sentence
      end
    end

    describe "when there are more items than the max" do
      it "should end with and n more" do
        helper.truncated_sentence(3, [1,2,3,4]).should include("and 1 more")
      end
    end

    describe "when given a block" do
      it "should map the items using the block" do
        helper.truncated_sentence(3, %w(a r)){|item| item.succ}.should == "b and s"
      end
    end

    it "should use the :more option" do
        helper.truncated_sentence(3, [1,2,3,4], :more => "%d extra").should include("and 1 extra")
    end

  end

  describe "#header_for" do
    it "should return a header for a form with a new record" do
      record = Node.spawn
      form = stub(:object => record)
      helper.header_for(form).should have_text /Add node/
    end

    it "should return a header for a form with an existing object" do
      record = Node.generate
      form = stub(:object => record)
      helper.header_for(form).should have_text /Edit node/
    end
  end

 describe "#pagination_for" do
    before :each do
      @template.stubs( :request => request, :params => params, :url_for => 'someurl')
    end

    context "when given paginated records" do
      subject { helper.pagination_for([*(1..100)].paginate) }

      it { should have_tag('div.actionbar') }
      it { should have_tag('a', /Next/) }
    end

    context "when not given paginated records" do
      subject { helper.pagination_for([]) }

      it { should have_tag('div.actionbar') }
      it { should_not have_tag('a', /Next/) }
    end

    describe "when rendering the page size control" do
      it "should use the default per_page setting" do
        foo = Class.new do
          def self.per_page; 51 ; end
        end
        paginated_results = [foo.new].paginate
        helper.pagination_for(paginated_results).should have_tag('a', /51/)
      end

      it "should render spans instead of links for the current pagination size" do
        foo = Class.new do
          def self.per_page; 51 ; end
        end
        paginated_results = [foo.new].paginate(:per_page => 100)
        helper.pagination_for(paginated_results).should have_tag('span', /100/)
      end

      it "should render spans instead of links for the current pagination size supplied in the url" do
        foo = Class.new do
          def self.per_page; 51 ; end
        end
        params[:per_page] = "all"
        paginated_results = [foo.new]
        helper.pagination_for(paginated_results).should have_tag('span', /all/)
      end


    end

  end

  describe "#icon" do
    it "should return an image tag to an icon" do
      helper.icon('foo').should have_tag('img[src=?]', image_path('icons/foo.png'))
    end
  end

  # TODO: Figure out how to test rendering from a partial
  describe "#report_status_td" do; end
  describe "#report_status_icon" do; end
  describe "#node_status_icon" do; end

  describe "#counter_class" do
    context "when measuring failure" do
      it "should be 'success' if count is zero" do
        helper.counter_class(0, true).should == 'success'
      end

      it "should be 'failure' if count is greater than zero" do
        helper.counter_class(1, true).should == 'failure'
      end
    end

    context "when measuring success" do
      it "should be 'success' if count is zero" do
        helper.counter_class(0, false).should == 'success'

      end

      it "should be 'success' if count is greater than zero" do
        helper.counter_class(1, false).should == 'success'
      end
    end
  end

  describe "#describe_search_if_present" do
    it "should describe an active search" do
      params[:q] = 'foo'
      helper.describe_search_if_present.should == 'matching &ldquo;foo&rdquo;'
    end

    it "should return nil if no search active" do
      helper.describe_search_if_present.should be_nil
    end
  end

  describe "#describe_no_matches_as" do
    it "should return a no matches message" do
      helper.describe_no_matches_as("Specific message").should == "<span class='nomatches'>&mdash; Specific message &mdash;</span>"
    end
  end

  describe "#describe_no_matches_for" do
    context "when not searching" do
      it "should return a message for the listing" do
        helper.describe_no_matches_for(:reports).should == "<span class='nomatches'>&mdash; No reports found &mdash;</span>"
      end

      it "should return a message for the listing and subject" do
        helper.describe_no_matches_for(:reports, :node).should == "<span class='nomatches'>&mdash; No reports found for this node &mdash;</span>"
      end
    end

    context "when searching" do
      before :each do
        params[:q] = 'query'
      end

      it "should return a message for the listing plus the search" do
        helper.describe_no_matches_for(:reports).should == "<span class='nomatches'>&mdash; No reports found matching &ldquo;query&rdquo; &mdash;</span>"
      end

      it "should return a message for the listing and subject plus the search" do
        helper.describe_no_matches_for(:reports, :node).should == "<span class='nomatches'>&mdash; No reports found for this node matching &ldquo;query&rdquo; &mdash;</span>"
      end
    end
  end

  describe "tokenize_input_class" do
    before :each do
      @objects = Array.new(6) { NodeGroup.generate! }
    end

    context "when given a single input" do
      context "and :objects is empty?" do
        it "should give an empty JSON array for prePopulate" do
          helper.tokenize_input_class({:class => '#class', :data_source => '/data.json', :objects => []}).should include('prePopulate: []')
        end
      end

      context "and :objects is not empty?" do
        it "should JSONify a single object" do
          target = @objects.first
          text = helper.tokenize_input_class({:class => '#class', :data_source => '/data.json', :objects => [target]})
          json_data = get_prepopulate_json_data(text)

          json_data.should include({"id" => target.id, "name" => target.name})
        end

        it "should JSONify multiple objects" do
          text = helper.tokenize_input_class({:class => '#class', :data_source => '/data.json', :objects => @objects[0..2]})
          json_data = get_prepopulate_json_data(text)
          json_data.should have(3).items

          (0..2).each do |idx|
            json_data.should include({"id" => @objects[idx].id, "name" => @objects[idx].name})
          end
        end
      end

      def get_prepopulate_json_data(text)
          json_data = ActiveSupport::JSON.decode(text[/prePopulate: (\[.*?\])/m, 1])
      end
    end

    context "when given multiple inputs" do
      context "and all :objects are empty?" do
        it "should give empty JSON arrays for prePopulate" do
          input_classes = []
          (1..3).each do |idx|
            input_classes << {:class => "#class#{idx}", :data_source => "/data#{idx}.json", :objects => []}
          end
          text = helper.tokenize_input_class(*input_classes)

          get_json_struct_for_token_list(text, '#class1').should be_empty
          get_json_struct_for_token_list(text, '#class2').should be_empty
          get_json_struct_for_token_list(text, '#class3').should be_empty
        end
      end

      context "and some :objects are empty?" do
        before :each do
          input_classes = []
          input_classes << {:class => "#class1", :data_source => "/data1.json", :objects => []}
          input_classes << {:class => "#class2", :data_source => "/data2.json", :objects => @objects[0..1]}
          input_classes << {:class => "#class3", :data_source => "/data3.json", :objects => [@objects[2]]}
          @text = helper.tokenize_input_class(*input_classes)
        end

        it "should be able to generate an empty JSON array" do
          get_json_struct_for_token_list(@text, '#class1').should be_empty
        end

        it "should be able to generate multiple elements in the JSON array" do
          get_json_struct_for_token_list(@text, '#class2').should include({"id" => @objects[0].id, "name" => @objects[0].name})
          get_json_struct_for_token_list(@text, '#class2').should include({"id" => @objects[1].id, "name" => @objects[1].name})
        end

        it "should be able to generate a single element in the JSON array" do
          get_json_struct_for_token_list(@text, '#class3').should include({"id" => @objects[2].id, "name" => @objects[2].name})
        end
      end

      context "and no :objects are empty?" do
        before :each do
          input_classes = []
          input_classes << {:class => "#class1", :data_source => "/data1.json", :objects => [@objects[0]]}
          input_classes << {:class => "#class2", :data_source => "/data2.json", :objects => @objects[1..2]}
          @text = helper.tokenize_input_class(*input_classes)
        end

        it "should be able to generate a single element JSON array" do
          get_json_struct_for_token_list(@text, '#class1').should include({"id" => @objects[0].id, "name" => @objects[0].name})
        end

        it "should be able to generate a multiple element JSON array" do
          get_json_struct_for_token_list(@text, '#class2').should include({"id" => @objects[1].id, "name" => @objects[1].name})
          get_json_struct_for_token_list(@text, '#class2').should include({"id" => @objects[2].id, "name" => @objects[2].name})
        end
      end

      def get_json_struct_for_token_list(text, selector)
        json = text[/'#{selector}'.+?prePopulate: (\[.*?\])/m, 1]
        ActiveSupport::JSON.decode(json)
      end
    end
  end
end
