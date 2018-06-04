module Xplain
  @@current_workflow = nil
  @@cache_enabled = false  
  
  def self.get_current_workflow
    @@current_workflow ||= Workflow.new
    @@current_workflow
  end

  def self.new_workflow
    @@current_workflow = Workflow.new
    @@current_workflow
  end

  def self.reset_workflow
    @@current_workflow = Workflow.new
    @@current_workflow
  end
  
  def self.set_default_server(server_params)
    klass = server_params[:class]
    @@default_server = klass.new(server_params)
  end
  
  def self.set_exploration_repository(repository_params)
    klass = server_params[:class]
    @@exploration_repository = klass.new(server_params)
  end
  
  def self.default_server
    @@default_server
  end
    
  def self.cache_enabled?
    @@cache_enabled  
  end
  
  def self.enable_cache
    @@cache_enabled = true
  end

  def self.disable_cache
    @@cache_enabled = false
  end
  

  #Config
  # 1 config data adapter
  # 2 config exploration adapter
  # 3 config visualization
  # 4 config relations label
  # 6 config types query
  
    
end