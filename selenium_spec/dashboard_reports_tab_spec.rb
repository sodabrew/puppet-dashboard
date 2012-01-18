require "./selenium_spec/spec_helper.rb"

describe "the Dashboard Reports tab" do

  before :all do 
    @driver = get_driver
    @menu = @driver.find_element(:css => "div#header ul.navigation")
  end

  after :all do
    @driver.quit
  end

  describe 'reports menu item' do
    it 'should exist' do
      reports_link = @driver.find_element(:link => "Reports")
      reports_link.displayed?.should be_true
    end
  end

  describe 'reports table' do
    it 'should allow status icons to be displayed with a graphical tooltip' do
      reports_link = @driver.find_element(:link => "Reports")
      @driver.action.click(reports_link).perform
      @driver.find_element(:css => "table.inspector.main").should be_true
    end
  end

end
