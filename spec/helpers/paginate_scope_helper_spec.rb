require 'spec_helper'

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

    it "should return the last page if page * per_page > count" do
      params[:page] = '3'
      params[:per_page] = '2'
      paginated_scope = helper.paginate_scope([1,2,3])
      paginated_scope.should be_a_kind_of(WillPaginate::Collection)
      paginated_scope.total_pages.should == 2
      paginated_scope.count.should == 1
      paginated_scope.current_page.should == 2
      paginated_scope.per_page.should == 2
    end

    it "should return the first page if page is negative" do
      params[:page] = '-5'
      params[:per_page] = '2'
      paginated_scope = helper.paginate_scope([1,2,3])
      paginated_scope.should be_a_kind_of(WillPaginate::Collection)
      paginated_scope.total_pages.should == 2
      paginated_scope.count.should == 2
      paginated_scope.current_page.should == 1
      paginated_scope.per_page.should == 2
    end

    it "should return the first page if page is not a number" do
      params[:page] = 'notanumber'
      params[:per_page] = '2'
      paginated_scope = helper.paginate_scope([1,2,3])
      paginated_scope.should be_a_kind_of(WillPaginate::Collection)
      paginated_scope.total_pages.should == 2
      paginated_scope.count.should == 2
      paginated_scope.current_page.should == 1
      paginated_scope.per_page.should == 2
    end

    it "should use default per_page if per_page is not a number" do
      params[:page] = 'notanumber'
      params[:per_page] = 'notanumber'
      paginated_scope = helper.paginate_scope([1,2,3])
      paginated_scope.should be_a_kind_of(WillPaginate::Collection)
      paginated_scope.total_pages.should == 1
      paginated_scope.count.should == 3
      paginated_scope.current_page.should == 1
      paginated_scope.per_page.should == 30 # In will_paginate v3, it is WillPaginate.per_page
    end
  end
end
