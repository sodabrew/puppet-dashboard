class ReportsController < InheritedResources::Base
  belongs_to :node, :optional => true, :finder => :find_by_url!
  protect_from_forgery :except => :create

  before_filter :handle_raw_post, :only => :create

  def create
    if params[:report][:report].blank?
      render :status => 406
      return
    end

    create!
  end

  private

  def collection
    get_collection_ivar || set_collection_ivar(
      request.format == :html ? 
        end_of_association_chain.paginate(:page => params[:page]) : 
        end_of_association_chain
    )
  end

  def handle_raw_post
    report = params[:report]
    params[:report] = {}
    case report
    when String
      params[:report][:report] = report
    when nil
      params[:report][:report] = request.raw_post
    when Hash
      params[:report] = report
    end
  end

end
