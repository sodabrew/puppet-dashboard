class DelayedJobFailuresController < ApplicationController
  def index
    @read = false
    @delayed_job_failures = get_failures(@read)
  end

  def read_all
    DelayedJobFailure.transaction do
      # Can't just update_all, because this is a WillPaginate collection,
      # and it has a limited API.  Alas. --daniel 2011-06-20
      DelayedJobFailure.all.each do |event|
        event.read = true
        event.save!
      end
    end
    @delayed_job_failures = []

    redirect_to "/"
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
        paginate_scope(DelayedJobFailure.where(:read => read).order('created_at DESC'))
      end

      format.all do
        DelayedJobFailure.where(:read => read).order('created_at DESC')
      end
    end
  end
end
