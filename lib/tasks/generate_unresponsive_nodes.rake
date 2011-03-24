require 'data_generator'

namespace :node do
  desc "Generate NUM_NODES unresponsive nodes with random hostnames for testing"
  task :generate_unresponsive => :environment do
    num_nodes = ENV['NUM_NODES'].to_i || 1

    num_nodes.times do
      Node.create!(:name => DataGenerator.generate_hostname)
    end
  end
end
