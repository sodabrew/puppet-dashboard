require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

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

      assigns[:node] = @node
    end

    context "when this node is the subject" do
      before :each do
        subject = @node.timeline_events.first(:conditions => {:subject_type => "Node", :event_type => "created"})
        template.stubs(:timeline_event => subject)
        render
      end

      subject { response }

      it "should describe the action on this node" do
        should have_text /This node\s+was created/
      end
    end

    context "when something else is the subject" do
      context "and is linkable" do
        before :each do
          subject = @node.timeline_events.first(:conditions => {:subject_type => "NodeClass", :event_type => "added_to"})
          template.stubs(:timeline_event => subject)
          render
        end

        subject { response }

        it "should describe the action on that subject" do
          should have_text /NodeClass.+?#{@node_class.name}.+?was added to\s+this node/sm
        end

        it "should link to the subject" do
          should have_tag 'a[href=?]', node_class_path(@node_class), @node_class.name
        end
      end

      context "and is not linkable" do
        before :each do
          subject = @node.timeline_events.first(:conditions => {:subject_type => "Parameter", :event_type => "added_to"})
          template.stubs(:timeline_event => subject)
          render
        end

        subject { response }

        it "should describe the action on that subject" do
          should have_text /#{@parameter.name}\s+was added to\s+this node/sm
        end

        it "should not link to the subject" do
          should_not have_tag 'a'
        end
      end
    end

    context "without an assigned node" do
      before :each do
        template.stubs(:timeline_event => @node.timeline_events.first)
        assigns[:node] = nil
        render
      end

      subject { response }

      it "should do nothing" do
        should be_blank
      end
    end
  end

  context "wihtout a timeline_event" do
    before :each do
      template.stubs(:timeline_event => nil)
      render
    end

    subject { response }

    it "should do nothing" do
      should be_blank
    end
  end

end
