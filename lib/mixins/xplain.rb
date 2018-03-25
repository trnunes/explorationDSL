module Xplain
  @@current_workflow = Workflow.new
  @@model_config = ModelConfig.new
  def self.get_current_workflow
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
  
  def self.default_server
    @@default_server
  end
    
  #Config
  # 1 config data adapter
  # 2 config exploration adapter
  # 3 config visualization
  # 4 config relations label
  # 6 config types query
  
    
end