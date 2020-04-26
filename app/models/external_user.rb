class ExternalUser < ActiveRecord::Base
  # attribute :name, :age
  # has_many :external_one_signals
  # has_many :one_signals
#  serialize :machine_type, Array
#  enum unit: {"Unit - 1": 1, "Unit - 2": 2, "Unit - 3": 3, "Unit - 4": 4, "Unit - 5": 5}
  self.abstract_class = true 
  establish_connection("#{Rails.env}_sec".to_sym)
  self.table_name = "set_alarm_settings"
 # def self.user
 #   "users."
 # end
end
