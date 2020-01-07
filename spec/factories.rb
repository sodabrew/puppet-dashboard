FactoryBot.define do

  sequence :name do |n|
    "name_#{n}"
  end

  sequence :filename do |n|
    dir = "dir_{n}"
    File.join('/', dir, dir, dir)
  end

  sequence :time do |n|
    # each things created will be 1 hour newer than the last
    # might be a problem if creating more than 1000 objects
    (1000 - n).hours.ago
  end

  factory :node_group do
    name
  end

  factory :node_class do
    name
  end

  factory :node do
    name

    factory :reported_node do |node|
      after(:create) do |node|
        create(:report, :node => node, :host => node.name)
        node.reload
      end

      factory :unresponsive_node do
        after(:create) do |node|
          node.last_apply_report.update!(time: 2.days.ago)
          node.update!(reported_at: 2.days.ago)
        end
      end

      factory :responsive_node do
        after(:create) do |node|
          node.last_apply_report.update!(time: 2.minutes.ago)
          node.update!(reported_at: 2.minutes.ago)
        end

        factory :failing_node do
          after(:create) do |node|
            node.last_apply_report.update!(status: 'failed')
            node.update!(status: 'failed')
          end
        end

        factory :pending_node do
          after(:create) do |node|
            node.last_apply_report.update!(status: 'pending')
            node.update!(status: 'pending')
            create(:pending_resource, report: node.last_apply_report)
          end
        end

        factory :changed_node do
          after(:create) do |node|
            node.last_apply_report.update!(status: 'changed')
            node.update!(status: 'changed')
            create(:changed_resource, report: node.last_apply_report)
          end
        end

        factory :unchanged_node do
          after(:create) do |node|
            node.last_apply_report.update!(status: 'unchanged')
            node.update!(status: 'unchanged')
          end
        end

      end
    end
  end

  factory :parameter do
    sequence(:key)   {|n| "Key #{n}"   }
    sequence(:value) {|n| "Value #{n}" }
  end

  factory :report do
    status { 'failed' }
    kind { 'apply' }
    host do |rep|
      if rep.node
        rep.node.name
      else
        generate(:name)
      end
    end
    time

    factory :successful_report do
      status { 'changed' }
    end

    factory :failing_report do
      status { 'failed' }
    end

    factory :inspect_report do
      kind { 'inspect' }
    end
  end


  factory :resource_status do
    resource_type { 'File' }
    title { generate(:filename) }
    evaluation_time { rand(60)+1 }
    file { generate(:filename) }
    line { rand(60)+1 }
    time
    change_count { 0 }
    out_of_sync_count { 0 }
    skipped { false }
    failed { false }

    factory :failed_resource do
      failed { true }
      after(:create) do |status|
        create(:resource_event, :resource_status => status, :status => 'failed')
        status.change_count += 1
        status.out_of_sync_count += 1
        status.save
      end
    end

    factory :changed_resource do
      after(:create) do |status|
        status.status = 'changed'
        create(:resource_event, :resource_status => status, :status => 'changed')
        status.change_count += 1
        status.out_of_sync_count += 1
        status.save
      end
    end

    factory :successful_resource do
      after(:create) do |status|
        create(:resource_event, :resource_status => status, :status => 'success')
        status.change_count += 1
        status.out_of_sync_count += 1
        status.save
      end
    end

    factory :pending_resource do
      after(:create) do |status|
        create(:resource_event, :resource_status => status, :status => 'noop')
        status.out_of_sync_count += 1
        status.save
      end
    end

  end

  factory :resource_event

end
