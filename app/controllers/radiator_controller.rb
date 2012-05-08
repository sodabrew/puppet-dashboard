class RadiatorController < InheritedResources::Base
  def index
    render :partial => "shared/node_summary", :layout => "radiator"
  end
end
