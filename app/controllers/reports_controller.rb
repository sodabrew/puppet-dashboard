class ReportsController < InheritedResources::Base
  belongs_to :node, :optional => true, :finder => :find_by_url!
  protect_from_forgery :except => [:create, :upload]

  before_filter :handle_raw_post, :only => [:create, :upload]

  def create
    if SETTINGS.disable_legacy_report_upload_url
      render :text => "Access Denied, this url has been disabled, try /reports/upload", :status => 403
    else
      upload
    end
  end

  def upload
    if params[:report][:report].blank?
      render :status => 406
      return
    end

    begin
      report = Report.create_from_yaml(params[:report][:report])
      unless report.valid?
        Rails.logger.debug "WARNING! ReportsController#create failed:"
        report.errors.full_messages.each { |msg| Rails.logger.debug msg }
        render :status => 406
      end
    rescue ArgumentError => e
      Rails.logger.debug "WARNING! ReportsController#create failed:"
      Rails.logger.debug e.message
      render :status => 406
    end
  end

  def diff
    @my_report = Report.find(params[:id])
    @baseline_report = Report.find(params[:baseline_id])
    @diff = @baseline_report.diff(@my_report)
  end

  def diff_summary
    diff
    @resources = {}
    @baseline_report.resources.each do |resource|
      if @diff[resource]
        @resources[resource] = :failed
      else
        @resources[resource] = :pass
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
