require File.expand_path(File.join(File.dirname(__FILE__), *%w[.. .. spec_helper]))

describe '/nodes/edit' do
  before :each do
    assigns[:node] = @node = Node.generate!
    params[:id] = @node.id
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

  describe 'for the node edit form' do
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

  describe 'editing interface' do
    describe "for parameters" do
      before :each do
        @node.parameter_attributes = [{:key => 'foo', :value => 'bar'}]
      end

      it "should allow editing parameters with node classification enabled" do
        SETTINGS.stubs(:use_external_node_classification).returns(true)

        render

        response.should have_tag('table#parameters')
      end

      it "should not allow editing parameters with node classification disabled" do
        SETTINGS.stubs(:use_external_node_classification).returns(false)

        render

        response.should_not have_tag('table#parameters')
      end
    end

    describe 'for classes' do
      before :each do
        @classes = Array.new(6) { NodeClass.generate! }
        @node.node_classes << @classes[0..2]
        assigns[:class_data] = {:class => '#node_class_ids', :data_source => node_classes_path(:format => :json), :objects => @node.node_classes}
      end

      it 'should provide a means to edit the associated classes when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)

        do_render
        response.should have_tag('input#node_class_ids')
      end

      it 'should not provide a means to edit the associated classes when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)

        do_render
        response.should_not have_tag('input#node_class_ids')
      end

      it 'should show the associated classes when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
        do_render

        response.should have_tag('#tokenizer') do
          struct = get_json_struct_for_token_list('#node_class_ids')
          struct.should have(3).items

          (0..2).each do |idx|
            struct.should include({"id" => @classes[idx].id, "name" => @classes[idx].name})
          end
        end
      end

      it 'should not show the associated classes when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
        do_render

        response.should_not have_tag('#node_class_ids')
      end
    end

    describe 'for groups' do
      before :each do
        @groups = Array.new(6) {NodeGroup.generate! }
        @node.node_groups << @groups[0..3]
        assigns[:group_data] = {:class => '#node_group_ids', :data_source => node_groups_path(:format => :json),  :objects => @node.node_groups}
      end

      it 'should show the associated groups when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
        do_render

        response.should have_tag('#tokenizer') do
          struct = get_json_struct_for_token_list('#node_group_ids')
          struct.should have(4).items

          (0..3).each do |idx|
            struct.should include({"id" => @groups[idx].id, "name" => @groups[idx].name})
          end
        end
      end

      it 'should show associated groups when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
        do_render

        response.should have_tag('#tokenizer') do
          struct = get_json_struct_for_token_list('#node_group_ids')
          struct.should have(4).items

          (0..3).each do |idx|
            struct.should include({"id" => @groups[idx].id, "name" => @groups[idx].name})
          end
        end
      end
    end

    def get_json_struct_for_token_list(selector)
      json = response.body[/'#{selector}'.+?prePopulate: (\[.*?\])/m, 1]
      ActiveSupport::JSON.decode(json)
    end
  end

  it 'should link to view the node' do
    do_render
    response.should have_tag('a[href=?]', node_path(@node))
  end
end
