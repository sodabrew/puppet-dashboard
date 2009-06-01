# Testing app setup

##########
# Routing
##########

ActionController::Routing::Routes.draw do |map|
  # this tests :resource_path (or :erp), for named routes that map to resources
  map.root :controller => 'forums', :action => 'index', :resource_path => '/forums'
  map.create_forum 'create_forum', :controller => 'forums', :action => 'create', :resource_path => '/forums', :resource_method => :post

  map.namespace :admin do |admin|
    admin.resources :forums do |forum|
      forum.resources :interests
    end
    admin.namespace :superduper do |superduper|
      superduper.resources :forums
    end
  end
  
  map.resource :account do |account|
    account.resources :posts
    account.resource :info do |info|
      info.resources :tags
    end
  end
  
  map.resources :users do |user|
    user.resources :interests
    user.resources :posts, :controller => 'user_posts'
    user.resources :comments, :controller => 'user_comments'
    user.resources :addresses do |address|
      address.resources :tags
    end
  end
  
  map.resources :forums do |forum|
    forum.resource :owner do |owner|
      owner.resources :posts do |post|
        post.resources :tags
      end
    end
    forum.resources :interests
    forum.resources :tags
    forum.resources :posts, :controller => 'forum_posts' do |post|
      post.resources :tags
      post.resources :comments do |comment|
        comment.resources :tags
      end
    end
  end
  
  map.resources :tags
  
  # the following routes are for testing errors
  map.resources :posts, :controller => 'forum_posts'
  map.resources :foos do |foo|
    foo.resources :bars, :controller => 'forum_posts'
  end
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end


##################
# Database schema
##################

ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Schema.define(:version => 0) do
    create_table :users, :force => true do |t|
      t.string :login
    end
    
    create_table :infos, :force => true do |t|
      t.column "user_id", :integer
    end

    create_table :addresses, :force => true do |t|
      t.column "user_id", :integer
    end
    
    create_table :forums, :force => true do |t|
      t.column "owner_id", :integer
    end

    create_table :posts, :force => true do |t|
      t.column "forum_id", :integer
      t.column "user_id", :integer
    end

    create_table :comments, :force => true do |t|
      t.column "post_id", :integer
      t.column "user_id", :integer
    end
    
    create_table :interests, :force => true do |t|
      t.column "interested_in_id", :integer
      t.column "interested_in_type", :string
    end
    
    create_table :tags, :force => true do |t|
      t.column "taggable_id", :integer
      t.column "taggable_type", :string
    end
  end
end


#########
# Models
#########

class Interest < ActiveRecord::Base
  belongs_to :interested_in, :polymorphic => true
end

class Tag < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
end

class User < ActiveRecord::Base
  has_many :posts
  has_many :comments
  has_many :interests, :as => :interested_in
  has_many :addresses
  has_one :info
  
  def to_param
    login
  end
end

class Info < ActiveRecord::Base
  belongs_to :user
  has_many :tags, :as => :taggable
end

class Address < ActiveRecord::Base
  belongs_to :user
  has_many :tags, :as => :taggable
end

class Forum < ActiveRecord::Base
  has_many :posts
  has_many :tags, :as => :taggable
  has_many :interests, :as => :interested_in
  belongs_to :owner, :class_name => "User"
end

class Post < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  has_many :comments
  has_many :tags, :as => :taggable
end

class Comment < ActiveRecord::Base
  validates_presence_of :user, :post
  
  belongs_to :user
  belongs_to :post
  has_many :tags, :as => :taggable
end

##############
# Controllers
##############

class ApplicationController < ActionController::Base
  map_enclosing_resource :account, :class => User, :singleton => true, :find => :current_user

  map_enclosing_resource :user do
    User.find_by_login(params[:user_id])
  end
    
protected
  def current_user
    @current_user
  end
end

module Admin
  class ForumsController < ApplicationController
    resources_controller_for :forums
  end
  
  class InterestsController < ApplicationController
    resources_controller_for :interests
  end
  
  module NotANamespace
    class ForumsController < ApplicationController
      resources_controller_for :forums
    end
  end
  
  module Superduper
    class ForumsController < ApplicationController
      resources_controller_for :forums
    end
  end
end

class AccountsController < ApplicationController
  resources_controller_for :account, :singleton => true, :source => :user, :find => :current_user
end

class InfosController < ApplicationController
  resources_controller_for :info, :singleton => true, :only => [:show, :edit, :update]
end

class TagsController < ApplicationController
  resources_controller_for :tags
end

class UsersController < ApplicationController
  resources_controller_for :users, :except => [:new, :create, :destroy]
  
protected
  def find_resource(id = params[:id])
    resource_service.find_by_login(id)
  end
end

class ForumsController < ApplicationController
  resources_controller_for :forums
end

class OwnersController < ApplicationController
  resources_controller_for :owner, :singleton => true, :class => User, :in => :forum
end

class PostsAbstractController < ApplicationController
  attr_accessor :filter_trace
  
  # for testing filter load order
  before_filter {|controller| controller.filter_trace ||= []; controller.filter_trace << :abstract}
  
  # redefine find_resources
  def find_resources
    resource_service.find :all, :order => 'id DESC'
  end
end

class PostsController < PostsAbstractController
  # for testing filter load order
  before_filter {|controller| controller.filter_trace ||= []; controller.filter_trace << :posts}
  
  # example of providing options to resources_controller_for
  resources_controller_for :posts, :class => Post, :route => 'posts'
  
  def load_enclosing_resources_with_trace(*args)
    self.filter_trace ||= []; self.filter_trace << :load_enclosing
    load_enclosing_resources_without_trace(*args)
  end
  alias_method_chain :load_enclosing_resources, :trace
end

class UserPostsController < PostsController
  # for testing filter load order
  before_filter {|controller| controller.filter_trace ||= []; controller.filter_trace << :user_posts}
  
  # example of providing options to nested in
  nested_in :user, :class => User, :key => 'user_id', :name_prefix => 'user_'
end

class AddressesController < ApplicationController
  resources_controller_for :addresses
end

class ForumPostsController < PostsController
  # for testing filter load order
  before_filter {|controller| controller.filter_trace ||= []; controller.filter_trace << :forum_posts}

  # test override resources_controller_for use
  resources_controller_for :posts
  
  # example of providing a custom finder for the nesting resource
  # also example of :as option, which allows you to assign an alias
  # for an enclosing resource
  nested_in :forum, :as => :other_name_for_forum do
    Forum.find(params[:forum_id])
  end
end

class CommentsController < ApplicationController
  resources_controller_for :comments, :in => [:forum, :post], :load_enclosing => false
end

class InterestsController < ApplicationController
  resources_controller_for :interests
  nested_in :interested_in, :polymorphic => true
  
  # the above two lines are the same as:
  #   resources_controller_for :interests, :in => '?interested_in'
end