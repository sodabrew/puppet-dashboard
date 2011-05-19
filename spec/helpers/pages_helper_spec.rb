require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesHelper do
  
  #Delete this example and add some real ones or delete this file
  it "should be included in the object returned by #helper" do
    included_modules = (class << helper; self; end).send :included_modules
    included_modules.should include(PagesHelper)
  end

  describe '#percentage' do
    before :each do
      helper.instance_variable_set(:@nodes, @nodes = [])
    end

    describe 'with values in @nodes' do
      before :each do
        @nodes.push(*%w[ a b c d e f g h i j ])
      end

      it 'should report the ratio of given list length to @nodes' do
        helper.percentage(%w[ a b c d e ]).should == 50
        helper.percentage(%w[ a b c z ]).should == 40
      end
    end
  end

end
