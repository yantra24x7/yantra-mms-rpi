class ExternalOneSignal < ActiveRecord::Base
 belongs_to :external_user, -> { with_deleted }
 belongs_to :externai_tenant

 establish_connection("#{Rails.env}_sec".to_sym)
# self.table_name = "one_signals"
  def self.one_signal
    self.table_name = "one_signals"
  end
  
  def self.user
    self.table_name = "users"
  end
  

end
