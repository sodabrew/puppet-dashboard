class ReportsController < InheritedResources::Base
  belongs_to :node, :optional => true, :finder => :find_by_url!
  protect_from_forgery :except => :create

  before_filter :handle_raw_post, :only => :create

  private

  def collection
    get_collection_ivar || set_collection_ivar(end_of_association_chain.paginate(:page => params[:page]))
  end

  def handle_raw_post
    report = params[:report]
    return unless report.is_a?(String)
    params[:report] = {:report => report}
  end
end
