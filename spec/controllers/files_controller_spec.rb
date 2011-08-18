require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe FilesController do
  before :each do
    SETTINGS.stubs(:use_file_bucket_diffs).returns(true)
    SETTINGS.stubs(:file_bucket_server).returns('filebucket')
    SETTINGS.stubs(:file_bucket_port).returns(1337)
  end

  describe "#diff" do
    before :each do
      @options = {:file1 => '24d27c169c2c881eb09a065116f2aa5c', :file2 => '40bb25658a72f731a6f71ef9476cd5af'}
    end

    it "Forwards the request to the file bucket server" do
      PuppetHttps.expects(:get).
        with("https://filebucket:1337/production/file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c?diff_with=40bb25658a72f731a6f71ef9476cd5af", 's').
        returns("This is the diff")

      get :diff, @options

      response.should be_success
      response.body.should == "This is the diff"
    end

    it "Doesn't attempt to do a diff if use_file_bucket_diffs is turned off" do
      SETTINGS.stubs(:use_file_bucket_diffs).returns(false)
      PuppetHttps.expects(:get).never

      get :diff, @options

      response.should_not be_success
      response.status.should == '403 Forbidden'
      response.body.should == 'File bucket diffs have been disabled'
    end

    [:file1, :file2].each do |which_parameter|
      it "Rejects an invalid md5 for #{which_parameter}" do
        @options[which_parameter] = 'Turkmenistan'

        get :diff, @options

        response.should_not be_success
        response.status.should == '400 Bad Request'
        response.body.should == 'Invalid md5: "Turkmenistan"'
      end
    end
  end

  describe "#show" do
    before :each do
      @options = {:file => '24d27c169c2c881eb09a065116f2aa5c'}
      @url = "https://filebucket:1337/production/file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c"
    end

    it "Forwards the request to the file bucket server" do
      PuppetHttps.expects(:get).
        with("https://filebucket:1337/production/file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c", 's').
        returns("This is the contents")

      get :show, @options

      response.should be_success
      response.body.should == "This is the contents"
    end

    it "Doesn't attempt to do a diff if use_file_bucket_diffs is turned off" do
      SETTINGS.stubs(:use_file_bucket_diffs).returns(false)
      PuppetHttps.expects(:get).never

      get :show, @options

      response.should_not be_success
      response.status.should == '403 Forbidden'
      response.body.should == 'File bucket diffs have been disabled'
    end

    it "Rejects an invalid md5 for :file" do
      @options[:file] = 'Turkmenistan'

      get :show, @options

      response.should_not be_success
      response.status.should == '400 Bad Request'
      response.body.should == 'Invalid md5: "Turkmenistan"'
    end

    it 'gracefully handles Net::HTTPServerExceptions related to cert problems' do
      PuppetHttps.expects(:get).
        with(@url, 's').
        raises(
          Net::HTTPServerException.new('Forbidden request: localhost(127.0.0.1) access to /file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c [find] at line 0',
            Net::HTTPForbidden.new('foo','403','baz')
          )
        )

      get :show, @options

      response.should_not be_success
      response.status.should == '403'
      response.body.should have_tag(
        "p",
        "Connection not authorized: Forbidden request: localhost(127.0.0.1) " +
        "access to /file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c [find] at line 0"
      )
    end

    it 'gracefully handles Net::HTTPServerExceptions related to filebucket content' do
      PuppetHttps.expects(:get).
        with(@url, 's').
        raises(
          Net::HTTPServerException.new('Could not find file_bucket_file md5/24d27c169c2c881eb09a065116f2aa5c',
            Net::HTTPNotFound.new('foo','404','baz')
          )
        )

      get :show, @options

      response.should_not be_success
      response.status.should == '404'
      response.body.should have_tag(
        "p",
        "File contents not available: Could not find file_bucket_file md5/24d27c169c2c881eb09a065116f2aa5c"
      )
    end

    it 'gracefully handles Errno::ECONNREFUSED when the puppet master is not running' do
      PuppetHttps.expects(:get).
        with(@url, 's').
        raises(Errno::ECONNREFUSED, "your server isn't running, so you don't need to catch it, yo.")

      get :show, @options

      response.should_not be_success
      response.status.should == '500 Internal Server Error'
      response.body.should have_tag(
        "p",
        "Could not connect to your filebucket server at filebucket:1337"
      )
    end

    it 'gracefully handles Exceptions, returning a 500 status code' do
      PuppetHttps.expects(:get).
        with(@url, 's').
        raises(ArgumentError, 'oops')

      get :show, @options

      response.should_not be_success
      response.status.should == '500 Internal Server Error'
      response.body.should == 'oops'
    end
  end
end
