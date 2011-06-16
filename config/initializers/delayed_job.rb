DELAYED_JOB_PID_PATH = Pathname.new "#{Rails.root}/tmp/pids/delayed_job_#{Rails.env}"
DELAYED_JOB_PID_PATH.mkpath

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3

def start_delayed_job
  Thread.new do
    `#{Rails.root}/script/delayed_job --pid-dir=#{DELAYED_JOB_PID_PATH} -p dashboard -n #{SETTINGS.delayed_job_workers || 2} -m start`
  end
end

def process_is_dead?
  begin
    pid = File.read(DELAYED_JOB_PID_PATH).strip
    Process.kill(0, pid.to_i)
    false
  rescue
    true
  end
end

unless Rails.env == 'test'
  if !File.exist?(DELAYED_JOB_PID_PATH + 'delayed_job.pid') && process_is_dead?
    start_delayed_job
  end
end
