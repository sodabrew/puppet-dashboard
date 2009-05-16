Object Daddy
============
_Version 0.4.1 (April 28, 2009)_

__Authors:__  [Rick Bradley](mailto:blogicx@rickbradley.com), [Yossef Mendelssohn](mailto:ymendel@pobox.com)

__Copyright:__  Copyright (c) 2007, Flawed Logic, OG Consulting, Rick Bradley, Yossef Mendelssohn

__License:__  MIT License.  See MIT-LICENSE file for more details.

Object Daddy is a library (as well as a Ruby on Rails plugin) designed to
assist in automating testing of large collections of objects, especially webs
of ActiveRecord models. It is a descendent of the "Object Mother" pattern for
creating objects for testing, and is related to the concept of an "object
exemplar" or _stereotype_.

**WARNING** This code is very much at an _alpha_ development stage. Usage, APIs,
etc., are all subject to change.

See [http://b.logi.cx/2007/11/26/object-daddy](http://b.logi.cx/2007/11/26/object-daddy) for inspiration, historical drama, and too much reading.

## Installation

Presuming your version of Rails has git plugin installation support:

  script/plugin install git://github.com/flogic/object_daddy.git

Otherwise, you can install object_daddy by hand:

1. Unpack the object_daddy directory into vendor/plugins/ in your rails project.
2. Run the object_daddy/install.rb Ruby script.


## Testing

Install the rspec gem and cd into the object_daddy directory. Type `spec
spec/` and you should see all specs run successfully. If you have autotest
from the ZenTest gem installed you can run autotest in that directory.

## Using Object Daddy


Object Daddy adds a `.generate` method to every ActiveRecord model which can be
called to generate a valid instance object of that model class, for use in
testing:

    it "should have a comment for every forum the user posts to" do
      @user = User.generate
      @post = Post.generate
      @post.comments << Comment.generate
      @user.should have(1).comments
    end

This allows us to generate custom model objects without relying on fixtures,
and without knowing, in our various widespread tests and specs, the details of
creating a User, Post, Comment, etc. Not having to know this information means
the information isn't coded into dozens (or hundreds) of tests, and won't need
to be changed when the User (Post, Comment, ...) model is refactored later.

Object Daddy will identify associated classes that need to be instantiated to
make the main model valid. E.g., given the following models:

    class User < ActiveRecord::Base
      belongs_to :login
      validates_presence_of :login
    end

    class Login < ActiveRecord::Base
      has_one :user
    end

A call to `User.generate` will also make a call to `Login.generate` so that
`User#login` is present, and therefore valid.

If all models were able to be created in a valid form by the default Model.new
call with no knowledge of the model itself, there'd be no need for Object
Daddy. So, when we deal with models which have validity requirements,
requiring fields which have format constraints, we need a means of expressing
how to create those models -- how to satisfy those validity constraints.

Object Daddy provides a `generator_for` method which allows the developer to
specify, for a specific model attribute, how to make a valid value. Note that
`validates_uniqueness_of` can require that, even if we make 100,000 instances
of a model that unique attributes cannot have the same values.

Object Daddy's `generator_for` method can take three main forms corresponding to
the means of finding a value for the associated attribute: a block, a method
call, or using a generator class.

    class User < ActiveRecord::Base
      validates_presence_of :email
      validates_uniqueness_of :email
      validates_format_of :email, 
      :with => /^[-a-z_+0-9.]+@(?:[-a-z_+0-9.]\.)+[a-z]+$/i
      validates_presence_of :username
      validates_format_of :username, :with => /^[a-z0-9_]{4,12}$/i

      generator_for :email, :start => 'test@domain.com' do |prev|
        user, domain = prev.split('@')
        user.succ + '@' + domain
      end

      generator_for :username, :method => :next_user

      generator_for :ssn, :class => SSNGenerator

      def self.next_user
        @last_username ||= 'testuser'
        @last_username.succ
      end
    end

    class SSNGenerator
      def self.next
        @last ||= '000-00-0000'
        @last = ("%09d" % (@last.gsub('-', '').to_i + 1)).sub(/^(\d{3})(\d{2})(\d{4})$/, '\1-\2-\3')
      end
    end

Note that the block method of invocation (as used with _:email_ above) takes an
optional _:start_ argument, to specify the value of that attribute on the first
run. The block will be called thereafter with the previous value of the
attribute and will generate the next attribute value to be used.

A simple default block is provided for any generator with a :start value.

    class User < ActiveRecord::Base
      generator_for :name, :start => 'Joe' do |prev|
        prev.succ
      end
  
      generator_for :name, :start => 'Joe'  # equivalent to the above
    end

The _:method_ form takes a symbol naming a class method in the model class to be
called to generate a new value for the attribute in question. If the method 
takes a single argument, it will act much like the block method of invocation,
being called with the previous value and generating the next.

The _:class_ form calls the .next class method on the named class to generate a
new value for the attribute in question.

The argument (previous value) to the block invocation form can be omitted if
it's going to be ignored, and simple invocation forms are provided for literal
values.

    class User < ActiveRecord::Base
      generator_for(:start_time) { Time.now }
      generator_for :name, 'Joe'
      generator_for :age => 25
    end

The developer would then simply call `User.generate` when testing.

If some attribute values are known (or are being controlled during testing)
then these can simply be passed in to `.generate`:

    @bad_login = Login.generate(:expiry => 1.week.ago)
    @expired_user = User.generate(:login => @bad_login)

A `.generate!` method is also provided. The _generate/generate!_ pair of methods
can be thought of as analogs to create/create!, one merely providing an instance
that may or may not be valid and the other raising an exception if any
problem comes up.

Finally, a `.spawn` method is provided that only gives a new, unsaved object. Note
that this is the only method of the three that is available if you happen to be
using Object Daddy outside of Rails.

## Exemplars

In the examples given above we are using `generator_for` in the bodies of the
models themselves. Given that Object Daddy is primarily geared towards
annotating models with information useful for testing, we anticipate that
`generator_for` should not normally be included inline in models. Rather, we
will provide a place where model classes can be re-opened and `generator_for`
calls (and support methods) can be written without polluting the model files
with Object Daddy information.

Object Daddy, when installed as a Rails plugin, will create
*RAILS_ROOT/spec/exemplars/* as a place to hold __exemplar__ files for Rails model
classes.  (We are seeking perhaps some better terminology)

An __exemplar__ for the User model would then be found in
*RAILS_ROOT/spec/exemplars/user_exemplar.rb* (when you are using a testing tool
which works from *RAILS_ROOT/test*, Object Daddy will create
*RAILS_ROOT/test/exemplars* and look for your exemplars in that directory
instead). Exemplar files are completely optional, and no model need have
exemplar files. The `.generate` method will still exist and be callable, and
`generator_for` can be declared in the model files themselves. If an exemplar
file is available when `.generate` is called on a model, the exemplar file will
be loaded and used. An example *user_exemplar.rb* appears below:

    require 'ssn_generator'

    class User < ActiveRecord::Base
      generator_for :email, :start => 'test@domain.com' do |prev|
        user, domain = prev.split('@')
        user.succ + '@' + domain
      end

      generator_for :username, :method => :next_user

      generator_for :ssn, :class => SSNGenerator

      def self.next_user
        @last_username ||= 'testuser'
        @last_username.succ
      end
    end

## Blocks

The `spawn`, `generate` and `generate!` methods can all accept a block, to which
they'll yield the generated object. This provides a nice scoping mechanism in
your code examples. Consider:

    describe "admin user" do
      it "should be authorized to create company profiles"
        admin_user = User.generate!
        admin_user.activate!
        admin_user.add_role("admin")

        admin_user.should be_authorized(:create, Company)
      end
    end

This could be refactored to:

    describe "admin user" do
      it "should be authorized to create company profiles" do
        admin_user = User.generate! do |user|
          user.activate!
          user.add_role("admin")
        end

        admin_user.should be_authorized(:create, Company)
      end
    end
  
Or:

    describe "admin user" do
      it "should be authorized to create company profiles"
        User.generate! do |user|
          user.activate!
          user.add_role("admin")
        end.should be_authorized(:create, Company)
      end
    end

Or even:

    describe "admin user" do
      def admin_user
        @admin_user ||= User.generate! do |user|
          user.activate!
          user.add_role("admin")
        end
      end

      it "should be authorized to create company profiles"
        admin_user.should be_authorized(:create, Company)
      end
    end

This last refactoring allows you to reuse the admin_user method across
multiple code examples, balancing DRY with local data.

## Object Daddy and Fixtures

While Object Daddy is meant to obviate the hellish devilspawn that are test
fixtures, Object Daddy should work alongside fixtures just fine. To each his
own, I suppose.

## Known Issues

The simple invocation forms for `generator_for` when using literal values do not 
work if the literal value is a Hash. Don't do that.

    class User < ActiveRecord::Base
      generator_for :thing_hash, { 'some key' => 'some value' }
      generator_for :other_hash => { 'other key' => 'other value' }
    end

I'm not sure why this would even ever come up, but seriously, don't.

Required `belongs_to` associations are automatically generated when generating an instance,
but only if necessary.

    class Category < ActiveRecord::Base
      has_many :items
    end

    class Item < ActiveRecord::Base
      belongs_to :category
      validates_presence_of :category
    end

`Item.generate` will generate a new category, but `some_category.items.generate` will not.
Unless, of course, you are foolish enough to define a generator in the exemplar.

    class Item
      generator_for(:category) { Category.generate }
    end

Once again, don't do that.

## Rails _surprises_

Due to the way Rails handles associations, cascading generations (as a result of
required associations) are always generated-and-saved, even if the original generation
call was a mere `spawn` (`new`). This may come as a surprise, but it would probably be more
of a surprise if `User.spawn.save` and `User.generate` weren't comparable.
