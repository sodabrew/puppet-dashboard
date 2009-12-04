class ReportsController < InheritedResources::Base
  layout 'application'
  protect_from_forgery :except => :create

  before_filter :handle_raw_post, :only => :create

  private

  def handle_raw_post
    report = params[:report]
    return unless report.is_a?(String)
    params[:report] = {:report => report}
  end
end
