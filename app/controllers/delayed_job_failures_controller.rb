class DelayedJobFailuresController < ApplicationController
  def index
    respond_to do |format|
      format.html do
        @delayed_job_failures = paginate_scope(DelayedJobFailure.all(:order => 'created_at DESC'))
      end

      format.all do
        @delayed_job_failures = DelayedJobFailure.all(:order => 'created_at DESC')
      end
    end

    if params.has_key? :mark_all_read then
      DelayedJobFailure.transaction do
        # Can't just update_all, because this is a WillPaginate collection,
        # and it has a limited API.  Alas. --daniel 2011-06-20
        @delayed_job_failures.each do |event|
          event.read = true
          event.save!
        end
      end
    end
  end
end
