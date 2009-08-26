require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/connect' do
  before :each do
    assigns[:node] = @node = Node.generate!
    @services = Array.new(6) { Service.generate! }
    @node.services << @services[0..2]
    assigns[:available_services] = @available = @services[3..5]
  end

  def do_render
    render '/nodes/connect'
  end

  it 'should show the associated classes' do
    do_render
    response.should have_tag('div[id=?]', 'associated-classes')
  end
  
  it 'should show each associated class in the associated classes section' do
    do_render
    response.should have_tag('div[id=?]', 'associated-classes') do
      @node.services.each do |service|
        with_tag('li', :text => Regexp.new(Regexp.escape(service.name)))
      end
    end
  end
  
  it 'should provide a remove link for each associated class' do
    do_render
    response.should have_tag('div[id=?]', 'associated-classes') do
      @node.services.each do |service|
        with_tag('a[href=?]', disconnect_service_node_path(service, @node))
      end
    end      
  end
  
  it 'should show the classes available to be associated' do
    do_render
    response.should have_tag('div[id=?]', 'available-classes')
  end
  
  it 'should show non-associated classes in the classes available to be associated section' do
    do_render
    response.should have_tag('div[id=?]', 'available-classes') do
      @available.each do |service|
        with_tag('li', :text => Regexp.new(Regexp.escape(service.name)))
      end
    end
  end
  
  it 'should provide an associate link for each available class' do
    do_render
    response.should have_tag('div[id=?]', 'available-classes') do
      @available.each do |service|
        with_tag('a[href=?]', connect_service_node_path(service, @node))
      end
    end
  end
end
