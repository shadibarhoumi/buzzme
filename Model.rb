require 'dm-core'
require 'data_mapper'
require 'dm-adjust'

DataMapper.setup(:default, "sqlite://#{Dir.pwd}/development.db")

class Target
	include DataMapper::Resource

	property :id, Serial

	property :name, String, required: true

	has n, :messages

	belongs_to :school

end

class Message
	include DataMapper::Resource

	property :id, Serial
	property :created_at, 	DateTime

	property :body, Text, required: true
	property :likes, Integer, default: 0

	has n, :comments

	belongs_to :school
	belongs_to :target
end

class Comment
	include DataMapper::Resource

	property :id, Serial
	property :created_at, DateTime

	property :body, Text, required: true, length: 10..500

	belongs_to :message
end

class School
	include DataMapper::Resource
	
	property :id, Serial

	property :name, String, required: true
	property :zipcode, Integer, required: true

	has n, :targets
	has n, :messages
end

DataMapper.finalize
DataMapper.auto_upgrade!