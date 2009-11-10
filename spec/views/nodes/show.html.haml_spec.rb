require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/show' do
  before :each do
    assigns[:node] = @node = Node.generate!
  end

  def do_render
    render '/nodes/show'
  end

  it 'should render successfully' do
    do_render
  end
  
  it 'should include the node name' do
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@node.name)))
  end
  
  it 'should include the node description' do
    @node.description = 'Test Description'
    do_render
    response.should have_text(Regexp.new(Regexp.escape(@node.description)))
  end
  
  it "should include the node's parameter settings" do
    @node.parameters = { 'a' => 'b', 'c' => 'd' }
    do_render
    @node.parameters.each_pair do |key, value|
      response.should have_tag('td.key', :text => key)
      response.should have_tag('td', :text => value)
    end
  end
  
  it "should include the node's class list" do
    @node_classes = Array.new(3) { NodeClass.generate! }
    @node.node_classes << @node_classes
    do_render
    @node_classes.each do |node_class|
      response.should have_text(Regexp.new(Regexp.escape(node_class.name)))
    end
  end
  
  it 'should include a link to edit the node' do
    do_render
    response.should have_tag('a[href=?]', edit_node_path(@node))
  end
  
  it 'should include a link to delete the node' do
    do_render
    response.should have_tag('a[href=?]', node_path(@node))
  end
end
