require 'passport_control/border_check'

ActiveRecord::Base.class_eval { include PassportControl::BorderCheck }

