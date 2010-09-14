describe "with search by q and tag", :shared => true do
  describe "without a search" do
    before { get 'index' }
    subject { assigns[:node_groups] }

    it "returns all node groupes" do
      should == model.all
    end
  end

  describe "with a 'tag' search" do
    before { get 'index', :tag => 'for_tag' }
    subject { assigns[:node_groups] }

    it "returns node groupes whose name contains the term" do
      subject.all?{|node_group| node_group.name.include?('for_tag')}.should be_true
    end
  end

  describe "with a 'q' search" do
    before { get 'index', :q => 'for_q' }
    subject { assigns[:node_groups] }

    it "returns node groupes whose name contains the term" do
      subject.all?{|node_group| node_group.name.include?('for_q')}.should be_true
    end
  end
end

describe "without JSON pagination", :shared => true do
  describe "GET index" do
    before :each do
      @for_tag = NodeGroup.generate(:name => 'for_tag')
      @for_q = NodeGroup.generate(:name => 'for_q')
      NodeGroup.generate(:name => 'without_search')
    end

    describe "as HTML" do
      before { get 'index', :format => 'html' }
      subject { assigns[:node_groups] }

      it "paginates by the page parameter" do
        should be_a_kind_of(WillPaginate::Collection)
      end
    end

    describe "as JSON" do
      before { get 'index', :format => 'json' }
      subject { assigns[:node_groups] }

      it "does not paginate" do
        should_not be_a_kind_of(WillPaginate::Collection)
      end
    end
  end
end

