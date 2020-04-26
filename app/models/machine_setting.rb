class MachineSetting < ApplicationRecord
  belongs_to :machine
  has_many :machine_setting_lists

def self.machine_setting
	Machine.all.each do |mac|
       mac_setting = MachineSetting.create(machine_id: mac.id)
       MachineSettingList.create(machine_setting_id: mac_setting.id, setting_name: "x_axis")
       MachineSettingList.create(machine_setting_id: mac_setting.id, setting_name: "y_axis")
       MachineSettingList.create(machine_setting_id: mac_setting.id, setting_name: "z_axis")
       MachineSettingList.create(machine_setting_id: mac_setting.id, setting_name: "a_axis")
       MachineSettingList.create(machine_setting_id: mac_setting.id, setting_name: "b_axis")
	end
end


  def self.machine_list
  @machine_setting = MachineSetting.create(is_active: true, machine_id: machine_id)
    if @machine_setting.save
    	render json: @machine_setting, status: :created
    else
    	render json: @machine_setting.errors, status: :unprocessable_entity
    end
  end





def self.status
    a = []
    Machine.find(6).machine_setting.machine_setting_lists.each_with_index do |(key, value), index|
     if key.is_active == true && ["x_axis", "y_axis", "z_axis", "a_axis", "b_axis"].include?(key.setting_name)
     a << key
     end
     
    end
    byebug
end


end
