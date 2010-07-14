require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/reports/index.html.haml" do
  describe "the response"  do
    before(:each) do
      assigns[:reports] = [ Report.generate ].paginate
      render
    end

    subject { response }

    it { should be_a_success }
  end

  describe "the response with a report lacking metrics" do

    before do
      report = Report.generate
      report.stubs(:metrics).returns(nil)
      assigns[:reports] = [ report ].paginate
      render
    end

    subject { response }

    it { should be_a_success }
  end
end
