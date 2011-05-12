require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  describe "#home" do
    before :each do
      SETTINGS.stubs(:no_longer_reporting_cutoff).returns(3600)

      [true, false].each do |hidden|
        prefix = hidden ? 'hidden:' : ''
        Factory(:node,              :hidden => hidden, :name => prefix + 'unreported')
        Factory(:reported_node,     :hidden => hidden, :name => prefix + 'reported')
        Factory(:unresponsive_node, :hidden => hidden, :name => prefix + 'unresponsive')
        Factory(:current_node,      :hidden => hidden, :name => prefix + 'current')
        Factory(:failing_node,      :hidden => hidden, :name => prefix + 'failing')
        Factory(:successful_node,   :hidden => hidden, :name => prefix + 'successful')
        Factory(:pending_node,      :hidden => hidden, :name => prefix + 'pending')
        Factory(:compliant_node,    :hidden => hidden, :name => prefix + 'compliant')
      end
    end

    it "should properly categorize nodes" do
      get :home

      assigns[:currently_failing_nodes].map(&:name).should   =~ %w[ reported unresponsive current failing ]
      assigns[:unreported_nodes].map(&:name).should          =~ %w[ unreported ]
      assigns[:no_longer_reporting_nodes].map(&:name).should =~ %w[ reported unresponsive ]
      assigns[:recently_reported_nodes].map(&:name).should   =~ %w[ reported unresponsive current failing successful pending compliant ]

      assigns[:nodes].map(&:name).should =~ %w[ unreported reported unresponsive current failing successful pending compliant ]

      assigns[:unresponsive_nodes].map(&:name).should =~ %w[ unreported reported unresponsive ]
      assigns[:current_nodes].map(&:name).should      =~ %w[ current failing successful pending compliant ]
      assigns[:failed_nodes].map(&:name).should       =~ %w[ current failing ]
      assigns[:successful_nodes].map(&:name).should   =~ %w[ successful pending compliant ]
      assigns[:pending_nodes].map(&:name).should      =~ %w[ pending ]
      assigns[:compliant_nodes].map(&:name).should    =~ %w[ successful compliant ]
    end
  end
end
