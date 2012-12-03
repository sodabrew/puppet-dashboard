require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PaginateScopeHelper do
  describe "#paginate_scope" do
    it "should paginate the scope" do
      helper.paginate_scope([1,2,3]).should be_a_kind_of(WillPaginate::Collection)
    end

    it "should pass in the per_page parameter" do
      params[:per_page] = 2
      helper.paginate_scope([1,2,3]).per_page.should == 2
    end

    it "should use only one page if the per_page parameter is 'all'" do
      params[:per_page] = 'all'
      paginated_scope = helper.paginate_scope([1,2,3])
      paginated_scope.should be_a_kind_of(WillPaginate::Collection)
      paginated_scope.total_pages.should == 1
      paginated_scope.per_page.should == 3
    end
  end
end
