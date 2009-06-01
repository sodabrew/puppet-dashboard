require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '../app'))

describe "#route_enclosing_names TagsController for named_route:" do
  before do
    @routes = ActionController::Routing::Routes.named_routes
    @controller = TagsController.new
  end
  
  it ':tags should be []' do
    @controller.stub!(:recognized_route).and_return(@routes[:tags])
    @controller.send(:route_enclosing_names).should == []
  end

  it ':new_tag should be []' do
    @controller.stub!(:recognized_route).and_return(@routes[:new_tag])
    @controller.send(:route_enclosing_names).should == []
  end

  it ':edit_tag should be []' do
    @controller.stub!(:recognized_route).and_return(@routes[:edit_tag])
    @controller.send(:route_enclosing_names).should == []
  end

  it ':tag should be []' do
    @controller.stub!(:recognized_route).and_return(@routes[:tag])
    @controller.send(:route_enclosing_names).should == []
  end

  it ':forum_tags should be [["forums", false]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:forum_tags])
    @controller.send(:route_enclosing_names).should == [["forums", false]]
  end

  it ':forum_tag should be [["forums", false]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:forum_tag])
    @controller.send(:route_enclosing_names).should == [["forums", false]]
  end
  
  it ':user_addresses_tags should be [["users", false], ["addresses", false]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:user_address_tags])
    @controller.send(:route_enclosing_names).should == [["users", false], ["addresses", false]]
  end

  it ':account_info_tags should be [["account", true], ["info", true]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:account_info_tags])
    @controller.send(:route_enclosing_names).should == [["account", true], ["info", true]]
  end
  
  it ':new_account_info_tag should be [["account", true], ["info", true]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:new_account_info_tag])
    @controller.send(:route_enclosing_names).should == [["account", true], ["info", true]]
  end
end

describe "#route_enclosing_names Admin::ForumsController for named_route:" do
  before do
    @routes = ActionController::Routing::Routes.named_routes
    @controller = Admin::ForumsController.new
  end

  it ':admin_forums should be [[]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:admin_forums])
    @controller.send(:route_enclosing_names).should == []
  end
end

describe "#route_enclosing_names Admin::InterestsController for named_route:" do
  before do
    @routes = ActionController::Routing::Routes.named_routes
    @controller = Admin::InterestsController.new
  end

  it ':admin_forum_interests should be [["forums", false]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:admin_forum_interests])
    @controller.send(:route_enclosing_names).should == [["forums", false]]
  end
  
  it ':forums_interests should be ["forums", false]]' do
    @controller.stub!(:recognized_route).and_return(@routes[:forum_interests])
    @controller.send(:route_enclosing_names).should == [["forums", false]]
  end
end

describe "#route_enclosing_names Admin::Superduper::ForumsController for named_route:" do
  before do
    @routes = ActionController::Routing::Routes.named_routes
    @controller = Admin::Superduper::ForumsController.new
  end

  it ':admin_superduper_forums should be []' do
    @controller.stub!(:recognized_route).and_return(@routes[:admin_superduper_forums])
    @controller.send(:route_enclosing_names).should == []
  end
end