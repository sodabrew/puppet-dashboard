#!/usr/bin/env ruby

require 'fileutils'
require 'data_generator'

namespace :reports do
  namespace :samples do

    desc "Remove previously generated sample reports."
    task :clean do
      report_dir = 'tmp/sample_reports'

      FileUtils.rm_rf(report_dir)
    end
  end
end
