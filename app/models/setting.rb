class Setting < ApplicationRecord
  #serialize :operator_split, Array
  serialize :split, Array
  belongs_to :tenant
  #serialize :shift_split, :operator_split, Array 

  def self.rs_part_hourwise(params)
    date = Date.today.strftime("%Y-%m-%d")
    tenant = Tenant.find(params[:tenant_id])
    mac =  Machine.find(params[:machine_id])
    shift = Shifttransaction.current_shift(tenant.id)
    #@logs = mac.machine_daily_logs.pluck(:parts_count)

case
      when shift.day == 1 && shift.end_day == 1	
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      when shift.day == 1 && shift.end_day == 2
        if Time.now.strftime("%p") == "AM"
          start_time = (date+" "+shift.shift_start_time).to_time-1.day
          end_time = (date+" "+shift.shift_end_time).to_time
        else
          start_time = (date+" "+shift.shift_start_time).to_time
          end_time = (date+" "+shift.shift_end_time).to_time+1.day
        end
      else
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      end
    @alldata = []

    run_time2 = [] 
    idle_time2 = []
    stop_time2 = []
    time_diff2 = []

    loop_count = 1
    (start_time.to_i..end_time.to_i).step(3600) do |hour|
    	
      if hour.to_i != end_time.to_i
        (hour.to_i+3600 < end_time.to_i) ? (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(hour.to_i+3600).strftime("%Y-%m-%d %H:%M")) : (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(end_time).strftime("%Y-%m-%d %H:%M"))
       # machines.order(:id).map do |mac|
          machine_log = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",hour_start_time[0].to_time,hour_end_time.to_time).order(:id)
          duration = hour_end_time.to_time.to_i - hour_start_time[0].to_time.to_i

            new_parts = Machine.new_parst_count(machine_log)
            run_time1 = Machine.run_time(machine_log)
			stop_time1 = Machine.stop_time(machine_log)
			idle_time1 = Machine.ideal_time(machine_log)
            time_diff = duration - (run_time1+stop_time1+idle_time1)
            
            run_time2 << run_time1 
            idle_time2 << idle_time1
            stop_time2 << stop_time1
            time_diff2 << time_diff


            run_time = Time.at(run_time1).utc.strftime("%H:%M:%S")
            idle_time = Time.at(idle_time1).utc.strftime("%H:%M:%S")
            stop_time = Time.at(stop_time1).utc.strftime("%H:%M:%S")


            if Time.now > hour_end_time.to_time
              if stop_time1.to_i > run_time1.to_i && stop_time1.to_i > idle_time1.to_i
               stop_time = Time.at(stop_time1.to_i + time_diff.to_i).utc.strftime("%H:%M:%S")
              else
	           stop_time = Time.at(stop_time1.to_i).utc.strftime("%H:%M:%S")
              end
              
              if idle_time1.to_i >= run_time1.to_i && idle_time1.to_i >= stop_time1.to_i
                 idle_time = Time.at(idle_time1.to_i + time_diff.to_i).utc.strftime("%H:%M:%S")
              else
	             idle_time = Time.at(idle_time1.to_i).utc.strftime("%H:%M:%S")
              end
              
              if run_time1.to_i > idle_time1.to_i && run_time1.to_i > stop_time1.to_i
                run_time = Time.at(run_time1.to_i + time_diff.to_i).utc.strftime("%H:%M:%S")
              else
	            run_time = Time.at(run_time1.to_i).utc.strftime("%H:%M:%S")
              end
            #else
            end

            @data = {
              :time => hour_start_time[0].split(" ")[1]+' - '+hour_end_time.split(" ")[1],
              :count => new_parts,
              :run_time => run_time,
              :idle_time => idle_time,
              :stop_time => stop_time
             }
             
            @alldata << @data
            
        end

      #end
    end
    
   return {data: @alldata, tot_run: run_time2.sum, tot_idle: idle_time2.sum, tot_stop: stop_time2.sum, no_data: time_diff2.sum }



end








  def self.single_part_report_hour(params)
    date = Date.today.strftime("%Y-%m-%d")
    tenant = Tenant.find(params[:tenant_id])
    mac =  Machine.find(params[:machine_id])
   # shift = Shifttransaction.find(5)
    shift = Shifttransaction.current_shift(tenant.id)
      case
      when shift.day == 1 && shift.end_day == 1
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      when shift.day == 1 && shift.end_day == 2
        if Time.now.strftime("%p") == "AM"
          start_time = (date+" "+shift.shift_start_time).to_time-1.day
          end_time = (date+" "+shift.shift_end_time).to_time
        else
          start_time = (date+" "+shift.shift_start_time).to_time
          end_time = (date+" "+shift.shift_end_time).to_time+1.day
        end
      else
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      end
       time1 = end_time - Time.now    

    @alldata = []
     
    run_time2 = [] 
    idle_time2 = []
    stop_time2 = []
    time_diff2 = []
    
    loop_count = 1
    (start_time.to_i..end_time.to_i).step(3600) do |hour|
      if hour.to_i != end_time.to_i
        (hour.to_i+3600 < end_time.to_i) ? (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(hour.to_i+3600).strftime("%Y-%m-%d %H:%M")) : (hour_start_time=Time.at(hour).strftime("%Y-%m-%d %H:%M"),hour_end_time=Time.at(end_time).strftime("%Y-%m-%d %H:%M"))
       # machines.order(:id).map do |mac|
          machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",hour_start_time[0].to_time,hour_end_time.to_time).order(:id)
          duration = hour_end_time.to_time.to_i - hour_start_time[0].to_time.to_i

            new_parts = Machine.new_parst_count(machine_log1)
            run_time1 = Machine.run_time(machine_log1)
			      stop_time1 = Machine.stop_time(machine_log1)
			      idle_time1 = Machine.ideal_time(machine_log1)
            time_diff = duration - (run_time1+stop_time1+idle_time1)
 
            run_time2 << run_time1 
            idle_time2 << idle_time1
            stop_time2 << stop_time1
            time_diff2 << time_diff

            run_time = Time.at(run_time1).utc.strftime("%H:%M:%S")
            idle_time = Time.at(idle_time1).utc.strftime("%H:%M:%S")
            stop_time = Time.at(stop_time1).utc.strftime("%H:%M:%S")


            if Time.now > hour_end_time.to_time
              if stop_time1.to_i > run_time1.to_i && stop_time1.to_i > idle_time1.to_i
               stop_time = Time.at(stop_time1.to_i + time_diff.to_i).utc.strftime("%H:%M:%S")
              else
	             stop_time = Time.at(stop_time1.to_i).utc.strftime("%H:%M:%S")
              end
              
              if idle_time1.to_i >= run_time1.to_i && idle_time1.to_i >= stop_time1.to_i
                 idle_time = Time.at(idle_time1.to_i + time_diff.to_i).utc.strftime("%H:%M:%S")
              else
	             idle_time = Time.at(idle_time1.to_i).utc.strftime("%H:%M:%S")
              end
              
              if run_time1.to_i > idle_time1.to_i && run_time1.to_i > stop_time1.to_i
                run_time = Time.at(run_time1.to_i + time_diff.to_i).utc.strftime("%H:%M:%S")
              else
	            run_time = Time.at(run_time1.to_i).utc.strftime("%H:%M:%S")
              end
            #else
            end
            @data = {
              :time => hour_start_time[0].split(" ")[1]+' - '+hour_end_time.split(" ")[1],
              :count => new_parts,
              :run_time => run_time,
              :idle_time => idle_time,
              :stop_time => stop_time              
             }
            @alldata << @data
        end
      #end
    end
            time2 = Time.at(time1).utc.strftime("%H:%M:%S")
            tot_run = run_time2.sum
            tot_idle = idle_time2.sum
            tot_stop = stop_time2.sum
            tot_diff = time_diff2.sum - time1.to_i
            

             if tot_stop.to_i > tot_run.to_i && tot_stop.to_i > tot_idle.to_i
               total_stop_time = Time.at(tot_stop.to_i + tot_diff.to_i).utc.strftime("%H:%M:%S")
              else
               total_stop_time = Time.at(tot_stop.to_i).utc.strftime("%H:%M:%S")
              end
              
              if tot_idle.to_i >= tot_run.to_i && tot_idle.to_i >= tot_stop.to_i
                 total_idle_time = Time.at(tot_idle.to_i + tot_diff.to_i).utc.strftime("%H:%M:%S")
              else
                 total_idle_time = Time.at(tot_idle.to_i).utc.strftime("%H:%M:%S")
              end
              
              if tot_run.to_i > tot_idle.to_i && tot_run.to_i > tot_stop.to_i
                total_run_time = Time.at(tot_run.to_i + tot_diff.to_i).utc.strftime("%H:%M:%S")
              else
                total_run_time = Time.at(tot_run.to_i).utc.strftime("%H:%M:%S")
              end
              


   return {data: @alldata, tot_run: total_run_time, tot_idle: total_idle_time, tot_stop: total_stop_time, no_data: time2, machine_name: mac.machine_name, machine_model: mac.machine_model, machine_ip: mac.machine_ip, machine_serial_no: mac.machine_serial_no, shift_part_count: @alldata.pluck(:count).sum }#@alldata
end






def self.single_part_report(params)
	date = Date.today.strftime("%Y-%m-%d")
    tenant = Tenant.find(params[:tenant_id])
    mac =  Machine.find(params[:machine_id])
    shift = Shifttransaction.current_shift(tenant.id)
     case
      when shift.day == 1 && shift.end_day == 1
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      when shift.day == 1 && shift.end_day == 2
        if Time.now.strftime("%p") == "AM"
          start_time = (date+" "+shift.shift_start_time).to_time-1.day
          end_time = (date+" "+shift.shift_end_time).to_time
        else
          start_time = (date+" "+shift.shift_start_time).to_time
          end_time = (date+" "+shift.shift_end_time).to_time+1.day
        end
      else
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
      end
      machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
      new_parts = Machine.new_parst_count(machine_log1)
      data = {
      	parts_produced: new_parts,
      	rejects: 0,
      	rework: 0,
      	inspection: 0,
      	remaining_parts: 0,
      	parts_delivered: 0
      }
end


end
