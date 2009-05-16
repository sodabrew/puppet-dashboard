require File.dirname(__FILE__) + '/spec_helper'
require 'ostruct'
require 'object_daddy'

describe ObjectDaddy, "when included into a class" do
  before(:each) do
    @class = Class.new
    @class.send(:include, ObjectDaddy)
  end
  
  it "should provide a means of spawning a class instance" do
    @class.should respond_to(:spawn)
  end
  
  it "should not provide a means of generating and saving a class instance" do
    @class.should_not respond_to(:generate)
  end
  
  it "should not provide a means of generating and saving a class instance while raising exceptions" do
    @class.should_not respond_to(:generate!)
  end
  
  it "should provide a means of registering a generator to assist in creating class instances" do
    @class.should respond_to(:generator_for)
  end
end

describe ObjectDaddy, "when registering a generator method" do
  before(:each) do
    @class = Class.new(OpenStruct)
    @class.send(:include, ObjectDaddy)
  end
  
  it "should fail unless an attribute name is provided" do
    lambda { @class.generator_for }.should raise_error(ArgumentError)
  end
  
  it "should fail if an attribute is specified that already has a generator" do
    @class.generator_for :foo do |prev| end
    lambda { @class.generator_for :foo do |prev| end }.should raise_error(ArgumentError)
  end
  
  it "should be agnostic to attribute names specified as symbols or strings" do
    @class.generator_for :foo do |prev| end
    lambda { @class.generator_for 'foo' do |prev| end }.should raise_error(ArgumentError)
  end
  
  it "should keep generators registered for different target classes separate" do
    @class2 = Class.new
    @class2.send :include, ObjectDaddy
    @class2.generator_for :foo do |prev| end
    lambda { @class.generator_for 'foo' do |prev| end }.should_not raise_error
  end

  it "should succeed if a generator block is provided" do
    lambda { @class.generator_for :foo do |prev| end }.should_not raise_error
  end
  
  it "should not fail if a generator block doesn't handle a previous value" do
    lambda { @class.generator_for :foo, :first => 'baz' do end }.should_not raise_error(ArgumentError)
  end
  
  it "should not fail if a generator block specifically doesn't handle a previous value" do
    lambda { @class.generator_for :foo, :first => 'baz' do || end }.should_not raise_error(ArgumentError)
  end
  
  it "should fail if a generator block expects more than one argument" do
    lambda { @class.generator_for :foo, :first => 'baz' do |x, y| end }.should raise_error(ArgumentError)
  end
  
  it "should allow an initial value with a block argument" do
    lambda { @class.generator_for :foo, :start => 'baz' do |prev| end }.should_not raise_error
  end
  
  it "should succeed if a generator class is provided" do
    @generator = Class.new
    @generator.stubs(:next)
    lambda { @class.generator_for :foo, :class => @generator }.should_not raise_error
  end
  
  it "should fail if a generator class is specified which doesn't have a next method" do
    @generator = Class.new
    lambda { @class.generator_for :foo, :class => @generator }.should raise_error(ArgumentError)
  end

  it "should succeed if a generator method name is provided" do
    @class.stubs(:method_name)
    lambda { @class.generator_for :foo, :method => :method_name }.should_not raise_error    
  end
  
  it "should not fail if a non-existent generator method name is provided" do
    lambda { @class.generator_for :foo, :method => :fake_method }.should_not raise_error(ArgumentError)
  end
  
  it "should allow an initial value with a method argument" do
    @class.stubs(:method_name)
    lambda { @class.generator_for :foo, :start => 'baz', :method => :method_name }.should_not raise_error
  end
  
  it 'should succeed if a value is provided' do
    lambda { @class.generator_for :foo, 'value' }.should_not raise_error(ArgumentError)
  end
  
  it 'should succeed when given an attr => value hash' do
    lambda { @class.generator_for :foo => 'value' }.should_not raise_error(ArgumentError)
  end
  
  it 'should fail when given an attr => value hash with multiple attrs' do
    lambda { @class.generator_for :foo => 'value', :bar => 'other value' }.should raise_error(ArgumentError)
  end
  
  it "should fail unless a generator block, generator class, generator method, or value is provided" do
    lambda { @class.generator_for 'foo' }.should raise_error(ArgumentError)
  end
end

describe ObjectDaddy, 'recording the registration of a generator method' do
  before(:each) do
    ObjectDaddy::ClassMethods.send(:public, :record_generator_for)
    @class = Class.new(OpenStruct)
    @class.send(:include, ObjectDaddy)
  end
  
  it 'should accept a handle and generator' do
    lambda { @class.record_generator_for('handle', 'generator') }.should_not raise_error(ArgumentError)
  end
  
  it 'should require generator' do
    lambda { @class.record_generator_for('handle') }.should raise_error(ArgumentError)
  end
  
  it 'should require a handle' do
    lambda { @class.record_generator_for }.should raise_error(ArgumentError)
  end
  
  it 'should save the generator' do
    @class.record_generator_for('handle', 'generator')
    @class.generators['handle'][:generator].should == 'generator'
  end
  
  it 'should save the class that specified the generator' do
    @class.record_generator_for('handle', 'generator')
    @class.generators['handle'][:source].should == @class
  end
  
  it 'should fail if the handle has already been recorded' do
    @class.record_generator_for('handle', 'generator')
    lambda { @class.record_generator_for('handle', 'generator 2') }.should raise_error
  end
  
  it 'should not fail if the handle has not already been recorded' do
    lambda { @class.record_generator_for('handle', 'generator') }.should_not raise_error
  end
end

describe ObjectDaddy, 'when registering exemplars' do
  before :each do
    @class = Class.new(OpenStruct)
    @class.send(:include, ObjectDaddy)
    @file_path = File.join(File.dirname(__FILE__), 'tmp')
    @file_name = File.join(@file_path, 'widget_exemplar.rb')
    @class.stubs(:exemplar_path).returns(@file_path)
    @class.stubs(:name).returns('Widget')
  end
  
  describe 'before exemplars have been registered' do
    before :each do
      @class.stubs(:exemplars_generated).returns(false)
    end
    
    it "should look for exemplars for the target class in the standard exemplar path" do
      @class.expects(:exemplar_path).returns(@file_path)
      @class.gather_exemplars
    end
    
    it "should look for an exemplar for the target class, based on the class's name" do
      @class.expects(:name).returns('Widget')
      @class.gather_exemplars
    end
    
    it "should register any generators found in the exemplar for the target class" do 
      # we are using the concrete Widget class here because otherwise it's difficult to have our exemplar file work in our class
      begin
        # a dummy class, useful for testing the actual loading of exemplar files
        Widget = Class.new(OpenStruct) { include ObjectDaddy }
        File.open(@file_name, 'w') {|f| f.puts "class Widget\ngenerator_for :foo\nend\n"}
        Widget.stubs(:exemplar_path).returns(@file_path)
        Widget.expects(:generator_for)
        Widget.gather_exemplars
      ensure
        # clean up test data file
        File.unlink(@file_name) if File.exists?(@file_name)
        Object.send(:remove_const, :Widget)
      end
    end

    it "should read from all paths when exemplar_path returns an array" do
      # we are using the concrete Widget class here because otherwise it's difficult to have our exemplar file work in our class
      begin
        # a dummy class, useful for testing the actual loading of exemplar files
        Widget = Class.new(OpenStruct) { include ObjectDaddy }
        File.open(@file_name, 'w') {|f| f.puts "class Widget\ngenerator_for :foo\nend\n"}
        other_filename = 'widget_exemplar.rb'
        File.open(other_filename, 'w') {|f| f.puts "class Widget\ngenerator_for :foo\nend\n"}
        Widget.stubs(:exemplar_path).returns(['.', @file_path])
        Widget.expects(:generator_for).times(2)
        Widget.gather_exemplars
      ensure
        # clean up test data file
        File.unlink(@file_name) if File.exists?(@file_name)
        File.unlink(other_filename) if File.exists?(other_filename)
        Object.send(:remove_const, :Widget)
      end
    end


    it 'should record that exemplars have been registered' do
      @class.expects(:exemplars_generated=).with(true)
      @class.gather_exemplars
    end
  end
  
  describe 'after exemplars have been registered' do
    before :each do
      @class.stubs(:exemplars_generated).returns(true)
    end
    
    it "should not look for exemplars for the target class in the standard exemplar path" do
      @class.expects(:exemplar_path).never
      @class.gather_exemplars
    end
    
    it "should not look for an exemplar for the target class, based on the class's name" do
      @class.expects(:name).never
      @class.gather_exemplars
    end
    
    it 'should register no generators' do
      # we are using the concrete Widget class here because otherwise it's difficult to have our exemplar file work in our class
      begin
        # a dummy class, useful for testing the actual loading of exemplar files
        Widget = Class.new(OpenStruct) { include ObjectDaddy }
        File.open(@file_name, 'w') {|f| f.puts "class Widget\ngenerator_for :foo\nend\n"}
        Widget.stubs(:exemplar_path).returns(@file_path)
        Widget.stubs(:exemplars_generated).returns(true)
        Widget.expects(:generator_for).never
        Widget.gather_exemplars
      ensure
        # clean up test data file
        File.unlink(@file_name) if File.exists?(@file_name)
        Object.send(:remove_const, :Widget)
      end
    end
    
    it 'should not record that exemplars have been registered' do
      @class.expects(:exemplars_generated=).never
      @class.gather_exemplars
    end
  end
  
  it "should register no generators if no exemplar for the target class is available" do
    @class.expects(:generator_for).never
    @class.gather_exemplars
  end
end

describe ObjectDaddy, "when spawning a class instance" do
  before(:each) do
    @class = Class.new(OpenStruct)
    @class.send(:include, ObjectDaddy)
    @file_path = File.join(File.dirname(__FILE__), 'tmp')
    @file_name = File.join(@file_path, 'widget_exemplar.rb')
    @class.stubs(:exemplar_path).returns(@file_path)
    @class.stubs(:name).returns('Widget')
  end
  
  it "should yield the instance to a block if given" do
    yielded_object = nil
    @class.spawn do |obj|
      yielded_object = obj
    end
    @class.should === yielded_object
  end
  
  it "should register exemplars for the target class" do
    @class.expects(:gather_exemplars)
    @class.spawn
  end
  
  it "should allow attributes to be overridden" do
    @class.spawn(:foo => 'xyzzy').foo.should == 'xyzzy'
  end
  
  it "should use any generators registered with blocks" do
    @class.generator_for :foo do |prev| "foo"; end
    @class.spawn.foo.should == 'foo'
  end
  
  it "should not use a block generator for an attribute that has been overridden" do
    @class.generator_for :foo do |prev| "foo"; end
    @class.spawn(:foo => 'xyzzy').foo.should == 'xyzzy'
  end
  
  it "should use any generators registered with generator method names" do
    @class.stubs(:generator_method).returns('bar')
    @class.generator_for :foo, :method => :generator_method
    @class.spawn.foo.should == 'bar'
  end
  
  it 'should fail if a generator is registered with a non-existent method name' do
    @class.generator_for :foo, :method => :nonexistent_metho
    lambda { @class.spawn.foo }.should raise_error
  end
  
  it "should not use a method generator for an attribute that has been overridden" do
    @class.stubs(:generator_method).returns('bar')
    @class.generator_for :foo, :method => :generator_method
    @class.spawn(:foo => 'xyzzy').foo.should == 'xyzzy'
  end
  
  it "should use any generators registered with generator classes" do
    @generator_class = Class.new do
      def self.next() 'baz' end
    end
    @class.generator_for :foo, :class => @generator_class
    @class.spawn.foo.should == 'baz'
  end

  it "should not use a class generator for an attribute that has been overridden" do
    @generator_class = Class.new do
      def self.next() 'baz' end
    end
    @class.generator_for :foo, :class => @generator_class
    @class.spawn(:foo => 'xyzzy').foo.should == 'xyzzy'
  end
  
  it "should return the initial value first if one was registered for a block generator" do
    @class.generator_for :foo, :start => 'frobnitz' do |prev| "foo"; end
    @class.spawn.foo.should == 'frobnitz'
  end
  
  it "should return the block applied to the initial value on the second call if an initial value was registered for a block generator" do
    @class.generator_for :foo, :start => 'frobnitz' do |prev| prev + 'a'; end
    @class.spawn
    @class.spawn.foo.should == 'frobnitza'
  end
  
  it "should return the block applied to the previous value when repeatedly calling a block generator" do
    @class.generator_for :foo do |prev| prev ? prev.succ : 'test'; end
    @class.spawn
    @class.spawn.foo.should == 'tesu'
  end
  
  it 'should not require a block if an initial value is given' do
    lambda { @class.generator_for :foo, :start => 'crapola' }.should_not raise_error(ArgumentError)
  end
  
  it 'should default the generator to increment the value if an initial value is given' do
    @class.generator_for :foo, :start => 'crapola'
    @class.spawn
    @class.spawn.foo.should == 'crapolb'
  end
  
  it "should return the initial value first if one was registered for a method generator" do
    @class.instance_eval do
      def self.generator_value_method(prev)
        'foo'
      end
    end
    
    @class.generator_for :foo, :start => 'frobnitz', :method => :generator_value_method
    @class.spawn.foo.should == 'frobnitz'
  end
  
  it "should return the method applied to the initial value on the second call if an initial value was registered for a method generator" do
    @class.instance_eval do
      def self.generator_value_method(prev)
        prev.succ
      end
    end
    
    @class.generator_for :foo, :start => 'frobnitz', :method => :generator_value_method
    @class.spawn
    @class.spawn.foo.should == 'frobniua'
  end
  
  it "should return the method applied to the previous value when repeatedly calling a method generator" do
    @class.instance_eval do
      def self.generator_value_method(prev)
        if prev
          prev.succ
        else
          'test'
        end
      end
    end
    
    @class.generator_for :foo, :method => :generator_value_method
    @class.spawn
    @class.spawn.foo.should == 'tesu'
  end
  
  it 'should use the return value for a block generator that takes no argument' do
    x = 5
    @class.generator_for(:foo) { x }
    @class.spawn.foo.should == x
  end
  
  it 'should use the return value for a block generator that explicitly takes no argument' do
    x = 5
    @class.generator_for(:foo) { ||  x }
    @class.spawn.foo.should == x
  end
  
  it 'should use the supplied value for the generated value' do
    x = 5
    @class.generator_for :foo, x
    @class.spawn.foo.should == x
  end
  
  it 'should use the supplied attr => value value for the generated value' do
    x = 5
    @class.generator_for :foo => x
    @class.spawn.foo.should == x
  end
  
  it "should call the normal target class constructor" do
    @class.expects(:new)
    @class.spawn
  end
  
  it 'should not generate a value for an attribute that has been specified as nil' do
    @class.generator_for :foo => 5
    @class.spawn(:foo => nil).foo.should be_nil
  end
  
  it 'should not generate a value for an attribute that has been specified as false' do
    @class.generator_for :foo => 5
    @class.spawn(:foo => false).foo.should be(false)
  end

  describe 'for an abstract parent class' do
    before :each do
      Widget = Class.new(OpenStruct) { include ObjectDaddy }
      SubWidget = Class.new(Widget) {include ObjectDaddy }
      Widget.stubs(:exemplar_path).returns(@file_path)
      SubWidget.stubs(:exemplar_path).returns(File.join(@file_path, 'sub_widget_exemplar.rb'))
    end

    after :each do
      [:Widget, :SubWidget].each { |const|  Object.send(:remove_const, const) }
    end
    
    it 'should generate an instance of a specified concrete subclass (specced using a symbol)' do
      Widget.generates_subclass :SubWidget
      Widget.spawn.should be_instance_of(SubWidget)
    end

    it 'should generate an instance of a specified concrete subclass (specced using a string)' do
      Widget.generates_subclass 'SubWidget'
      Widget.spawn.should be_instance_of(SubWidget)
    end
    
    it 'should generate an instance of a specified concrete subclass and yield to a block if given' do
      yielded_object = nil
      Widget.generates_subclass :SubWidget
      Widget.spawn do |obj|
        yielded_object = obj
      end
      yielded_object.should be_instance_of(SubWidget)
    end

    describe 'using exemplar files' do
      before :each do
        File.open(@file_name, 'w') do |f|
          f.puts "class Widget\ngenerates_subclass 'SubWidget'\nend"
        end
      end

      after :each do
        File.unlink @file_name
      end

      it 'should generate an instance fo the specified concrete subclass' do
        Widget.spawn.should be_instance_of(SubWidget)
      end
    end
  end
  
  describe 'for a subclass' do
    before :each do
      @subclass = Class.new(@class)
      @subclass.send(:include, ObjectDaddy)
      @subfile_path = File.join(File.dirname(__FILE__), 'tmp')
      @subfile_name = File.join(@file_path, 'sub_widget_exemplar.rb')
      @subclass.stubs(:exemplar_path).returns(@file_path)
      @subclass.stubs(:name).returns('SubWidget')
    end
    
    describe 'using generators from files' do
      before :each do
        Widget = Class.new(OpenStruct) { include ObjectDaddy }
        SubWidget = Class.new(Widget)  { include ObjectDaddy }
        
        Widget.stubs(:exemplar_path).returns(@file_path)
        SubWidget.stubs(:exemplar_path).returns(@subfile_path)
        
        File.open(@file_name, 'w') do |f|
          f.puts "class Widget\ngenerator_for :blah do |prev| 'blah'; end\nend\n"
        end
      end
      
      after :each do
        [@file_name, @subfile_name].each { |file|  File.unlink(file) if File.exists?(file) }
        [:Widget, :SubWidget].each { |const|  Object.send(:remove_const, const) }
      end
      
      it 'should use generators from the parent class' do
        SubWidget.spawn.blah.should == 'blah'
      end
      
      it 'should let subclass generators override parent generators' do
        File.open(@subfile_name, 'w') do |f|
          f.puts "class SubWidget\ngenerator_for :blah do |prev| 'blip'; end\nend\n"
        end
        SubWidget.spawn.blah.should == 'blip'
      end
    end

    describe 'using generators called directly' do
      it 'should use generators from the parent class' do
        @class.generator_for :blah do |prev| 'blah'; end
        @subclass.spawn.blah.should == 'blah'
      end
      
      it 'should let subclass generators override parent generators' do
        pending 'figuring out what to do about this, including deciding whether or not this is even important' do
          @class.generator_for :blah do |prev| 'blah'; end
          # p @class
          # p @subclass
          # @subclass.send(:gather_exemplars)
          # p @subclass.generators
          @subclass.generator_for :blah do |prev| 'blip'; end
          # @subclass.send(:gather_exemplars)
          # p @subclass.generators
          # p @subclass.generators[:blah][:generator][:block].call
          # @subclass.send(:gather_exemplars)
          @subclass.spawn.blah.should == 'blip'
        end
      end
    end
  end
end

# conditionally do Rails tests, if we were included as a plugin
if File.exists?("#{File.dirname(__FILE__)}/../../../../config/environment.rb")

  setup_rails_database

  class Foo < ActiveRecord::Base
    has_many :frobnitzes, :class_name => 'Frobnitz'
  end
  
  class Bar < ActiveRecord::Base
  end
  
  class Thing < ActiveRecord::Base
    has_many :frobnitzes, :class_name => 'Frobnitz'
  end

  class Frobnitz < ActiveRecord::Base
    belongs_to :foo
    belongs_to :bar
    belongs_to :thing
    belongs_to :bango, :class_name => 'Blah', :foreign_key => 'bangbang_id'
    belongs_to :blotto, :class_name => 'YaModel', :foreign_key => 'blitblot_id'
    validates_presence_of :foo
    validates_presence_of :thing_id
    validates_presence_of :bangbang_id
    validates_presence_of :blotto
    validates_presence_of :name
    validates_presence_of :title, :on => :create, :message => "can't be blank"
    validates_format_of   :title, :with => /^\d+$/
  end
  
  class SubFrobnitz < Frobnitz
    validates_presence_of :bar
  end
  
  class Blah < ActiveRecord::Base
  end
  
  class YaModel < ActiveRecord::Base
  end

  describe ObjectDaddy, "when integrated with Rails" do
    it "should provide a means of generating and saving a class instance" do
      Frobnitz.should respond_to(:generate)
    end
    
    it "should provide a means of generating and saving a class instance while raising exceptions" do
      Frobnitz.should respond_to(:generate!)
    end
    
    describe "and a block is passed to generate" do
      it "should yield the instance to the block" do
        yielded_object = nil
        YaModel.generate do |obj|
          yielded_object = obj
        end
        YaModel.should === yielded_object
      end

      it "should save the instance before yielding" do
        instance = Frobnitz.new
        YaModel.generate do |obj|
          obj.should_not be_new_record
        end
      end
    end
    
    describe "and a block is passed to generate!" do
      it "should yield the instance to the block" do
        yielded_object = nil
        YaModel.generate! do |obj|
          yielded_object = obj
        end
        YaModel.should === yielded_object
      end

      it "should save the instance before yielding" do
        instance = Frobnitz.new
        YaModel.generate! do |obj|
          obj.should_not be_new_record
        end
      end
    end
    
    describe 'giving an exemplar path for an ActiveRecord model' do
      it 'should check if a spec directory exists' do
        File.expects(:directory?).with(File.join(RAILS_ROOT, 'spec'))
        Frobnitz.exemplar_path
      end
      
      describe 'if a spec directory exists' do
        before :each do
          File.stubs(:directory?).returns(true)
        end
        
        it 'should use the spec directory' do
          Frobnitz.exemplar_path.should == File.join(RAILS_ROOT, 'spec', 'exemplars')
        end
      end
      
      describe 'if a spec directory does not exist' do
        before :each do
          File.stubs(:directory?).returns(false)
        end
        
        it 'should use the test directory' do
          Frobnitz.exemplar_path.should == File.join(RAILS_ROOT, 'test', 'exemplars')
        end
      end
    end
    
    describe 'when an association is required by name' do
      it 'should generate an instance for the association' do
        foo = Foo.create(:name => 'some foo')
        Foo.expects(:generate).returns(foo)
        Frobnitz.spawn
      end
      
      it 'should assign an instance for the association' do
        foo = Foo.create(:name => 'some foo')
        Foo.stubs(:generate).returns(foo)
        Frobnitz.spawn.foo.should == foo
      end
      
      it 'should generate an instance for the association using specified foreign key and class name values' do
        ya_model = YaModel.create(:name => 'ya model')
        YaModel.expects(:generate).returns(ya_model)
        Frobnitz.spawn
      end
      
      it 'should assign an instance for the association using specified foreign key and class name values' do
        ya_model = YaModel.create(:name => 'ya model')
        YaModel.stubs(:generate).returns(ya_model)
        Frobnitz.spawn.blotto.should == ya_model
      end
      
      it 'should use the parent object when generating an instance through a has_many association' do
        foo  = Foo.create(:name => 'some foo')
        frob = foo.frobnitzes.generate
        frob.foo.should == foo
      end
      
      it 'should not generate an instance if the attribute is overridden by nil' do
        Foo.expects(:generate).never
        Frobnitz.spawn(:foo => nil)
      end
      
      it 'should not assign an instance if the attribute is overridden by nil' do
        Frobnitz.spawn(:foo => nil).foo.should be_nil
      end
      
      it 'should not generate an instance if the attribute (*_id) is overridden' do
        foo = Foo.create(:name => 'some foo')
        Foo.expects(:generate).never
        Frobnitz.spawn(:foo_id => foo.id)
      end
      
      it 'should use the given attribute (*_id) instead of assigning a new association object' do
        foo = Foo.create(:name => 'some foo')
        Frobnitz.spawn(:foo_id => foo.id).foo.should == foo
      end
    end
    
    describe 'when an association is required by ID' do
      it 'should generate an instance for the association' do
        thing = Thing.create(:name => 'some thing')
        Thing.expects(:generate).returns(thing)
        Frobnitz.spawn
      end
      
      it 'should assign an instance for the association' do
        thing = Thing.create(:name => 'some thing')
        Thing.stubs(:generate).returns(thing)
        Frobnitz.spawn.thing.should == thing
      end
      
      it 'should generate an instance for the association using specified foreign key and class name values' do
        blah = Blah.create(:bam => 'blah')
        Blah.expects(:generate).returns(blah)
        Frobnitz.spawn
      end
      
      it 'should assign an instance for the association using specified foreign key and class name values' do
        blah = Blah.create(:bam => 'blah')
        Blah.stubs(:generate).returns(blah)
        Frobnitz.spawn.bango.should == blah
      end
      
      it 'should use the parent object when generating an instance through a has_many association' do
        thing = Thing.create(:name => 'some thing')
        frob  = thing.frobnitzes.generate
        frob.thing.should == thing
      end
      
      it 'should not generate an instance if the attribute is overridden by nil' do
        Thing.expects(:generate).never
        Frobnitz.spawn(:thing_id => nil)
      end
      
      it 'should not assign an instance if the attribute is overridden by nil' do
        Frobnitz.spawn(:thing_id => nil).thing.should be_nil
      end
      
      it 'should not generate an instance if the association is overridden' do
        thing = Thing.create(:name => 'some thing')
        Thing.expects(:generate).never
        Frobnitz.spawn(:thing => thing)
      end
      
      it 'should use the given association object instead of assigning a new one' do
        thing = Thing.create(:name => 'some thing')
        Frobnitz.spawn(:thing => thing).thing.should == thing
      end
    end
    
    it 'should handle a belongs_to association required through inheritance' do
      thing = Thing.create(:name => 'some thing')
      Thing.expects(:generate).returns(thing)
      SubFrobnitz.spawn
    end
    
    it 'should include belongs_to associations required by the subclass' do
      bar = Bar.create
      Bar.expects(:generate).returns(bar)
      SubFrobnitz.spawn
    end
    
    it 'should not include belongs_to associations required by the subclass at the parent class level' do
      Bar.expects(:generate).never
      Frobnitz.spawn
    end
    
    it "should not generate instances of belongs_to associations which are not required by a presence_of validator" do
      Bar.expects(:generate).never
      Frobnitz.spawn
    end
    
    it "should not generate any values for attributes that do not have generators" do
      Frobnitz.spawn.name.should be_nil
    end

    it "should use specified values for attributes that do not have generators" do
      Frobnitz.spawn(:name => 'test').name.should == 'test'
    end
    
    it "should use specified values for attributes that would otherwise be generated" do
      Foo.expects(:generate).never
      foo = Foo.new
      Frobnitz.spawn(:foo => foo).foo.should == foo
    end
    
    it 'should pass the supplied validator options to the real validator method' do
      Blah.validates_presence_of :bam, :if => lambda { false }
      Blah.new.should be_valid
    end
    
    it "should ignore optional arguments to presence_of validators" do
      Frobnitz.presence_validated_attributes.should have_key(:title)
    end
    
    it "should return an unsaved record if spawning" do
      Thing.spawn.should be_new_record
    end
    
    it "should return a saved record if generating" do
      Thing.generate.should_not be_new_record
    end
    
    it 'should return a saved record if generating while raising exceptions' do
      Thing.generate!.should_not be_new_record
    end
    
    it "should not fail if trying to generate and save an invalid object" do
      lambda { Frobnitz.generate(:title => 'bob') }.should_not raise_error(ActiveRecord::RecordInvalid)
    end
    
    it "should return an invalid object if trying to generate and save an invalid object" do
      Frobnitz.generate(:title => 'bob').should_not be_valid
    end
    
    it "should fail if trying to generate and save an invalid object while raising acceptions" do
      lambda { Frobnitz.generate!(:title => 'bob') }.should raise_error(ActiveRecord::RecordInvalid)
    end
    
    it "should return a valid object if generate and save succeeds" do
      Frobnitz.generate(:title => '5', :name => 'blah').should be_valid
    end
    
    it 'should allow attributes to be overriden with string keys' do
      Frobnitz.generator_for :name => 'thing'
      Frobnitz.generate('name' => 'boo').name.should == 'boo'
    end
  end
end
