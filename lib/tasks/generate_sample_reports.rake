#!/usr/bin/env ruby

require 'erb'
require 'ostruct'
require 'rubygems'
require 'active_support/all'
require 'YAML'
require 'fileutils'
require 'data_generator'

namespace :reports do
  namespace :samples do

    desc "Generate sample YAML reports with in REPORT_DIR with NUM_NODES, NUM_STATUSES, NUM_EVENTS"
    task :generate do
      DEFAULT_DIR = 'tmp/sample_reports'
      report_dir = ENV['REPORT_DIR'] || DEFAULT_DIR
      options = {
        :num_statuses => ENV['NUM_STATUSES'].to_i || 3,
        :num_events   => ENV['NUM_EVENTS'].to_i   || 3,
      }
      num_nodes = ENV['NUM_NODES'].to_i || 100

      FileUtils.mkdir_p(report_dir)

      num_nodes.times do
        report = DataGenerator.generate_reports(options)
        File.open("#{report_dir}/#{report.host}.yaml","w") do |f|
          f.print YAML.dump(report)
        end
      end
    end
  end
end
