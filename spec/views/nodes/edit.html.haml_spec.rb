require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/edit' do
  before :each do
    assigns[:node] = @node = Node.generate!
  end

  def do_render
    render '/nodes/edit'
  end

  describe 'when errors are available' do
    it 'should display errors in an error region' do
      @node.name = nil
      @node.valid?
      do_render
      response.should have_tag('div[class=?]', 'errors', :text => /error/)
    end
  end

  describe 'when no errors are available' do
    it 'should not display error messages' do
      do_render
      response.should have_tag('div[class=?]', 'errors', :text => '')
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
        
    describe 'when the node has no parameters' do
      before :each do
        @node.parameters = []
      end
      
      it 'should have a blank input for parameters' do
        do_render
        response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'node[parameters][]')
        end
      end
    end
    
    describe 'when the node has nil parameters' do
      before :each do
        @node.parameters = nil
      end
      
      it 'should have a blank input for parameters' do
        do_render
        response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'node[parameters][]')
        end
      end
    end
    
    describe 'when the node has parameters' do
      before :each do
        @parameters = %w[one two three]
        @node.parameters = @parameters
      end
      
      it 'should have an input for each parameter' do
        do_render
        response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
          @parameters.each do |parameter|
            with_tag('input[type=?][name=?][value=?]', 'text', 'node[parameters][]', parameter)
          end
        end
      end
      
      it 'should not have a blank input for parameters' do
        pending 'finding the right way to test this'
        do_render
        response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
          with_tag('input[type=?][name=?]:not([value])', 'text', 'node[parameters][]')
        end
      end
    end
    
    it 'should have a link to add a new parameter' do
      pending 'testing some JS stuffs'
    end
    
    it 'should have a link to delete an existing parameter' do
      pending 'testing some JS stuffs'
    end
    
    it 'should allow submitting' do
      do_render
      response.should have_tag('form[id=?]', "edit_node_#{@node.id}") do
        with_tag('input[type=?]', 'submit')
      end
    end
  end

  it 'should link to view the node' do
    do_render
    response.should have_tag('a[href=?]', node_path(@node))
  end
end
