
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/index' do
  before :each do
    assigns[:nodes] = @nodes = [Node.generate!]
  end

  def do_render
    render '/nodes/index'
  end

  it 'should render successfully' do
    do_render
  end

  it 'should have a header' do
    do_render
    response.should have_tag('#nodes h2', :text => /Nodes/)
  end
  
  it 'should have a list of nodes' do
    do_render
    response.should have_tag('.node', :count => @nodes.size)
  end

  describe 'each node' do
    it 'should have a heading with the node name' do
      do_render
      response.should have_tag('.node h3', :text => @nodes.first.name)
    end
  end
end
