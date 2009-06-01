require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "(re: saved?) Comment" do
  describe ".new(<invalid attrs>)" do
    before { @comment = Comment.new }
    
    it { @comment.should_not be_validation_attempted }
    it { @comment.should_not be_saved }

    describe ".save" do
      before { @comment.save }

      it { @comment.should be_validation_attempted }
      it { @comment.should_not be_saved }

      describe "then update_attributes(<valid attrs>)" do
        before { @comment.update_attributes :user => User.create!, :post => Post.create! }
        
        it { @comment.should be_validation_attempted }
        it { @comment.should be_saved }
      end
    end
  end
end