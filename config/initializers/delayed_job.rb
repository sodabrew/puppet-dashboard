DELAYED_JOB_PID_PATH = "#{Rails.root}/tmp/pids/delayed_job.pid"

Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 3

def start_delayed_job
  Thread.new do
    `#{Rails.root}/script/delayed_job -p dashboard -m start`
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

if !File.exist?(DELAYED_JOB_PID_PATH) && process_is_dead?
  start_delayed_job
end
