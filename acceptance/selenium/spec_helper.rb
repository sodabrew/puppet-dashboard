require "rubygems"
require "selenium-webdriver"

$DASHBOARD_BASE_URL = "http://localhost:3000/"
$HEADLESS_DISPLAY = nil #"localhost:15.0"

# Choose from :ie, :internet_explorer, :remote, :chrome, :firefox, :ff, :android, :iphone, :opera
$DRIVER = :firefox

$DRIVER_IMPLICIT_WAIT = 10

# Used only when $DRIVER == :remote.
$DRIVER_HUB_URL = "http://192.168.100.228:4444/wd/hub"
$DRIVER_CAPABILITIES = Selenium::WebDriver::Remote::Capabilities.firefox

def get_web_driver()
  if $DRIVER == :remote
    driver = Selenium::WebDriver.for(:remote, :url => $DRIVER_HUB_URL, :desired_capabilities => $DRIVER_CAPABILITIES)
  else
    ENV["DISPLAY"] = $HEADLESS_DISPLAY if $HEADLESS_DISPLAY
    driver = Selenium::WebDriver.for($DRIVER)
  end
  driver.manage.timeouts.implicit_wait = $DRIVER_IMPLICIT_WAIT
  driver.navigate.to $DASHBOARD_BASE_URL
  driver
end
