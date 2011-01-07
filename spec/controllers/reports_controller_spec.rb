require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'shared_behaviors/controller_mixins'

describe ReportsController do
  before :each do
    @yaml = File.read(Rails.root.join('spec', 'fixtures', 'sample_report.yml'))
  end

  def model; Report end

  it_should_behave_like "without JSON pagination"

  describe "#upload" do
    describe "correctly formatted POST", :shared => true do
      it { should_not raise_error }
      it { should change(Report, :count).by(1) }
      it { should change{ Node.find_by_name("sample_node")}.from(nil) }
    end

    describe "with a POST from Puppet 2.6.x" do
      subject do
        lambda { post_with_body('upload', @yaml, :content_type => 'application/x-yaml') }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST from Puppet 0.25.x" do
      subject do
        lambda { post('upload', :report => @yaml) }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST with a report inside the report parameter" do
      subject do
        lambda { post('upload', :report => { :report => @yaml }) }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST without a report, the response code" do
      before :each do
        post('upload', :report => "" )
      end

      it "should return a 406 response and the error text" do
        response.code.should == '406'
        response.body.should == "ERROR! ReportsController#upload failed: The supplied report is in invalid format 'FalseClass', expected 'Puppet::Transaction::Report'"
      end
    end

    describe "with a POST with invalid report data, the response code" do
      before :each do
        post('upload', :report => "foo bar baz bad data invalid")
      end

      it "should return a 406 response and the error text" do
        response.code.should == '406'
        response.body.should == "ERROR! ReportsController#upload failed: The supplied report is in invalid format 'String', expected 'Puppet::Transaction::Report'"
      end
    end
  end

  describe "#create" do
    it "should fail with a 403 error when disable_legacy_report_upload_url is true" do
      SETTINGS.stubs(:disable_legacy_report_upload_url).returns(true)
      response = post_with_body('create', @yaml, :content_type => 'application/x-yaml')
      response.status.should == "403 Forbidden"
    end

    it "should succeed when disable_legacy_report_upload_url is false" do
      SETTINGS.stubs(:disable_legacy_report_upload_url).returns(false)
      response = post_with_body('create', @yaml, :content_type => 'application/x-yaml')
      response.status.should == "200 OK"
    end
  end

 def post_with_body(action, body, headers)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, {}, headers)
    @request.env.delete('RAW_POST_DATA')
    response
  end

end
