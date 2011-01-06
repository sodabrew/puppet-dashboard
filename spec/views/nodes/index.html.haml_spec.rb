
require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/index' do
  before :each do
    assigns[:nodes] = @nodes = [Node.generate!]
  end

  def do_render
    render '/nodes/index'
  end

  describe "search fields" do
    before :each do
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
