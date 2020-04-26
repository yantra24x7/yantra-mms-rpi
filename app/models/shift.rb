class Shift < ApplicationRecord
	acts_as_paranoid
  has_many :shifttransactions,:dependent => :destroy
  belongs_to :tenant
  has_many :reports
  has_many :hour_reports
  has_many :cnc_hour_reports
  has_many :cnc_reports
  has_many :program_reports
  has_many :ct_reports

  def self.get_all_shift(params)
  	shifts=Tenant.find(params[:tenant_id]).shift.shifttransactions
  	return shifts
  end



def self.check_shift_time22
    @data = []
    date = "2018-08-29"
    tenants = Tenant.where(id: 31)
    tenants.each do |tenant|
      shifts = tenant.shift.shifttransactions
      shifts.each do |shift|
        # if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
        #   if Time.now.strftime("%p") == "AM"
        #     date = (date.to_date - 1.day).strftime("%Y-%m-%d")
        #   end 
        #   start_time = (date+" "+shift.shift_start_time).to_time
        #   end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
        # elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")
        #   if shift.shift.shift_start_time > Time.now           
        #   if Time.now.strftime("%p") == "AM"
        #     date = (date.to_day - 1.day).strftime("%Y-%m-%d")
        #   end
        #   start_time = (date+" "+shift.shift_start_time).to_time+1.day
        #   end_time = (date+" "+shift.shift_end_time).to_time+1.day
        # else              
        #   start_time = (date+" "+shift.shift_start_time).to_time
        #   end_time = (date+" "+shift.shift_end_time).to_time        
        # end
        
      
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
       else              
         start_time = (date+" "+shift.shift_start_time).to_time
         end_time = (date+" "+shift.shift_end_time).to_time        
       end
       puts start_time
       puts end_time
     
      #   @data << {
      #          tenant: tenant.tenant_name,
      #          shift: shift.shift_no,
      #          sh_time: shift.shift_start_time+'-'+shift.shift_end_time,
      #          time: start_time.to_time.strftime("%Y-%m-%d || %H:%M:%S")+'------'+end_time.to_time.strftime("%Y-%m-%d || %H:%M:%S")
      #             }
      # #end

    end
    #ShiftCheckingMailer.check_time(@data).deliver_now
  end

end

 def self.check_shift_time
    @data = []
    date = "2018-10-10"
    tenants = Tenant.where(id: [1, 3, 8, 10, 31])
    tenants.each do |tenant|
      shifts = tenant.shift.shifttransactions
      shifts.each do |shift|

        #byebug
        # if shift.shift_start_time.include?("PM") && shift.shift_end_time.include?("AM")
        #   if Time.now.strftime("%p") == "AM"
        #     date = (date.to_date - 1.day).strftime("%Y-%m-%d")
        #   end 
        #   start_time = (date+" "+shift.shift_start_time).to_time
        #   end_time = (date+" "+shift.shift_end_time).to_time+1.day                             
        # elsif shift.shift_start_time.include?("AM") && shift.shift_end_time.include?("AM")
        #   if shift.shift.shift_start_time > Time.now           
        #   if Time.now.strftime("%p") == "AM"
        #     date = (date.to_day - 1.day).strftime("%Y-%m-%d")
        #   end
        #   start_time = (date+" "+shift.shift_start_time).to_time+1.day
        #   end_time = (date+" "+shift.shift_end_time).to_time+1.day
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
              start_time = (date+" "+shift.shift_start_time).to_time+1.day
              end_time = (date+" "+shift.shift_end_time).to_time+1.day
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
   
        @data << {
               tenant: tenant.tenant_name,
               shift: shift.shift_no,
               sh_time: shift.shift_start_time+'-'+shift.shift_end_time,
               time: start_time.to_time.strftime("%Y-%m-%d || %H:%M:%S")+'------'+end_time.to_time.strftime("%Y-%m-%d || %H:%M:%S")
                  }
      end
    #end
    
  end
  
   ShiftCheckingMailer.check_time(@data).deliver_now
end





end
