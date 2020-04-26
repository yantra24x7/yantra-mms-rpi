class CncReport < ApplicationRecord
  belongs_to :shift
  belongs_to :operator, -> { with_deleted }, :optional=>true
  belongs_to :machine, -> { with_deleted }
  belongs_to :tenant
  serialize :all_cycle_time, Array
  serialize :cycle_start_to_start, Array


def self.delay_jobs 
	a = Time.now
  tenants = Tenant.where(id: [10])#isactive: true)
  tenants.each do |tenant|
  	date = Date.today.strftime("%Y-%m-%d")
    shift1 = Shifttransaction.current_shift(tenant.id)
    #shift1 = Shifttransaction.find(2)
  # tenant.shift.shifttransactions.each do |shift1|

   if shift1.shift_start_time.to_time + 25.minutes > Time.now
    if shift1.shift_no == 1
	    shift = tenant.shift.shifttransactions.last
      date = Date.yesterday.strftime("%Y-%m-%d")
    else
      shift = tenant.shift.shifttransactions.where(shift_no: shift1.shift_no - 1).last
    end
     
  #   if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		#   if Time.now.strftime("%p") == "AM"
		# 	  date = (Date.today - 1).strftime("%Y-%m-%d")
		#   end 
		#   start_time = (date+" "+shift.shift_start_time).to_time
		#   end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		# elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")

		#   if Time.now.strftime("%p") == "AM" 
		# 	  date = (Date.today - 1).strftime("%Y-%m-%d")
		#   end
		#   if shift.day == 1
  #       start_time = (date+" "+shift.shift_start_time).to_time
  #       end_time = (date+" "+shift.shift_end_time).to_time
  #     else
  #       start_time = (date+" "+shift.shift_start_time).to_time+1.day
  #       end_time = (date+" "+shift.shift_end_time).to_time+1.day
  #     end
		#   #start_time = (date+" "+shift.shift_start_time).to_time+1.day
		#   #end_time = (date+" "+shift.shift_end_time).to_time+1.day
		# else           
		#   start_time = (date+" "+shift.shift_start_time).to_time
		#   end_time = (date+" "+shift.shift_end_time).to_time        
		# end


	if tenant.id != 31 || tenant.id != 10
		if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end 
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")           
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end
		  if shift.day == 1
           start_time = (date+" "+shift.shift_start_time).to_time
           end_time = (date+" "+shift.shift_end_time).to_time
         else
           start_time = (date+" "+shift.shift_start_time).to_time+1.day
           end_time = (date+" "+shift.shift_end_time).to_time+1.day
         end
		 # start_time = (date+" "+shift.shift_start_time).to_time+1.day
		 # end_time = (date+" "+shift.shift_end_time).to_time+1.day
		else              
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time        
		end
	else
		case
      when shift.day == 1 && shift.end_day == 1   
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time  
      when shift.day == 1 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day    
      else
        start_time = (date+" "+shift.shift_start_time).to_time+1.day
        end_time = (date+" "+shift.shift_end_time).to_time+1.day     
      end
	end



    if start_time + 25.minutes > Time.now
	    unless Delayed::Job.where(run_at: shift1.shift_start_time.to_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").present?
		    CncReport.delay(run_at: shift1.shift_start_time.to_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").cnc_report(tenant.id, shift.shift_no, date)
		  end
	    unless Delayed::Job.where(run_at: shift1.shift_start_time.to_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").present?
	    	if tenant.id == 3
	    		HourReport.delay(run_at: shift1.shift_start_time.to_time + 45.minutes, tenant: 3, shift: shift.shift_no, date: date, method: "hour_report").hourly_report
	    	end
	   	  CncHourReport.delay(run_at: shift1.shift_start_time.to_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").cnc_hour_report(tenant.id, shift.shift_no, date)
	    end
	  end
	 end 	
  end

end


def self.delay_jobs1
  tenants = Tenant.where(isactive: true)
  tenants.each do |tenant|
    date = Date.today.strftime("%Y-%m-%d")
    tenant.shift.shifttransactions.each do |shift|
       
           case
          when shift.day == 1 && shift.end_day == 1   
            start_time = (date+" "+shift.shift_start_time).to_time
            end_time = (date+" "+shift.shift_end_time).to_time  
          when shift.day == 1 && shift.end_day == 2
            start_time = (date+" "+shift.shift_start_time).to_time
            end_time = (date+" "+shift.shift_end_time).to_time+1.day    
          when shift.day == 2 && shift.end_day == 2
            start_time = (date+" "+shift.shift_start_time).to_time+1.day
            end_time = (date+" "+shift.shift_end_time).to_time+1.day     
          end
       # end
        # byebug

	    unless Delayed::Job.where(run_at: end_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").present?
		    CncReport.delay(run_at: end_time + 20.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_report").cnc_report(tenant.id, shift.shift_no, date)
		  end
	    unless Delayed::Job.where(run_at: end_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").present?
	    	if tenant.id == 3
	    		HourReport.delay(run_at: start_time + 45.minutes, tenant: 3, shift: shift.shift_no, date: date, method: "hour_report").hourly_report
	    	end
	   	  CncHourReport.delay(run_at: end_time + 15.minutes, tenant: tenant.id, shift: shift.shift_no, date: date, method: "cnc_hour_report").cnc_hour_report(tenant.id, shift.shift_no, date)
	    end
	  end
  end
end




def self.delay_jobs2

	a = Time.now
  tenants = Tenant.where(id: 8)
  tenants.each do |tenant|
    date = Date.today.strftime("%Y-%m-%d")
    shift = Shifttransaction.current_shift(tenant.id)    
    #shift = Shifttransaction.find(6)
    case
      when shift.day == 1 && shift.end_day == 1   
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
        date = Date.today.strftime("%Y-%m-%d")  
      when shift.day == 1 && shift.end_day == 2
        if Time.now.strftime("%p") == "AM"
          start_time = (date+" "+shift.shift_start_time).to_time-1.day
          end_time = (date+" "+shift.shift_end_time).to_time
          date = (Date.today - 1.day).strftime("%Y-%m-%d")
        else
          start_time = (date+" "+shift.shift_start_time).to_time
          end_time = (date+" "+shift.shift_end_time).to_time+1.day
          date = Date.today.strftime("%Y-%m-%d")
        end    
      when shift.day == 2 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time
        date = (Date.today - 1.day).strftime("%Y-%m-%d")      
      end
        
      duration = end_time.to_i - start_time.to_i
      tenant.machines.where(controller_type: 1).order(:id).map do |mac|
      machine_log = mac.machine_daily_logs.where("created_at >=? AND created_at <?",start_time,end_time).order(:id)
      tot_run = Machine.calculate_total_run_time(machine_log)
      tot_stop = Machine.stop_time(machine_log)
	  tot_idle = Machine.ideal_time(machine_log)
	  count = machine_log.where(machine_status: 3).pluck(:programe_number, :parts_count).uniq
      
      job_id = machine_log.where.not(:job_id=>"",:programe_number=>nil).order(:id).last.present? ? ""+machine_log.where.not(:job_id=>"",:programe_number=>nil).order(:id).last.programe_number+"-"+machine_log.where.not(:job_id=>"",:programe_number=>nil).order(:id).last.job_id : nil
      #machine_log.where(machine_status: 3)
      
      # shift_wise_part = []
      # shift_wise = count.group_by {|(k, v)| k }.map {|k, v1| [k, v1.count]}.to_h
      
      shift_wise_part2 = []
      
       if machine_log.present? && machine_log.where(machine_status: 3).present?
       machine_log.where(machine_status: 3).group_by{|d| d[:programe_number]}.map do |k, v|
       	 cc = v.pluck(:parts_count).uniq.count
         shift_wise_part2 << { program_number: k, parts_count: cc }
       end
       end
      
      # shift_wise_part << shift_wise
      if count.present?
        total_count = count.count - 1
        
        unless count.count == 1
          data = count[-2]
          data2 = machine_log.where(programe_number: data[0], parts_count: data[1]).last
          cycle_time = data2.run_time * 60 + data2.run_second.to_i/1000
        else
          data = count[-1]
          cycle_time = 0
        end
      else
      	cycle_time = 0
      	total_count = 0
      end
      utilization = (tot_run*100)/duration
      status = mac.machine_daily_logs.last.machine_status
      balance_time = end_time.to_i - Time.now.to_i
      tot_diff = duration - (balance_time + tot_run + tot_idle + tot_stop)
      
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
    #byebug
	    if DashboardDatum.where(date: date, shifttransaction_id: shift.id, machine_id: mac.id).present?
	      data = DashboardDatum.where(date: date, shifttransaction_id: shift.id, machine_id: mac.id).last
	      data.update(utilization: utilization, cycle_time: cycle_time, run_time: total_run_time, idle_time: total_idle_time, stop_time: total_stop_time, job_wise_part: shift_wise_part2, machine_status: total_count, job_id: job_id)
	    else
	      DashboardDatum.create(date: date, utilization:utilization, shift_no:shift.shift_no, shifttransaction_id: shift.id, machine_id: mac.id, tenant_id: tenant.id, cycle_time: cycle_time, run_time: total_run_time, idle_time: total_idle_time, stop_time: total_stop_time, job_wise_part: shift_wise_part2, machine_status: total_count, job_id: job_id)
	    end
     
      end
	end

  	mac1 = Time.now - a
      CronReport.create(time: mac1.round, report: "1")  
end


def self.cnc_report(tenant, shift_no, date)
  #date = Date.today.strftime("%Y-%m-%d")
  a = Time.now
  date = date
  @alldata = []
	tenant = Tenant.find(tenant)
	machines = tenant.machines.where.not(controller_type: 3)
	shift = tenant.shift.shifttransactions.where(shift_no: shift_no).last
		
	# if tenant.id != 31 || tenant.id != 10
	# 	if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
	# 	  if Time.now.strftime("%p") == "AM"
	# 		date = (Date.today - 1).strftime("%Y-%m-%d")
	# 	  end 
	# 	  start_time = (date+" "+shift.shift_start_time).to_time
	# 	  end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
	# 	elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")           
	# 	  if Time.now.strftime("%p") == "AM"
	# 		date = (Date.today - 1).strftime("%Y-%m-%d")
	# 	  end
	# 	  if shift.day == 1
 #           start_time = (date+" "+shift.shift_start_time).to_time
 #           end_time = (date+" "+shift.shift_end_time).to_time
 #         else
 #           start_time = (date+" "+shift.shift_start_time).to_time+1.day
 #           end_time = (date+" "+shift.shift_end_time).to_time+1.day
 #         end
	# 	 # start_time = (date+" "+shift.shift_start_time).to_time+1.day
	# 	 # end_time = (date+" "+shift.shift_end_time).to_time+1.day
	# 	else              
	# 	  start_time = (date+" "+shift.shift_start_time).to_time
	# 	  end_time = (date+" "+shift.shift_end_time).to_time        
	# 	end
	# else
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
	#end

		  machines.where(controller_type: 2).order(:id).map do |mac|
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
			if shift.operator_allocations.where(machine_id:mac.id).last.nil?
			  operator_id = nil
			else
			  if shift.operator_allocations.where(machine_id:mac.id).present?
				shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
				  aa = ro.from_date
				  bb = ro.to_date
				  cc = date
				  if cc.to_date.between?(aa.to_date,bb.to_date)  
					dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
					if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
					  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
					else
					  operator_id = nil
					end              
				  end
				end
			  else
				operator_id = nil
			  end
			end

			job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
			duration = end_time.to_i - start_time.to_i
			new_parst_count = Machine.new_parst_count(machine_log1)
			run_time = Machine.run_time(machine_log1)
			stop_time = Machine.stop_time(machine_log1)
			ideal_time = Machine.ideal_time(machine_log1)
						
      if mac.controller_type == 2
        cycle_time = Machine.rs232_cycle_time(machine_log1)	
      else
			  #cycle_time = Machine.cycle_time(machine_log1)
			  cycle_time = Machine.cycle_time22(machine_log1)
      end

			start_cycle_time = Machine.start_cycle_time(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)
			utilization =(run_time*100)/duration if duration.present?
			 
			@alldata << [
			  date,
			  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
			  duration,
			  shift.shift.id,
			  shift.shift_no,
			  operator_id,
			  mac.id,
			  job_description.nil? ? "-" : job_description.split(',').join(" & "),
			  new_parst_count,
			  run_time,
			  ideal_time,
			  stop_time,
			  time_diff,
			  count,
			  utilization,
			  tenant.id,
			  cycle_time,
			  start_cycle_time
			  ] 
		  end
		#end
  #end
  
  if @alldata.present?
    @alldata.each do |data|
      if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
	    CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start: data[17])
	  else    
		CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
	  end
    end
  end 
  mac1 = Time.now - a
  CronReport.create(time: mac1.round, report: "1") 
end




def self.last_shift_report(date, machine, tenant, shift_no)
  @alldata = []
  date = date
  tenant = Tenant.find(tenant)
  machines = Machine.where(id: machine)
  shift = tenant.shift.shifttransactions.find_by(shift_no: shift_no)
 
	  #shift = Shifttransaction.current_shift(tenant.id)

		# if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		#   if Time.now.strftime("%p") == "AM"
		# 	date = (Date.today - 1).strftime("%Y-%m-%d")
		#   end 
		#   start_time = (date+" "+shift.shift_start_time).to_time
		#   end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		# elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")            
		#   if Time.now.strftime("%p") == "AM"
		# 	date = (Date.today - 1).strftime("%Y-%m-%d")
		#   end

		#   if shift.day == 1
	 #       start_time = (date+" "+shift.shift_start_time).to_time
	 #       end_time = (date+" "+shift.shift_end_time).to_time
	 #     else
	 #       start_time = (date+" "+shift.shift_start_time).to_time+1.day
	 #       end_time = (date+" "+shift.shift_end_time).to_time+1.day
	 #     end
		#  # start_time = (date+" "+shift.shift_start_time).to_time+1.day
		#   #end_time = (date+" "+shift.shift_end_time).to_time+1.day
		# else              
		#   start_time = (date+" "+shift.shift_start_time).to_time
		#   end_time = (date+" "+shift.shift_end_time).to_time        
		# end


     if tenant.id != 31 || tenant.id != 10
		if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end 
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")           
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end
		  if shift.day == 1
           start_time = (date+" "+shift.shift_start_time).to_time
           end_time = (date+" "+shift.shift_end_time).to_time
         else
           start_time = (date+" "+shift.shift_start_time).to_time+1.day
           end_time = (date+" "+shift.shift_end_time).to_time+1.day
         end
		 # start_time = (date+" "+shift.shift_start_time).to_time+1.day
		 # end_time = (date+" "+shift.shift_end_time).to_time+1.day
		else              
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time        
		end
	else
		case
      when shift.day == 1 && shift.end_day == 1   
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time  
      when shift.day == 1 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day    
      else
        start_time = (date+" "+shift.shift_start_time).to_time+1.day
        end_time = (date+" "+shift.shift_end_time).to_time+1.day     
      end
	end

         
		 machines.order(:id).map do |mac|
		  	
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
			
			if shift.operator_allocations.where(machine_id:mac.id).last.nil?
			  operator_id = nil
			else
			  if shift.operator_allocations.where(machine_id:mac.id).present?
				shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
				  aa = ro.from_date
				  bb = ro.to_date
				  cc = date
				  if cc.to_date.between?(aa.to_date,bb.to_date)  
					dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
					if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
					  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
					else
					  operator_id = nil
					end              
				  end
				end
			  else
				operator_id = nil
			  end
			end
			job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
			duration = end_time.to_i - start_time.to_i
			new_parst_count = Machine.new_parst_count(machine_log1)
			run_time = Machine.run_time(machine_log1)
			stop_time = Machine.stop_time(machine_log1)
			ideal_time = Machine.ideal_time(machine_log1)
			cycle_time = Machine.cycle_time(machine_log1)
			start_cycle_time = Machine.start_cycle_time(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)		
			utilization =(run_time*100)/duration if duration.present?

			

    #  total_count = []
    #  short_value = machine_log1.where(machine_status: 3).where.not(parts_count: -9).pluck(:programe_number, :parts_count).uniq
    #  if short_value.present? 
    #   short_value.each do |val|

    #     data = machine_log1.find_by(parts_count: val[1], machine_status: 3, programe_number: val[0])
    #     if machine_log1.where(parts_count: data.parts_count, machine_status: 3, programe_number: data.programe_number).last.created_at.to_i == data.machine.machine_daily_logs.where(parts_count: data.parts_count, machine_status: 3, programe_number: data.programe_number).last.created_at.to_i
    #         total_count << val[1]
    #       end
    #   end
    # end



			@alldata << [
			  date,
			  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
			  duration,
			  shift.shift.id,
			  shift.shift_no,
			  operator_id,
			  mac.id,
			  job_description.nil? ? "-" : job_description.split(',').join(" & "),
			  new_parst_count,
			  run_time,
			  ideal_time,
			  stop_time,
			  time_diff,
			  count,
			  utilization,
			  tenant.id,
			  cycle_time,
			  start_cycle_time
			  ]
			  
		  end
       @alldata.each do |data|
		# if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
		#   CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
		# else
		# 	puts "Wrong Data"
		#   #CncHourReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], ideal_time: data[10], stop_time: data[11], time_diff: data[12], log_count: data[13], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16])
		# end
  end
end





  def self.cnc_report1
  
  date = Date.today.strftime("%Y-%m-%d")
  #tenants = Tenant.where(isactive: true).ids
  #date="2018-08-31"
  tenants = Tenant.where(id: [8]).ids
  @alldata = []
  tenants.each do |tenant|
	tenant = Tenant.find(tenant)
	machines = tenant.machines
	#shifts = tenant.shift.shifttransactions.ids
	#shifts.each do |shift_id|
	  shift = Shifttransaction.find(4)
	 #shift = Shifttransaction.current_shift(tenant.id)

		# if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		#   if Time.now.strftime("%p") == "AM"
		# 	date = (Date.today - 1).strftime("%Y-%m-%d")
		#   end 
		#   start_time = (date+" "+shift.shift_start_time).to_time
		#   end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		# elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")           
		#   if Time.now.strftime("%p") == "AM"
		# 	date = (Date.today - 1).strftime("%Y-%m-%d")
		#   end
		#   if shift.day == 1
  #          start_time = (date+" "+shift.shift_start_time).to_time
  #          end_time = (date+" "+shift.shift_end_time).to_time
  #        else
  #          start_time = (date+" "+shift.shift_start_time).to_time+1.day
  #          end_time = (date+" "+shift.shift_end_time).to_time+1.day
  #        end
		#   #start_time = (date+" "+shift.shift_start_time).to_time+1.day
		#   #end_time = (date+" "+shift.shift_end_time).to_time+1.day
		# else 
		               
		#   start_time = (date+" "+shift.shift_start_time).to_time
		#   end_time = (date+" "+shift.shift_end_time).to_time        
		# end
	  #if start_time < Time.now && end_time > Time.now
		
    
     if tenant.id != 31 || tenant.id != 10
		if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end 
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")           
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end
		  if shift.day == 1
           start_time = (date+" "+shift.shift_start_time).to_time
           end_time = (date+" "+shift.shift_end_time).to_time
         else
           start_time = (date+" "+shift.shift_start_time).to_time+1.day
           end_time = (date+" "+shift.shift_end_time).to_time+1.day
         end
		 # start_time = (date+" "+shift.shift_start_time).to_time+1.day
		 # end_time = (date+" "+shift.shift_end_time).to_time+1.day
		else              
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time        
		end
	else
		case
      when shift.day == 1 && shift.end_day == 1   
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time  
      when shift.day == 1 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day    
      else
        start_time = (date+" "+shift.shift_start_time).to_time+1.day
        end_time = (date+" "+shift.shift_end_time).to_time+1.day     
      end
	end



		  machines.order(:id).map do |mac|
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
			if shift.operator_allocations.where(machine_id:mac.id).last.nil?
			  operator_id = nil
			else
			  if shift.operator_allocations.where(machine_id:mac.id).present?
				shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
				  aa = ro.from_date
				  bb = ro.to_date
				  cc = date
				  if cc.to_date.between?(aa.to_date,bb.to_date)  
					dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
					if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
					  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
					else
					  operator_id = nil
					end              
				  end
				end
			  else
				operator_id = nil
			  end
			end
			
			job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
			duration = end_time.to_i - start_time.to_i
			new_parst_count = Machine.new_parst_count(machine_log1)
			run_time = Machine.run_time(machine_log1)
			stop_time = Machine.stop_time(machine_log1)
			ideal_time = Machine.ideal_time(machine_log1)
			cycle_time = Machine.cycle_time(machine_log1)
			start_cycle_time = Machine.start_cycle_time(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)

			utilization =(run_time*100)/duration if duration.present?
			
			data = [
			  date,
			  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
			  duration,
			  shift.shift.id,
			  shift.shift_no,
			  operator_id,
			  mac.id,
			  job_description.nil? ? "-" : job_description.split(',').join(" & "),
			  new_parst_count,
			  run_time,
			  ideal_time,
			  stop_time,
			  time_diff,
			  count,
			  utilization,
			  tenant.id,
			  cycle_time,
			  start_cycle_time
			  ]
			  
		  #end
            if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
	          CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start: data[17])
	        else
	       	  CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
	        end
        end
		end
	 
	
  #end
  # if @alldata.present?
  #   @alldata.each do |data|
  #     if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
	 #    CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start: data[17])
	 #  else
	   


  #   #     if CncReport.where(machine_id:data[6], tenant_id:data[15]).present?
		#   # if data[4] == 1
		#   #   shift = Tenant.find(data[15]).shift.shifttransactions.last.shift_no
		#   #   date = Date.yesterday.strftime("%Y-%m-%d")
		#   # else
		#   #   shift = data[4] - 1
  #   #         date = data[0]
		#   # end
		#   # byebug
	 #   #    cnc_last_report = CncReport.last_shift_report(date, data[6], data[15], shift)
  #   #      end
        
		# CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
	 #  end
  #   end
  # end 
end







def self.cnc_report_speed
	tenants = Tenant.where(id: 8)
  tenants.each do |tenant|
  
  date = Date.today.strftime("%Y-%m-%d")
  @alldata = []
	tenant = Tenant.find(tenant.id)
	machines = tenant.machines.where.not(controller_type: 3)
	#shift = tenant.shift.shifttransactions.where(shift_no: shift_no).last
	shift = Shifttransaction.current_shift(tenant.id)	
	if tenant.id != 31 || tenant.id != 10
		if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end 
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
		elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")           
		  if Time.now.strftime("%p") == "AM"
			date = (Date.today - 1).strftime("%Y-%m-%d")
		  end
		  if shift.day == 1
           start_time = (date+" "+shift.shift_start_time).to_time
           end_time = (date+" "+shift.shift_end_time).to_time
         else
           start_time = (date+" "+shift.shift_start_time).to_time+1.day
           end_time = (date+" "+shift.shift_end_time).to_time+1.day
         end
		 # start_time = (date+" "+shift.shift_start_time).to_time+1.day
		 # end_time = (date+" "+shift.shift_end_time).to_time+1.day
		else              
		  start_time = (date+" "+shift.shift_start_time).to_time
		  end_time = (date+" "+shift.shift_end_time).to_time        
		end
	else
		case
      when shift.day == 1 && shift.end_day == 1   
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time  
      when shift.day == 1 && shift.end_day == 2
        start_time = (date+" "+shift.shift_start_time).to_time
        end_time = (date+" "+shift.shift_end_time).to_time+1.day    
      else
        start_time = (date+" "+shift.shift_start_time).to_time+1.day
        end_time = (date+" "+shift.shift_end_time).to_time+1.day     
      end
	end

		  machines.order(:id).map do |mac|
			machine_log1 = mac.machine_daily_logs.where("created_at >= ? AND created_at <= ?",start_time,end_time).order(:id)
			if shift.operator_allocations.where(machine_id:mac.id).last.nil?
			  operator_id = nil
			else
			  if shift.operator_allocations.where(machine_id:mac.id).present?
				shift.operator_allocations.where(machine_id:mac.id).each do |ro| 
				  aa = ro.from_date
				  bb = ro.to_date
				  cc = date
				  if cc.to_date.between?(aa.to_date,bb.to_date)  
					dd = ro#cc.to_date.between?(aa.to_date,bb.to_date)
					if dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.present?
					  operator_id = dd.operator_mapping_allocations.where(:date=>date.to_date).last.operator.id 
					else
					  operator_id = nil
					end              
				  end
				end
			  else
				operator_id = nil
			  end
			end

			job_description = machine_log1.pluck(:job_id).uniq.reject{|i| i.nil? || i == ""}
			duration = end_time.to_i - start_time.to_i
			new_parst_count = Machine.new_parst_count(machine_log1)
			run_time = Machine.run_time(machine_log1)
			stop_time = Machine.stop_time(machine_log1)
			ideal_time = Machine.ideal_time(machine_log1)
						
      if mac.controller_type == 2
        cycle_time = Machine.rs232_cycle_time(machine_log1)	
      else
			  #cycle_time = Machine.cycle_time(machine_log1)
			  cycle_time = Machine.cycle_time22(machine_log1)
      end      
			start_cycle_time = Machine.start_cycle_time(machine_log1)
			count = machine_log1.count
			time_diff = duration - (run_time+stop_time+ideal_time)
			utilization =(run_time*100)/duration if duration.present?
			
			@alldata << [
			  date,
			  start_time.strftime("%H:%M:%S")+' - '+end_time.strftime("%H:%M:%S"),
			  duration,
			  shift.shift.id,
			  shift.shift_no,
			  operator_id,
			  mac.id,
			  job_description.nil? ? "-" : job_description.split(',').join(" & "),
			  new_parst_count,
			  run_time,
			  ideal_time,
			  stop_time,
			  time_diff,
			  count,
			  utilization,
			  tenant.id,
			  cycle_time,
			  start_cycle_time
			  ] 
		  end
		end
  #end
  
  if @alldata.present?
    @alldata.each do |data|
      if CncReport.where(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).present?
	    CncReport.find_by(date:data[0],shift_no: data[4], time: data[1], machine_id:data[6], tenant_id:data[15]).update(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start: data[17])
	  else    
		CncReport.create!(date:data[0], time: data[1], hour: data[2], shift_id: data[3], shift_no: data[4], operator_id: data[5], machine_id: data[6], job_description: data[7], parts_produced: data[8], run_time: data[9], idle_time: data[10], stop_time: data[11], time_diff: data[12], utilization: data[14],  tenant_id: data[15], all_cycle_time: data[16], cycle_start_to_start:data[17])
	  end
    end
  end 
end



end


