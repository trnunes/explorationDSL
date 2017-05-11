module Explorable
  attr_accessor :intention
  def self.included klass
    klass.class_eval do
      include AuxiliaryOperations
    end
  end
  
  def register_observer(observer)
    @observers ||= Set.new
    @observers << observer
  end
  
  def dependency_changed(dependency)
    result_set = intention.execute
    extension = result_set.extension
    notify()
  end
  
  def notify
    @observers.each do |obs|
      obs.dependency_changed(self);
    end
  end
  
end