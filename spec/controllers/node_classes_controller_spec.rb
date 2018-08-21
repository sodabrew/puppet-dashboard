require 'spec_helper'
require 'shared_behaviors/controller_mixins'
require 'shared_behaviors/sorted_index'

describe NodeClassesController, :type => :controller do
  def model; NodeClass end

  it_should_behave_like "without JSON pagination"
  it_should_behave_like "with search by q and tag"
  it_should_behave_like "sorted index"

end
