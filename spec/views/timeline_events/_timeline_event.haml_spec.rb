require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/timeline_events/_timeline_event.haml" do
  context "with a node" do
    before do
      @node = Node.generate!
      @node.name.swapcase!
      @node.save!

      @class = NodeClass.generate!

      @node.node_classes << @class

      assigns[:node] = @node
    end

    context "when this node is the subject" do
      before do
        template.stubs(:timeline_event => @node.timeline_events.first(:conditions => {:event_type => "created"}))
        render
      end

      subject { response }

      it "should describe the action on this node" do
        should have_text /This node\s+was created/
      end
    end

    context "when something else is the subject" do
      before do
        template.stubs(:timeline_event => @node.timeline_events.first(:conditions => {:event_type => "added_to"}))
        render
      end

      subject { response }

      it "should describe the action on that something" do
        should have_text /NodeClass.+?#{@class.name}.+?was added to\s+this node/sm
      end
    end

    context "without an assigned node" do
      before do
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
    before do
      template.stubs(:timeline_event => nil)
      render
    end

    subject { response }

    it "should do nothing" do
      should be_blank
    end
  end

end
