class Device < ApplicationRecord
	 acts_as_paranoid
	has_many :device_mappings
end
