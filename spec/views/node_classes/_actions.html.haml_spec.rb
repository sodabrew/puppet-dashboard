require 'spec_helper'

describe "/node_classes/_actions.html.haml" do
  include NodeClassesHelper

  describe "successful render" do
    before { render }

    it { rendered.should have_tag('a', :with => { :href => new_node_class_path }) }
  end
end
