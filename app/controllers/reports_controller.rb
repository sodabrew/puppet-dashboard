class ReportsController < InheritedResources::Base
  respond_to :html, :yaml, :json
  belongs_to :node, :optional => true
  protect_from_forgery :except => [:create, :upload]

  before_action :raise_if_enable_read_only_mode, :only => [:new, :edit, :update, :destroy]

  def index
    index! do |format|
      format.html do
        if params[:kind] == "inspect"
          @reports = paginate_scope Report.inspections
          @tab = false
        elsif Node.possible_statuses.include?(params[:status])
          @reports = paginate_scope Report.send(params[:status])
          @tab = params[:status]
        else
          @reports = paginate_scope Report.applies
          @tab = 'all'
        end
      end
    end
  end

  def create
    if SETTINGS.disable_legacy_report_upload_url
      render html: 'Access Denied, this url has been disabled, try /reports/upload', status: 403
    else
      upload
    end
  end

  def upload
    begin
      Report.delay.create_from_yaml(raw_report_from_params)
      render html: 'Report queued for import'
    rescue => e
      error_text = 'ERROR! ReportsController#upload failed:'
      Rails.logger.debug error_text
      Rails.logger.debug e.message
      render html: "#{error_text} #{e.message}", status: 406
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

  def raw_report_from_params
    report = params.require(:report)
    if report.kind_of?(ActionController::Parameters)
      report.require(:report)
    else
      report
    end
  rescue ActionController::ParameterMissing
    request.raw_post
  end

end
