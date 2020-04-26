class MachineMonthlyLog < ApplicationRecord
  belongs_to :machine, -> { with_deleted }
   serialize :x_axis, Array
  serialize :y_axis, Array

  def self.delete_data
    MachineMonthlyLog.where("created_at <?",Date.today.beginning_of_month).delete_all
  end

  def self.data_tranfor
     beginning_of_month = Date.today.beginning_of_month
     beginning_of_pre_month = beginning_of_month.months_ago(1)
     previous_month = MachineLog.where(created_at: beginning_of_pre_month..beginning_of_month)
      previous_month.each do | p |
     	PreMonthlyLog.create(parts_count:p.parts_count,machine_status:p.machine_status,job_id:p.job_id,total_run_time:p.total_run_time,total_cutting_time:p.total_cutting_time,run_time:p.run_time,feed_rate:p.feed_rate,cutting_speed:p.cutting_speed,axis_load:p.axis_load,axis_name:p.axis_name,spindle_speed:p.spindle_speed,spindle_load:p.spindle_load,total_run_second:p.total_run_second,programe_number:p.programe_number,run_second:p.run_second,machine_id:p.machine_id)
      end
  end


  # def self.hour_wise_data(params)
  #   mac = Machine.find(params[:machine_id])
  #   tenant = mac.tenant
  #   date = Date.today.strftime("%Y-%m-%d")
  #   shift = Shifttransaction.current_shift(tenant.id)
  #   if CncHourReport.where(machine_id: mac.id date: date, shift_no: shift.shift_no).present?
  #     cnc_reports = CncHourReport.where(machine_id: mac.id date: date, shift_no: shift.shift_no)
      
  #   else
      
  #   end
  # end
end
