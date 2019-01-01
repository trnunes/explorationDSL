module Xplain
  @@current_workflow = nil
  @@cache_enabled = false  
  @@exploration_repository = MemoryRepository.new
  
  def self.get_current_workflow
    @@current_workflow ||= Workflow.new
    @@current_workflow
  end

  def self.exploration_repository
    @@exploration_repository
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
    if server_params.is_a? Hash
      klass = server_params[:class]
      klass = eval(klass) if klass.is_a? String
      @@default_server = klass.new(server_params)
    else
      @@default_server = server_params
    end
    @@default_server
  end
  
  def self.set_exploration_repository(repository_params)
    if repository_params.is_a? Hash
      klass = repository_params[:class]
      @@exploration_repository = klass.new(repository_params)
    else
      @@exploration_repository = repository_params
    end
    @@exploration_repository
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


class String
  
  def to_underscore
    self.gsub(/::/, '/').
    gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
    gsub(/([a-z\d])([A-Z])/,'\1_\2').
    tr("-", "_").
    downcase
  end
  
  def to_camel_case
    return self if self !~ /_/ && self =~ /[A-Z]+.*/
    split('_').map{|e| e.capitalize}.join
  end
end