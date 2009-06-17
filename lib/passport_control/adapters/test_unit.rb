module PassportControl
  module Adapters
    module TestUnit
      
      def self.included( mod )
        mod.class_eval do
          def setup_with_passport_control
            PassportControl::Border.clear
            setup_without_passport_control
          end
          
          alias_method_chain :setup, :passport_control
        end
      end
    end
  end
end
