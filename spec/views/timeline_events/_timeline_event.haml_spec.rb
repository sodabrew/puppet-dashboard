require 'spec_helper'

describe "/timeline_events/_timeline_event.html.haml" do
  context "with a node" do
    before :each do
      @node = Node.generate!
      @node.name.swapcase!
      @node.save!

      @node_class = NodeClass.generate! 
      @node.node_classes << @node_class

      @parameter = Parameter.generate! :parameterable => @node
      @node.reload
    end

    context "when this node is the subject" do
      before :each do
        subject = @node.timeline_events.first(:conditions => {:subject_type => "Node", :event_type => "created"})
        view.stubs(:timeline_event => subject)
        render
      end

      subject { rendered }

      it "should describe the action on this node" do
        should =~ /This node\s+was created/
      end
    end

    context "when something else is the subject" do
      context "and is linkable" do
        before :each do
          subject = @node.timeline_events.first(:conditions => {:subject_type => "NodeClass", :event_type => "added_to"})
          view.stubs(:timeline_event => subject)
          render
        end

        subject { rendered }

        it "should describe the action on that subject" do
          should =~ /NodeClass.+?#{@node_class.name}.+?was added to\s+this node/sm
        end

        it "should link to the subject" do
          should have_tag 'a', :with => { :href => node_class_path(@node_class) }, :text => @node_class.name
        end
      end

      context "and is not linkable" do
        before :each do
          subject = @node.timeline_events.first(:conditions => {:subject_type => "Parameter", :event_type => "added_to"})
          view.stubs(:timeline_event => subject)
          render
        end

        subject { rendered }

        it "should describe the action on that subject" do
          should =~ /#{ERB::Util.html_escape(@parameter.name)}\s+was added to\s+this node/sm
        end

        it "should not link to the subject" do
          should_not have_tag 'a'
        end
      end
    end

    context "without an assigned node" do
      before :each do
        view.stubs(:timeline_event => @node.timeline_events.first)
        @node = nil
        render
      end

      subject { rendered }

      it "should do nothing" do
        should be_blank
      end
    end
  end

  context "wihtout a timeline_event" do
    before :each do
      view.stubs(:timeline_event => nil)
      render
    end

    subject { rendered }

    it "should do nothing" do
      should be_blank
    end
  end

end
