require "./acceptance/selenium/spec_helper.rb"

describe "the Dashboard Reports tab" do
  let(:browser) { get_web_driver }
  let(:menu) { browser.find_element(:css => "div#header ul.navigation") }

  after :all do
    browser.quit
  end

  describe 'reports menu item' do
    it 'should exist' do
      reports_link = browser.find_element(:link => "Reports")
      reports_link.should be_displayed
    end
  end

  describe 'reports table' do
    it 'should allow status icons to be displayed with a graphical tooltip' do
      reports_link = browser.find_element(:link => "Reports")
      browser.action.click(reports_link).perform
      browser.find_element(:css => "table.inspector.main").should be_true
    end
  end

end
