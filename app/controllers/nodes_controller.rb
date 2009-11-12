class NodesController < InheritedResources::Base
  respond_to :html, :yaml

  private

  def content_id; :inspector end
  helper_method :content_id
end
