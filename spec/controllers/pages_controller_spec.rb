require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  describe "#home" do
    before :each do
      SETTINGS.stubs(:no_longer_reporting_cutoff).returns(3600)

      [true, false].each do |hidden|
        prefix = hidden ? 'hidden:' : ''
        Factory(:node, :hidden => hidden, :name => prefix + 'unreported')
        [:reported, :unresponsive, :responsive, :failing, :pending, :changed, :unchanged].each do |node_status|
          Factory("#{node_status}_node".to_sym, :hidden => hidden, :name => prefix + node_status.to_s)
        end
      end
    end

    it "should properly categorize nodes" do
      get :home

      assigns[:currently_failing_nodes].map(&:name).should   =~ %w[ reported unresponsive responsive failing ]
      assigns[:unreported_nodes].map(&:name).should          =~ %w[ unreported ]
      assigns[:no_longer_reporting_nodes].map(&:name).should =~ %w[ reported unresponsive ]
      assigns[:recently_reported_nodes].map(&:name).should   =~ %w[ reported unresponsive responsive failing changed pending unchanged ]

      assigns[:nodes].map(&:name).should =~ %w[ unreported reported unresponsive responsive failing changed pending unchanged ]

      assigns[:unresponsive_nodes].map(&:name).should =~ %w[ unreported reported unresponsive ]
      assigns[:failed_nodes].map(&:name).should       =~ %w[ responsive failing ]
      assigns[:pending_nodes].map(&:name).should      =~ %w[ pending ]
      assigns[:changed_nodes].map(&:name).should      =~ %w[ changed ]
      assigns[:unchanged_nodes].map(&:name).should    =~ %w[ unchanged ]
    end
  end
end
