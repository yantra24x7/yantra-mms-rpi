class AddFieldToHmiReason < ActiveRecord::Migration[5.0]
  def change
    add_reference :hmi_machine_reasons, :hmi_machine_detail, foreign_key: true
    add_column :hmi_machine_details, :start_time, :time
    add_column :hmi_machine_details, :end_time, :time
    add_column :hmi_machine_details, :description, :string
  end
end
