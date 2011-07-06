class DelayedJobFailuresController < ApplicationController
  def index
    @read = false
    @delayed_job_failures = get_failures(@read)

    if params.has_key? :mark_all_read then
      DelayedJobFailure.transaction do
        # Can't just update_all, because this is a WillPaginate collection,
        # and it has a limited API.  Alas. --daniel 2011-06-20
        DelayedJobFailure.all.each do |event|
          event.read = true
          event.save!
        end
      end
      @delayed_job_failures = []
    end
  end

  def read
    @read = true
    @delayed_job_failures = get_failures(true)
    render 'delayed_job_failures/index'
  end

  protected
  def get_failures(read)
    respond_to do |format|
      format.html do
        paginate_scope(DelayedJobFailure.all(:order => 'created_at DESC',
                                             :conditions => { :read => read }))
      end

      format.all do
        DelayedJobFailure.all(:order => 'created_at DESC',
                              :conditions => { :read => read })
      end
    end
  end
end
