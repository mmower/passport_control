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
        class_inheritable_accessor :wanted_list, :border_checks
        self.border_checks = false
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
        self.wanted_list[instance.id].each { |wanted| wanted.call( instance ) } if self.border_checks
        instance
      end
      
      def clear_wanted_list
        self.wanted_list.clear
      end
      
      def on_entry( id, &action )
        Border.register_class( self )
        self.border_checks = true
        self.wanted_list ||= Hash.new { [] }
        self.wanted_list[id] = self.wanted_list[id] << action
      end
    end
    
  end
  
end
