require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesHelper do

  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(PagesHelper)
  end

  describe '#percentage' do
    describe 'with appropriate values passed in' do
      it 'should report the ratio of those values' do
        helper.percentage(50,100).should == 50
        helper.percentage(40,100).should == 40
        helper.percentage(1,3).should == 33.3
        helper.percentage(1,0).should == 0
      end
    end
  end

end
