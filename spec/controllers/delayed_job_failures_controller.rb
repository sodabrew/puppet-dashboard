require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'shared_behaviors/controller_mixins'

describe DelayedJobFailuresController do
  def model; DelayedJobFailure end
  it_should_behave_like "without JSON pagination"

  it "should mark events read when asked" do
    event = DelayedJobFailure.create!(:summary => "foo").id
    DelayedJobFailure.find(event).read.should be_false
    post :index, :mark_all_read => nil
    DelayedJobFailure.find(event).read.should be_true
  end
end
