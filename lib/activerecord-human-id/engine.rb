module HumanID
  class Engine < Rails::Engine
    isolate_namespace HumanID

    rake_tasks { load 'tasks/human_id.rake' }
  end
end