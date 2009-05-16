require File.dirname(__FILE__) + '/spec_helper'
require 'fileutils'

describe 'the plugin install.rb script' do
  before :each do
    FileUtils.stubs(:mkdir)
    self.stubs(:puts).returns(true)
  end
  
  def do_install
    eval File.read(File.join(File.dirname(__FILE__), *%w[.. install.rb ]))
  end
  
  describe 'when there is a spec directory under RAILS_ROOT' do
    before :each do
      File.stubs(:directory?).with('./../../../spec').returns(true)      
    end
    
    describe 'and there is a spec/exemplars directory under RAILS_ROOT' do
      before :each do
        File.stubs(:directory?).with('./../../../spec/exemplars').returns(true)      
      end
      
      it 'should not create any new directories' do
        FileUtils.expects(:mkdir).never
        do_install
      end
    end
    
    describe 'but there is no spec/exemplars directory under RAILS_ROOT' do
      before :each do
        File.stubs(:directory?).with('./../../../spec/exemplars').returns(false)      
      end
            
      it 'should create a spec/exemplars directory under RAILS_ROOT' do        
        FileUtils.expects(:mkdir).with('./../../../spec/exemplars')
        do_install
      end
    end
  end
  
  describe 'when there is no spec directory under RAILS_ROOT' do
    before :each do
      File.stubs(:directory?).with('./../../../spec').returns(false)      
    end
    
    describe 'and there is a test directory under RAILS_ROOT' do
      before :each do
        File.stubs(:directory?).with('./../../../test').returns(true)      
      end

      describe 'and there is a test/exemplars directory under RAILS_ROOT' do
        before :each do
          File.stubs(:directory?).with('./../../../test/exemplars').returns(true)      
        end

        it 'should not create any new directories' do
          FileUtils.expects(:mkdir).never
          do_install
        end
      end
      
      describe 'but there is no test/exemplars directory under RAILS_ROOT' do
        before :each do
          File.stubs(:directory?).with('./../../../test/exemplars').returns(false)      
        end

        it 'should create a test/exemplars directory under RAILS_ROOT' do
          FileUtils.expects(:mkdir).with('./../../../test/exemplars')
          do_install
        end
      end
    end
    
    describe 'and there is no test directory under RAILS_ROOT' do
      before :each do
        File.stubs(:directory?).with('./../../../test').returns(false)      
      end

      it 'should create a spec directory under RAILS_ROOT' do
        FileUtils.expects(:mkdir).with('./../../../spec')
        do_install
      end
      
      it 'should create a spec/exemplars directory under RAILS_ROOT' do
        FileUtils.expects(:mkdir).with('./../../../spec/exemplars')
        do_install
      end
    end
  end
  
  it 'displays the content of the plugin README file' do
    self.stubs(:readme_contents).returns('README CONTENTS')
    self.expects(:puts).with('README CONTENTS')
    do_install
  end
  
  describe 'readme_contents' do
    it 'should work without arguments' do
      do_install
      lambda { readme_contents }.should_not raise_error(ArgumentError)
    end
    
    it 'should accept no arguments' do
      do_install
      lambda { readme_contents(:foo) }.should raise_error(ArgumentError)
    end
    
    it 'should read the plugin README file' do
      do_install
      File.stubs(:join).returns('/path/to/README')
      IO.expects(:read).with('/path/to/README')
      readme_contents
    end
    
    it 'should return the contents of the plugin README file' do
      do_install
      File.stubs(:join).returns('/path/to/README')
      IO.stubs(:read).with('/path/to/README').returns('README CONTENTS')
      readme_contents.should == 'README CONTENTS'
    end
  end
end