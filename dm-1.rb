require 'dm-core'

class Target
	include DataMapper::Resource

	property :id, Serial

	property :name, String, required: true

	has n, :messages

	belongs_to, :school

end