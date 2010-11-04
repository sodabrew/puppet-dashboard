class ReportsController < InheritedResources::Base
  belongs_to :node, :optional => true, :finder => :find_by_url!
  protect_from_forgery :except => :create

  before_filter :handle_raw_post, :only => :create

  def create
    if params[:report][:report].blank?
      render :status => 406
      return
    end

    create! do |success,failure|
      failure.html do
        Rails.logger.debug "WARNING! ReportsController#create failed:"
        @report.errors.full_messages.each { |msg| Rails.logger.debug msg }
        render :status => 406
      end
    end
  end

  private

  def collection
    get_collection_ivar || set_collection_ivar(
      request.format == :html ? 
        paginate_scope(end_of_association_chain) : 
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
