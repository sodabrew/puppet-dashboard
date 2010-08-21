
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/index' do
  before :each do
    assigns[:nodes] = @nodes = [Node.generate!]
  end

  def do_render
    render '/nodes/index'
  end

  it 'should render successfully' do
    pending "Testing inherited resources views"
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

  describe "search fields" do
    before do
      template.stubs(
        :action_name => 'index',
        :parent => nil
      )
    end

    it "should not have :current or :successful if these aren't defined" do
      do_render
      should_not have_tag('.search input#current')
      should_not have_tag('.search input#successful')
    end

    it "should should have only :current if only it's defined" do
      params[:current] = "true"
      do_render
      should have_tag('.search input#current[type=hidden][value=true]')
      should_not have_tag('.search input#successful')
    end

    it "should should have only :successful if only it's defined" do
      params[:successful] = "false"
      do_render
      should_not have_tag('.search input#current')
      should have_tag('.search input#successful[type=hidden][value=false]')
    end

    it "should should both :current and :successful if both are defined" do
      params[:current] = "true"
      params[:successful] = "false"
      do_render
      should have_tag('.search input#current[type=hidden][value=true]')
      should have_tag('.search input#successful[type=hidden][value=false]')
    end
  end
end
