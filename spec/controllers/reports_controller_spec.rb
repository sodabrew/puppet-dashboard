require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'shared_behaviors/controller_mixins'

describe ReportsController do
  def model; Report end

  it_should_behave_like "without JSON pagination"

  describe "creating a report" do
    before :each do
      @yaml = File.read(Rails.root.join('spec', 'fixtures', 'sample_report.yml'))
    end

    describe "correctly formatted POST", :shared => true do
      it { should_not raise_error }
      it { should change(Report, :count).by(1) }
      it { should change{ Node.find_by_name("sample_node")}.from(nil) }
    end

    describe "with a POST from Puppet 2.6.x" do
      subject do
        lambda { post_with_body(:create, @yaml, :content_type => 'application/x-yaml') }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST from Puppet 0.25.x" do
      subject do
        lambda { post(:create, :report => @yaml) }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST with a report inside the report parameter" do
      subject do
        lambda { post(:create, :report => { :report => @yaml }) }
      end

      it_should_behave_like "correctly formatted POST"
    end

    describe "with a POST without a report, the response code" do
      before :each do
        post(:create, :report => "" )
      end

      subject { response.code }

      it { should == "406" }
    end

    describe "with a POST with invalid report data, the response code" do
      before :each do
        post(:create, :report => "foo bar baz bad data invalid")
      end

      subject { response.code }

      it { should == "406" }
    end
  end

 def post_with_body(action, body, headers)
    @request.env['RAW_POST_DATA'] = body
    response = post(action, {}, headers)
    @request.env.delete('RAW_POST_DATA')
    response
  end

end
