require 'spec_helper'
require 'shared_behaviors/controller_mixins'

describe ReportsController, :type => :controller do
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
    shared_examples_for "correctly formatted POST" do
      it { should_not raise_error }
      it { should change(Report, :count).by(1) }
      it { should change { Node.find_by_name("sample_node") }.from(nil) }
    end

    describe "with a POST from Puppet 2.6.x" do
      subject do
        lambda {
          post :upload, body: @yaml, as: :yaml
          Delayed::Worker.new.work_off
        }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST from Puppet 0.25.x" do
      subject do
        lambda {
          post :upload, params: { report: @yaml }, as: :json
          Delayed::Worker.new.work_off
        }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST with a report inside the report parameter" do
      subject do
        lambda {
          post :upload, params: { report: { report: @yaml } }
          Delayed::Worker.new.work_off
        }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST without a report, the response code" do
      before :each do
        post :upload, params: { report: '' }
      end

      it "should be 200, because we queued the job" do
        response.should be_successful
      end
    end

    describe "with a POST with invalid report data, the response code" do
      before :each do
        post :upload, params: { report: 'foo bar baz bad data invalid' }
      end

      it "should be 200, because we queued the job" do
        response.should be_successful
      end
    end
  end

  describe "#create" do
    it "should fail with a 403 error when disable_legacy_report_upload_url is true" do
      SETTINGS.stubs(:disable_legacy_report_upload_url).returns(true)
      post :create, body: @yaml, as: :yaml
      response.should be_forbidden
    end

    it "should succeed when disable_legacy_report_upload_url is false" do
      SETTINGS.stubs(:disable_legacy_report_upload_url).returns(false)
      post :create, body: @yaml, as: :yaml
      response.should be_successful
    end
  end

  describe "#index" do
    it "should render the index template and show all reports" do
      get :index
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:tab].should == 'all'
      assigns[:reports].should include @failed
      assigns[:reports].should include @pending
      assigns[:reports].should include @changed
      assigns[:reports].should include @unchanged
    end
  end

  describe "#failed" do
    it "should render the index template and show only failed reports" do
      get :index, params: { status: 'failed' }
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:tab].should == 'failed'
      assigns[:reports].should include @failed
      assigns[:reports].should_not include @pending
      assigns[:reports].should_not include @changed
      assigns[:reports].should_not include @unchanged
    end
  end
  describe "#pending" do
    it "should render the index template and show only pending reports" do
      get :index, params: { status: 'pending' }
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:tab].should == 'pending'
      assigns[:reports].should_not include @failed
      assigns[:reports].should include @pending
      assigns[:reports].should_not include @changed
      assigns[:reports].should_not include @unchanged
    end
  end
  describe "#changed" do
    it "should render the index template and show only changed reports" do
      get :index, params: { status: 'changed' }
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:tab].should == 'changed'
      assigns[:reports].should_not include @failed
      assigns[:reports].should_not include @pending
      assigns[:reports].should include @changed
      assigns[:reports].should_not include @unchanged
    end
  end

  describe "#unchanged" do
    it "should render the index template and show only unchanged reports" do
      get :index, params: { status: 'unchanged' }
      response.code.should == '200'
      response.should render_template("reports/index")
      assigns[:tab].should == 'unchanged'
      assigns[:reports].should_not include @failed
      assigns[:reports].should_not include @pending
      assigns[:reports].should_not include @changed
      assigns[:reports].should include @unchanged
    end
  end
end
