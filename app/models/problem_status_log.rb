class ProblemStatusLog < ApplicationRecord
  belongs_to :tenant

  def self.test
  roles = SetAlarmSetting.all#.all#with_deleted
   ExternalUser.all.each_with_index do |val, ind|
   
   if roles[ind].present?
     if val.attributes == roles[ind].attributes
       puts "Alredy Have The Record"
     else
       if SetAlarmSetting.where(id: val.attributes["id"]).present?
        puts "Record Need To Change"
       else
         puts "Need To Create"
       end
      end
    else
     puts "No Record"
    end
   end   
  end






  def self.test1
   a = []
   ExternalUser.all.each_with_index do |val, ind|
    if SetAlarmSetting.where(id: val.attributes['id']).present?
     SetAlarmSetting.find(val.attributes['id']).update(val.attributes)
     puts "Yes"
    a << val
   #  roles.pop#(Role.new(val.attributes))
    else
     puts "No"
      SetAlarmSetting.create(val.attributes)
    end
   end
  end



end
