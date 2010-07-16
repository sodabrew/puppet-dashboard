require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'shared_behaviors/controller_mixins'

describe NodeClassesController do
  def model; NodeClass end

  it_should_behave_like "without JSON pagination"
  it_should_behave_like "with search by q and tag"

end
