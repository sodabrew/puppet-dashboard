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

  describe "#diff" do
    it "should use the baseline of the node associated with the report if baseline_type=self" do
      report = Report.generate!(:host => "foo", :kind => "inspect")
      baseline = Report.generate!(:host => "foo", :time => 1.week.ago, :kind => "inspect")
      baseline.baseline!

      get :diff, :id => report.id, :baseline_type => "self"
      assigns[:baseline_report].should == baseline
    end

    it "should use the baseline of the node specified if baseline_type=other" do
      report = Report.generate!(:host => "foo", :kind => "inspect")
      baseline = Report.generate!(:host => "bar", :kind => "inspect")
      baseline.baseline!

      get :diff, :id => report.id, :baseline_type => "other", :baseline_host => "bar"
      assigns[:baseline_report].should == baseline
    end

    it "should raise an error if baseline_type=self and the current node does not have a baseline" do
      report = Report.generate!(:host => "foo", :kind => "inspect")

      lambda { get :diff, :id => report.id, :baseline_type => "self" }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it "should raise an error if baseline_type=other and the specified node's baseline doesn't exist" do
      report = Report.generate!(:host => "foo", :kind => "inspect")

      lambda { get :diff, :id => report.id, :baseline_type => "other", :baseline_host => "foo" }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#search" do
    it "should render the search form if there are no parameters" do
      get('search')
      response.code.should == '200'
      response.should render_template("reports/search")
      assigns[:matching_files].should == nil
      assigns[:unmatching_files].should == nil
    end

    describe "when searching for files" do
      before do
        @matching_report = Report.create!(:host => "foo", :time => 1.week.ago.to_date, :status => "unchanged", :kind => "inspect")
        @matching_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/hosts", :events_attributes => [{:property => "content", :previous_value => "{md5}ab07acbb1e496801937adfa772424bf7"}])

        @other_matching_report = Report.create!(:host => "bar", :time => 1.week.ago.to_date, :status => "unchanged", :kind => "inspect")
        @other_matching_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/hosts", :events_attributes => [{:property => "content", :previous_value => "{md5}ab07acbb1e496801937adfa772424bf7"}])

        @unmatching_file_report = Report.create!(:host => "baz", :time => 1.week.ago.to_date, :status => "unchanged", :kind => "inspect")
        @unmatching_file_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/sudoers", :events_attributes => [{:property => "content", :previous_value => "{md5}ab07acbb1e496801937adfa772424bf7"}])

        @unmatching_content_report = Report.create!(:host => "banana", :time => 1.week.ago.to_date, :status => "unchanged", :kind => "inspect")
        @unmatching_content_report.resource_statuses.create!(:resource_type => "File", :title => "/etc/hosts", :events_attributes => [{:property => "content", :previous_value => "{md5}aa876288711c4198cfcda790b58d7e95"}])
      end

      describe "when both file title and content are specified" do
        it "should return both matching and unmatching nodes" do
          get('search', :file_title => "/etc/hosts", :file_content => "ab07acbb1e496801937adfa772424bf7")
          assigns[:matching_files].to_a.should =~ @matching_report.resource_statuses + @other_matching_report.resource_statuses
          assigns[:unmatching_files].to_a.should =~ @unmatching_content_report.resource_statuses
        end
      end

      describe "when only file content is specified" do
        it "should not perform a search, and should add an error message" do
          get('search', :file_content => "ab07acbb1e496801937adfa772424bf7")
          assigns[:matching_files].should == nil
          assigns[:unmatching_files].should == nil
          flash[:errors].should include "Please specify the file title to search for"
        end
      end

      describe "when the page first loads" do
        it "should not perform a search, and should not add error messages" do
          get('search')
          assigns[:matching_files].should == nil
          assigns[:unmatching_files].should == nil
          flash[:errors].should be_empty
        end
      end

      describe "when nothing is specified" do
        it "should not perform a search, and should add error messages" do
          get('search', :file_title => "", :file_content => "")
          assigns[:matching_files].should == nil
          assigns[:unmatching_files].should == nil
          flash[:errors].should include "Please specify the file title to search for"
        end
      end
    end
  end

  describe "#baselines" do
    it "should sanitize the parameter given" do
      hostname = %q{da\ng%erous'in_put}
      report = Report.generate!(:host => hostname, :kind => "inspect")
      report.baseline!

      get :baselines, :term => hostname, :limit => 20, :format => :json
      JSON.load(response.body).should == [hostname]
    end

    it "should return prefix matches before substring matches" do
      Report.generate!(:host => "beetle"  , :kind => "inspect").baseline!
      Report.generate!(:host => "egret"   , :kind => "inspect").baseline!
      Report.generate!(:host => "chimera" , :kind => "inspect").baseline!
      Report.generate!(:host => "elephant", :kind => "inspect").baseline!

      get :baselines, :term => 'e', :limit => 20, :format => :json
      JSON.load(response.body).should == ["egret", "elephant", "beetle", "chimera"]
    end

    it "should only return the requested number of matches" do
      Report.generate!(:host => "egret"   , :kind => "inspect").baseline!
      Report.generate!(:host => "chimera" , :kind => "inspect").baseline!
      Report.generate!(:host => "elephant", :kind => "inspect").baseline!
      Report.generate!(:host => "beetle"  , :kind => "inspect").baseline!

      get :baselines, :term => 'e', :limit => 3, :format => :json
      JSON.load(response.body).should == ["egret", "elephant", "beetle"]
    end

    it "should fail if the format is not json" do
      get :baselines, :term => 'anything', :format => :html
      response.should_not be_success
      response.code.should == "406"
    end
  end

  def post_with_body(action, body, headers)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, {}, headers)
    @request.env.delete('RAW_POST_DATA')
    response
  end

end
