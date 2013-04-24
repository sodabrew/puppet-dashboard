class RadiatorController < InheritedResources::Base
  respond_to :html, :json

  def index
    @node_summary = { 'display' => [] }

    # Get the primary statuses in one query
    @node_summary.merge!(Node.count_by_status)

    # Continue the loop to pick up other radiator statuses
    Node.radiator_statuses.each do |status|
      case status
      when 'all'
        @node_summary['display'] << { 'key' => 'all', 'name' => 'Total' }
        @node_summary[status] = Node.unhidden.count
      else
        @node_summary['display'] << { 'key' => status, 'name' => status.capitalize }
        @node_summary[status] = @node_summary[status] || Node.send(status).unhidden.count
      end
    end

    respond_to do |format|
      format.html { render :partial => 'shared/node_summary', :layout => 'radiator' }
      format.json { render :json => @node_summary }
    end
  end
end
