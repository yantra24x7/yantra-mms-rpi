class ExternalSetAlarmSetting < ActiveRecord::Base
 establish_connection("#{Rails.env}_sec".to_sym)
 self.table_name = "set_alarm_settings"
end

