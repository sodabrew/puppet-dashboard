require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaginateScopeHelper do
  describe "#paginate_scope" do
    it "should paginate the scope" do
      helper.paginate_scope([1,2,3]).should be_a_kind_of(WillPaginate::Collection)
    end
  end
end
