class ExternalMachine < ActiveRecord::Base
 establish_connection("#{Rails.env}".to_sym)
# self.table_name = "machines"
end
