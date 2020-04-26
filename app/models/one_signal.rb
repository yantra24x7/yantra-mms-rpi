class OneSignal < ApplicationRecord
 # self.abstract_class = true
 # establish_connection("#{Rails.env}_sec".to_sym)
  belongs_to :user, -> { with_deleted }
  belongs_to :tenant
end
