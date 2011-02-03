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
      PuppetHttps.expects(:get).with("https://filebucket:1337/production/file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c?diff_with=40bb25658a72f731a6f71ef9476cd5af", 's').returns("This is the diff")

      get :diff, @options

      response.should be_success
      response.body.should == "This is the diff"
    end

    it "Doesn't attempt to do a diff if use_file_bucket_diffs is turned off" do
      SETTINGS.stubs(:use_file_bucket_diffs).returns(false)
      PuppetHttps.expects(:get).never

      get :diff, @options

      response.should_not be_success
    end

    [:file1, :file2].each do |which_parameter|
      it "Rejects an invalid md5 for #{which_parameter}" do
        @options[which_parameter] = 'Turkmenistan'

        get :diff, @options

        response.should_not be_success
      end
    end
  end

  describe "#show" do
    before :each do
      @options = {:file => '24d27c169c2c881eb09a065116f2aa5c'}
    end

    it "Forwards the request to the file bucket server" do
      PuppetHttps.expects(:get).with("https://filebucket:1337/production/file_bucket_file/md5/24d27c169c2c881eb09a065116f2aa5c", 's').returns("This is the contents")

      get :show, @options

      response.should be_success
      response.body.should == "This is the contents"
    end

    it "Doesn't attempt to do a diff if use_file_bucket_diffs is turned off" do
      SETTINGS.stubs(:use_file_bucket_diffs).returns(false)
      PuppetHttps.expects(:get).never

      get :show, @options

      response.should_not be_success
    end

    it "Rejects an invalid md5 for :file" do
      @options[:file] = 'Turkmenistan'

      get :diff, @options

      response.should_not be_success
    end
  end
end
