require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'shared_behaviors/controller_mixins'

describe ReportsController do
  before :each do
    @yaml = File.read(Rails.root.join('spec', 'fixtures', 'sample_report.yml'))
    @failed = Report.create!(:host => "failed", :time => 1.week.ago.to_date, :status => "failed", :kind => "apply")
    @unchanged = Report.create!(:host => "unchanged", :time => 1.week.ago.to_date, :status => "unchanged", :kind => "apply")
    @pending = Report.create!(:host => "pending", :time => 1.week.ago.to_date, :status => "pending", :kind => "apply")
    @changed = Report.create!(:host => "changed", :time => 1.week.ago.to_date, :status => "changed", :kind => "apply")
  end

  def model; Report end

  it_should_behave_like "without JSON pagination"

  describe "#upload" do
    describe "correctly formatted POST", :shared => true do
      it { should_not raise_error }
      it { should change(Report, :count).by(1) }
      it { should change { Node.find_by_name("sample_node") }.from(nil) }
    end

    describe "with a POST from Puppet 2.6.x" do
      subject do
        lambda {
          post_with_body('upload', @yaml, :content_type => 'application/x-yaml')
          Delayed::Worker.new.work_off
        }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST from Puppet 0.25.x" do
      subject do
        lambda {
          post('upload', :report => @yaml)
          Delayed::Worker.new.work_off
        }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST with a report inside the report parameter" do
      subject do
        lambda {
          post('upload', :report => { :report => @yaml })
          Delayed::Worker.new.work_off
        }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST without a report, the response code" do
      before :each do
        post('upload', :report => "" )
      end

      it "should be 200, because we queued the job" do
        response.code.should == '200'
      end
    end

    describe "with a POST with invalid report data, the response code" do
      before :each do
        post('upload', :report => "foo bar baz bad data invalid")
      end

      it "should be 200, because we queued the job" do
        response.code.should == '200'
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

  describe "#index" do
    it "should render the index template and show all reports" do
      get('index')
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:controller_action].should == 'all'
      assigns[:reports].should include @failed
      assigns[:reports].should include @pending
      assigns[:reports].should include @changed
      assigns[:reports].should include @unchanged
    end
  end

  describe "#all" do
    it "should render the index template and show all reports" do
      get('all')
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:controller_action].should == 'all'
      assigns[:reports].should include @failed
      assigns[:reports].should include @pending
      assigns[:reports].should include @changed
      assigns[:reports].should include @unchanged
    end
  end

  describe "#failed" do
    it "should render the index template and show only failed reports" do
      get('failed')
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:controller_action].should == 'failed'
      assigns[:reports].should include @failed
      assigns[:reports].should_not include @pending
      assigns[:reports].should_not include @changed
      assigns[:reports].should_not include @unchanged
    end
  end
  describe "#pending" do
    it "should render the index template and show only pending reports" do
      get('pending')
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:controller_action].should == 'pending'
      assigns[:reports].should_not include @failed
      assigns[:reports].should include @pending
      assigns[:reports].should_not include @changed
      assigns[:reports].should_not include @unchanged
    end
  end
  describe "#changed" do
    it "should render the index template and show only changed reports" do
      get('changed')
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:controller_action].should == 'changed'
      assigns[:reports].should_not include @failed
      assigns[:reports].should_not include @pending
      assigns[:reports].should include @changed
      assigns[:reports].should_not include @unchanged
    end
  end

  describe "#unchanged" do
    it "should render the index template and show only unchanged reports" do
      get('unchanged')
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:controller_action].should == 'unchanged'
      assigns[:reports].should_not include @failed
      assigns[:reports].should_not include @pending
      assigns[:reports].should_not include @changed
      assigns[:reports].should include @unchanged
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
          subject.errors.should include "Please specify the file title to search for"
        end
      end

      describe "when the page first loads" do
        it "should not perform a search, and should not add error messages" do
          get('search')
          assigns[:matching_files].should == nil
          assigns[:unmatching_files].should == nil
          subject.errors.should be_empty
        end
      end

      describe "when nothing is specified" do
        it "should not perform a search, and should add error messages" do
          get('search', :file_title => "", :file_content => "")
          assigns[:matching_files].should == nil
          assigns[:unmatching_files].should == nil
          subject.errors.should include "Please specify the file title to search for"
        end
      end
    end
  end

  def post_with_body(action, body, headers)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, {}, headers)
    @request.env.delete('RAW_POST_DATA')
    response
  end
end
