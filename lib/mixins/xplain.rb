module Xplain
  @@current_workflow = Workflow.new

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
    
end