require 'spec_helper'

describe "/node_classes/show.html.haml", :type => :view do
  include NodeClassesHelper

  describe "successful render" do
    before :each do
      assigns[:node_class] = @node_class = create(:node_class)
      render
    end

    it { rendered.should have_tag 'h2', :text => /Class:\n#{@node_class.name}/ }
  end
end
