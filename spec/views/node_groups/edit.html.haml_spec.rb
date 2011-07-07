require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/node_groups/edit.html.haml" do
  include NodeGroupsHelper

  describe "when successfully rendered" do
    before :each do
      assigns[:node_group] = @node_group = NodeGroup.generate!
    end

    specify { render; response.should be_a_success }
    it { render; should have_tag('form[method=post][action=?]', node_group_path(@node_group)) }

    describe "in editing interface" do
      describe "for parameters" do
        before :each do
          @node_group.parameter_attributes = [{:key => 'foo', :value => 'bar'}]
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

      describe "for classes" do
        before :each do
          @classes = Array.new(6) { NodeClass.generate! }
          @node_group.node_classes << @classes[0..2]
          assigns[:class_data] = {:class => '#node_class_ids', :data_source => node_classes_path(:format => :json), :objects => @node_group.node_classes}

          render
        end

        it 'should provide a means to edit the associated classes' do
          response.should have_tag('input#node_class_ids')
        end

        it 'should show the associated classes' do
          response.should have_tag('#tokenizer') do
            struct = get_json_struct_for_token_list('#node_class_ids')
            struct.should have(3).items

            (0..2).each do |idx|
              struct.should include({"id" => @classes[idx].id, "name" => @classes[idx].name})
            end
          end
        end
      end

      describe "for groups" do
        before :each do
          @groups = Array.new(6) { NodeGroup.generate! }
          @node_group.node_groups << @groups[0..3]
          assigns[:group_data] = {:class => '#node_group_ids', :data_source => node_groups_path(:format => :json),  :objects => @node_group.node_groups}

          render
        end

        it 'should provide a means to edit the associated groups' do
          response.should have_tag('input[id=node_group_ids]')
        end

        it 'should show the associated groups' do
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
  end
end
