module HumanID
  class Engine < Rails::Engine
    isolate_namespace HumanID

    # http://blog.nathanhumbert.com/2010/02/rails-3-loading-rake-tasks-from-gem.html
    rake_tasks { load 'tasks/human_id.rake' }
  end
end