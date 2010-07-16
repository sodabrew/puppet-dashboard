require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ApplicationHelper do

  #Delete this example and add some real ones or delete this file
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
    before do
      @template.stubs( :request => request, :params => params, :url_for => 'someurl')
    end

    context "when given paginated records" do
      subject { helper.pagination_for([*(1..100)].paginate) }

      it { should have_tag('div.actionbar') }
      it { should have_tag('a', /Next/) }
    end

    context "when not given paginated records" do
      subject { helper.pagination_for([]) }

      it { should be_nil }
    end

  end

end
