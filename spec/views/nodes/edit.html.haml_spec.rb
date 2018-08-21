require 'spec_helper'

describe '/nodes/edit', :type => :view do
  before :each do
    @node = create(:node)
  end

  def do_render
    render :template => '/nodes/edit'
  end

  describe 'when errors are available' do
    it 'should display errors if name is blank' do
      @node.name = ''
      @node.valid?
      do_render
      rendered.should have_tag('div.field_with_errors')
    end
  end

  describe 'when no errors are available' do
    it 'should not display error messages' do
      do_render
      rendered.should_not have_tag('div.field_with_errors')
    end
  end

  it 'should have a form for editing the node' do
    do_render
    response.should have_tag('form[id=param_form]')
  end

  describe 'for the node edit form' do
    it 'should post to the update node action' do
      do_render
      response.should have_tag('form[method=post]', :with => { :id => "param_form", :action => node_path(@node.id) })
    end

    it 'should set the form method to PATCH' do
      do_render
      response.should have_tag('form[id=param_form]') do
        with_tag('input[name=_method][value=patch]')
      end
    end

    it 'should have a name input' do
      do_render
      response.should have_tag('form[id=param_form]') do
        with_tag('input[type=text]', :with => { :name => 'node[name]' })
      end
    end

    it 'should populate the name input' do
      @node.name = 'Test Node'
      do_render
      response.should have_tag('form[id=param_form]') do
        with_tag('input', :with => { :name => 'node[name]', :value => @node.name })
      end
    end

    it 'should have a description input' do
      do_render
      response.should have_tag('form[id=param_form]') do
        with_tag('textarea', :with => { :name => 'node[description]' })
      end
    end

    it 'should populate the description input' do
      @node.description = 'Test Description'
      do_render
      response.should have_tag('form[id=param_form]') do
        with_tag('textarea', :with => { :name => 'node[description]' }, :text => /#{@node.description}/)
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

        rendered.should have_tag('table#parameters')
      end

      it "should not allow editing parameters with node classification disabled" do
        SETTINGS.stubs(:use_external_node_classification).returns(false)

        render

        rendered.should_not have_tag('table#parameters')
      end
    end

    describe 'for classes' do
      before :each do
        @classes = Array.new(6) { create(:node_class) }
        @node.node_classes << @classes[0..2]
        @class_data = {:class => '#node_class_ids', :data_source => node_classes_path(:format => :json), :objects => @node.node_classes}
      end

      it 'should provide a means to edit the associated classes when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)

        do_render
        rendered.should have_tag('input#node_class_ids')
      end

      it 'should not provide a means to edit the associated classes when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)

        do_render
        rendered.should_not have_tag('input#node_class_ids')
      end

      it 'should show the associated classes when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
        do_render

        rendered.should have_tag('#tokenizer')
        struct = get_json_struct_for_token_list(rendered, '#node_class_ids')
        struct.should have(3).items

        (0..2).each do |idx|
          struct.should include({"id" => @classes[idx].id, "name" => @classes[idx].name})
        end
      end

      it 'should not show the associated classes when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
        do_render

        rendered.should_not have_tag('#node_class_ids')
      end
    end

    describe 'for groups' do
      before :each do
        @groups = Array.new(6) { create(:node_group) }
        @node.node_groups << @groups[0..3]
        @group_data = {:class => '#node_group_ids', :data_source => node_groups_path(:format => :json), :objects => @node.node_groups}
      end

      it 'should show the associated groups when using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(true)
        do_render

        rendered.should have_tag('#tokenizer')
        struct = get_json_struct_for_token_list(rendered, '#node_group_ids')
        struct.should have(4).items

        (0..3).each do |idx|
          struct.should include({"id" => @groups[idx].id, "name" => @groups[idx].name})
        end
      end

      it 'should show associated groups when not using node classification' do
        SETTINGS.stubs(:use_external_node_classification).returns(false)
        do_render

        rendered.should have_tag('#tokenizer')
        struct = get_json_struct_for_token_list(rendered, '#node_group_ids')
        struct.should have(4).items

        (0..3).each do |idx|
          struct.should include({"id" => @groups[idx].id, "name" => @groups[idx].name})
        end
      end
    end

    def get_json_struct_for_token_list(string, selector)
      json = string[/'#{selector}'.+?prePopulate: (\[.*?\])/m, 1]
      ActiveSupport::JSON.decode(json)
    end
  end

  it 'should link to view the node' do
    do_render
    rendered.should have_tag('a', :with => { :href => node_path(@node.id) })
  end
end
