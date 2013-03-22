require 'spec_helper'

describe "/node_groups/_search.html.haml" do
  include NodeGroupsHelper

  describe "successful render" do
    before { render }

    it { rendered.should have_tag('form.search') }
  end
end
