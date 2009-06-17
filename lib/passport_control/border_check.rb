module PassportControl
  
  #
  # The Border keeps a track of the classes that have instances registered
  # at PassportControl. This is required so that the border can be cleared
  # at test setup time.
  #
  class Border
    cattr_accessor :registered_classes
    @@registered_classes = []
    
    def self.register_class( klass )
      registered_classes << klass
    end
    
    def self.clear
      registered_classes.each { |klass| klass.clear_wanted_list }
      registered_classes = []
    end
  end
  
  module BorderCheck
    def self.included( base )
      base.extend( ClassMethods )
      
      base.instance_eval do
        class_inheritable_accessor :passport_control_wanted_list, :passport_control_border_checks
        self.passport_control_border_checks = false
        include InstanceMethods
      end
      
      class << base
        alias_method_chain :instantiate, :passport_checking
      end
    end
    
    module ClassMethods
      
      #
      # The #instantiate method is the choke point for all ActiveRecord
      # object creation. This is probably evil but saves us from messing
      # about with AR callbacks. If border checking is enabled for this
      # class it sees whether this is a wanted instance or not and calls
      # anyone interested (to mock/stub the object)
      #
      def instantiate_with_passport_checking( record )
        instance = instantiate_without_passport_checking( record )
        self.passport_control_wanted_list[instance.id].each { |wanted| wanted.call( instance ) } if self.passport_control_border_checks
        instance
      end
      
      def clear_wanted_list
        self.passport_control_wanted_list.clear
      end
      
      def at_passport_control( id, &action )
        Border.register_class( self )
        self.passport_control_border_checks = true
        self.passport_control_wanted_list ||= Hash.new { [] }
        self.passport_control_wanted_list[id] = self.passport_control_wanted_list[id] << action
      end
      
    end
    
    module InstanceMethods
      def at_passport_control( &action )
        self.class.at_passport_control( id, &action )
      end
    end
    
  end
  
end
