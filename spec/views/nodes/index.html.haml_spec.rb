
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

  it 'should have a list of nodes' do
    pending "Only in layout"
    do_render
    response.should have_tag('tr.node', :count => @nodes.size)
  end

  describe 'each node' do
    it 'should have a heading with the node name' do
      pending "Only in layout"
      do_render
      response.should have_tag('tr.node td.name', :text => @nodes.first.name)
    end
  end
end
