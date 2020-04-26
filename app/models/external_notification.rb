class ExternalNotification < ActiveRecord::Base
 establish_connection("#{Rails.env}_sec".to_sym)
 self.table_name = "notifications"
end

