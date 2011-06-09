require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PagesController do
  describe "#home" do
    before :each do
      SETTINGS.stubs(:no_longer_reporting_cutoff).returns(3600)

      [true, false].each do |hidden|
        prefix = hidden ? 'hidden:' : ''
        Factory(:node, :hidden => hidden, :name => prefix + 'unreported')
        [:unresponsive, :responsive, :failing, :pending, :changed, :unchanged].each do |node_status|
          Factory("#{node_status}_node".to_sym, :hidden => hidden, :name => prefix + node_status.to_s)
        end
      end
    end

    it "should properly categorize nodes" do
      get :home
      assigns[:all_nodes].map(&:name).should =~ %w[ unreported unresponsive responsive failing changed pending unchanged ]

      assigns[:unreported_nodes].map(&:name).should   =~ %w[ unreported ]
      assigns[:unresponsive_nodes].map(&:name).should =~ %w[ unresponsive ]
      assigns[:failed_nodes].map(&:name).should       =~ %w[ responsive failing ]
      assigns[:pending_nodes].map(&:name).should      =~ %w[ pending ]
      assigns[:changed_nodes].map(&:name).should      =~ %w[ changed ]
      assigns[:unchanged_nodes].map(&:name).should    =~ %w[ unchanged ]
    end
  end
end
