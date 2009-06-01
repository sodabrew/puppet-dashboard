require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe CommentsController, "#resource_saved" do
  describe "Comment.new(<invalid attrs>)" do
    before { @controller.resource = Comment.new }
    
    it { @controller.should_not be_resource_saved }
  
    describe ".save" do
      before { @controller.resource.save }

      it { @controller.should_not be_resource_saved }

      describe "then update_attributes(<valid attrs>)" do
        before { @controller.resource.update_attributes :user => User.create!, :post => Post.create! }
        
        it { @controller.should be_resource_saved }
      end
    end
  end
    
  describe "Comment.find(<id>)" do
    before do
      Comment.create! :user => User.create!, :post => Post.create!
      @controller.resource = Comment.find(:first)
    end
    
    it { @controller.should be_resource_saved }

    it ".save should be saved" do
      @controller.resource.save
      @controller.should be_resource_saved
    end

    describe "then update_attributes(<invalid attrs>)" do
      before { @controller.resource.update_attributes :user => nil }
      
      it { @controller.should_not be_resource_saved }
    end
    
    describe "then update_attributes(<new valid attrs>)" do
      before { @controller.resource.update_attributes :user => User.create! }
      
      it { @controller.should be_resource_saved }
    end
  end
end