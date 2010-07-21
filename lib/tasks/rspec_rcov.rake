namespace :spec do
  namespace :rcov do
    if defined?(Spec::Rake::SpecTask)
      desc 'Run all specs and save the code coverage data'
      Spec::Rake::SpecTask.new(:save) do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList['spec/**/*/*_spec.rb']
        t.rcov = true
        t.rcov_opts = lambda do
          IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten + ['--save']
        end
      end

      Spec::Rake::SpecTask.new(:diffraw) do |t|
        t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
        t.spec_files = FileList['spec/**/*/*_spec.rb']
        t.rcov = true
        t.rcov_opts = lambda do
          IO.readlines("#{RAILS_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten + ['--text-coverage-diff', '--no-color']
        end
      end

      @rcov_log_file = 'log/rcov.log'
      desc %{Run all specs and display uncovered code since last save to "#{@rcov_log_file}"}
      task :diff do
        sh "rake spec:rcov:diffraw 2>&1 | tee #{@rcov_log_file}"
        puts %{\n# Saved above rcov diff report to "#{@rcov_log_file}"}
      end

      desc 'Clean up, delete coverage report and coverage status'
      task :clean do
        rm_r 'coverage' rescue nil
        rm_r 'coverage.info' rescue nil
      end
    end
  end
end
