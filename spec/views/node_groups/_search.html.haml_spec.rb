require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/_search.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before { render }

    specify { response.should be_a_success }
    it { should have_tag('form.search') }
  end
end
