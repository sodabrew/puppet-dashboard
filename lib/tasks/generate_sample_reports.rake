#!/usr/bin/env ruby

require 'erb'
require 'ostruct'
require 'rubygems'
require 'active_support/all'
require 'yaml'
require 'fileutils'
require 'data_generator'

namespace :reports do
  namespace :samples do

    desc "Generate NUM_REPORTS sample YAML reports for NUM_NODES nodes, each with NUM_STATUSES with NUM_EVENTS."
    task :generate do
      report_dir = 'tmp/sample_reports'
      ENV['REPORT_DIR'] = report_dir
      options = {
        :num_statuses => (ENV['NUM_STATUSES'] || 3).to_i,
        :num_events   => (ENV['NUM_EVENTS']   || 3).to_i,
      }
      num_nodes = (ENV['NUM_NODES'] || 20).to_i
      num_reports = (ENV['NUM_REPORTS'] || 3).to_i

      FileUtils.mkdir_p(report_dir)

      if Dir[File.join(report_dir, '**', '*.yaml')].present?
        puts "Sample reports already present in #{report_dir}; these may cause conflicts when importing into the database"
      end

      num_nodes.times do
        options[:hostname] = DataGenerator.generate_hostname
        num_reports.times do |i|
          options[:time_offset] = i
          report = DataGenerator.generate_reports(options)
          File.open("#{report_dir}/#{report.host}_#{i}.yaml","w") do |f|
            f.print YAML.dump(report)
          end
        end
      end
    end
  end
end
