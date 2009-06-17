module PassportControl
  
  class Border
    cattr_accessor :officials
    @@officials = {}
    
    def self.flag( klass, id, &official )
      puts "FLAGGING #{klass},#{id}"
      officials[klass] = Hash.new { [] } if !officials.has_key?( klass )
      officials[klass][id] = officials[klass][id] << official
    end
    
    def self.present_papers( inst )
      puts "INSTANCE #{inst} PRESENTING PAPERS"
      if officials.has_key? inst.class
        if officials[inst.class].has_key? inst.id
          officials[inst.class][inst.id].each { |official| official.call( inst ) }
        end
      end
    end
    
    def self.clear
      puts "CLEARING THE BORDER"
      officials.clear
    end
    
  end
  
  module BorderCheck
    def self.included( base )
      base.extend( ClassMethods )
      
      class << base
        alias_method_chain :instantiate, :passport_check
      end
    end
    
    module ClassMethods
      
      def instantiate_with_passport_check( record )
        instance = instantiate_without_passport_check( record )
        Border.present_papers( instance )
        instance
      end
      
      def on_entry( id, &official )
        puts "ON ENTRY TO #{self},#{id}"
        Border.flag( self, id, &official )
      end
    end
    
  end
  
end
