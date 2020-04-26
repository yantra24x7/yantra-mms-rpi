class ExternalTenant < ActiveRecord::Base
 establish_connection("#{Rails.env}_sec".to_sym)
 self.table_name = "tenants"
end
