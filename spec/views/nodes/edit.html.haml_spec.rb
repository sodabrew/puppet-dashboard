require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/edit' do
  before :each do
    assigns[:node] = @node = Node.generate!
    params[:id] = @node.name
  end

  def do_render
    render '/nodes/edit'
  end

  describe 'when errors are available' do
    it 'should display errors if name is blank' do
      @node.name = ''
      @node.valid?
      do_render
      response.should have_tag('div.errors')
    end
  end

  describe 'when no errors are available' do
    it 'should not display error messages' do
      do_render
      response.should_not have_tag('div.errors')
    end
  end

  it 'should have a form for editing the node' do
    do_render
    response.should have_tag('form[id=?]', "edit_node_#{@node.id}")
  end

  describe 'the node edit form' do
    it 'should post to the update node action' do
      do_render
      response.should have_tag('form[id=?][method=?][action=?]', "edit_node_#{@node.id}", 'post', node_path(@node))
    end

    it 'should set the form method to PUT' do
      do_render
      response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
        with_tag('input[name=?][value=?]', '_method', 'put')
      end
    end

    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
        with_tag('input[type=?][name=?]', 'text', 'node[name]')
      end
    end

    it 'should populate the name input' do
      @node.name = 'Test Node'
      do_render
      response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
        with_tag('input[name=?][value=?]', 'node[name]', @node.name)
      end
    end

    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
        with_tag('textarea[name=?]', 'node[description]')
      end
    end

    it 'should populate the description input' do
      @node.description = 'Test Description'
      do_render
      response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
        with_tag('textarea[name=?]', 'node[description]', @node.description)
      end
    end
  end
  
  describe 'class editing interface' do
    before :all do
      NodeClass.delete_all
    end
    
    before :each do
      @classes = Array.new(6) { NodeClass.generate! }
      @node.node_classes << @classes[0..2]
    end

    it 'should provide a means to edit the associated classes' do
      do_render
      response.should have_tag('input[id=node_class_names]')
    end
    
    it 'should show the associated classes' do
      do_render
      response.should have_tag('ul[id=existing_node_classes]')
    end
    
    it 'should show each associated class in the associated classes section' do
      do_render
      response.should have_tag('ul#existing_node_classes') do
        @node.node_classes.each do |node_class|
          with_tag('li', :text => Regexp.new(Regexp.escape(node_class.name)))
        end
      end
    end
    
    it 'should provide a remove link for each associated class'
    it 'should show the classes available to be associated'
    it 'should show non-associated classes in the classes available to be associated section'
    it 'should provide an associate link for each available class'
  end

  it 'should link to view the node' do
    do_render
    response.should have_tag('a[href=?]', node_path(@node))
  end
end
