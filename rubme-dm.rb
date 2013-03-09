require 'sinatra'
require './RubMeModel'

enable :sessions

# database file not used here, going to be set in ./config
database_file = settings.environment.to_s + ".db"

# helper methods
helpers do
	def to_javascript_array(array)
		jsArray = "'[\"#{array.join('", "')}\"]'"
	end

	def remove_whitespace(string)
		string.gsub(/\s+/, "")
	end

	def titlecase(string)
		string.split(' ').each{|word| word.capitalize!}.join(' ')
	end

	def format_timestamp(datetime)
		datetime.strftime("On %B %e, %Y at %l:%M%P")
	end
end

get "/" do
	
	schools = School.all
	
	schools_array = []
	schools.each do |school|
		entry = "%s" % [school.name]
		#entry = "%s (%s, %s)" % [school["name"], school["city"], school["state"]]
		schools_array.push(entry)
	end
	@js_schools_array = to_javascript_array(schools_array)
	erb File.read("erb/home.erb")
end

post "/" do
	# put school and target field values into titlecase for database lookup and display
	school_name = titlecase(params["school"])
	target_name = titlecase(params["target"])
	
	
	# if school isn't in database (school_id array is empty)
	# take user to /createschool
	#schools = db.execute("SELECT * FROM schools WHERE schools.name = ?", school_name)
	schools = School.all(name: school_name)
	if schools.length == 1
		# if school exists and there's only one
		school = schools.first
		
		# find first target matching name and school, or create new one
		target = Target.first_or_create(name: target_name, school: school)

		# ALL THIS CODE GOES AWAY!
		# target = db.execute("SELECT * FROM targets
		# 							WHERE targets.name = ?
		# 							AND targets.school_id = ?",
		# 							target_name, school["id"]).first
		# if target.nil?	
		# 	# target name must be unique within school, so insert with school_id
		# 	db.execute("INSERT INTO targets (name, school_id) VALUES(?, ?)",
		# 		target_name, school["id"])
		# 	# run select statement again to get the new target out of the database
		# 	target = db.execute("SELECT * FROM targets
		# 							WHERE targets.name = ?
		# 							AND targets.school_id = ?",
		# 							target_name, school["id"]).first
		# end

		# # get timestamp as seconds since epoch
		# TIMESTAMP TAKEN CARE OF IN DATAMAPPER BY DM-TIMESTAMPS MAGIC
		# timestamp = Time.now.to_i

		# TODO: validate that message is not empty...
		Message.create(body: params["message"], target: target, school: school)

		# insert message into messages table
		# db.execute("INSERT INTO messages
		# 			(target_id, school_id, message, timestamp, likes)
		# 			VALUES (?, ?, ?, ?, ?)", target["id"], school["id"], params["message"], timestamp, 0)
		
		# redirect to school's page
		redirect to("/school/#{school["id"]}/recent")

	elsif schools.empty? || schools.length > 1 
		# redirect to search of schools with query string
		# if school doesn't exist or there are multiple schools
		# session["target"] = target_name
		# session["message"] = 
		redirect to("/create/school")
	end


end

# create school
#TODO: in future figure out how to remove global variables, and replace with Rack 'call' methods
get "/create/school" do
	erb File.read("erb/create_school.erb")
end

post "/create/school" do
	school_name = titlecase(params["school"])

	school = School.create(name: school_name, zipcode: params["zipcode"])

	# db.execute("INSERT INTO schools (name, zipcode) VALUES(?, ?)",
	# 	school_name, params["zipcode"])

	# school = db.execute("SELECT * FROM schools WHERE name = ? AND zipcode = ?",
	# 	school_name, params["zipcode"]).first
	# redirect to school's recent feed
	redirect to("/school/#{school.id}/recent")
end

get "/school/:school_id/recent" do
	
	@school = School.get(params["school_id"])

	# @school = db.execute("SELECT * FROM
	# 	schools WHERE schools.id = ?", params["school_id"]).first

	if !@school.nil? # if school is not nil
		# the left outer join returns rows on the left even if they don't match any comments on the right
		# @messages = db.execute("SELECT messages.id, messages.message, messages.timestamp, messages.likes,
		# 						targets.name target_name, schools.name school_name
		# 						FROM messages 
		# 						JOIN targets ON targets.id = messages.target_id
		# 						JOIN schools ON schools.id = messages.school_id
		# 						LEFT OUTER JOIN comments ON comments.message_id = messages.id
		# 						WHERE schools.id = ?
		# 						ORDER BY messages.timestamp DESC", params["school_id"])
	
		# use :order to specify descending timestamp order
		@messages = Message.all(school: @school, order: [:created_at.desc])

		erb File.read("erb/school_page.erb")
	else
		# otherwise, school is nil and it isn't in database so id is invalid
		erb File.read("erb/school_not_found.erb")
	end

end

get "/school/:school_id/trending" do
	@school = School.get(params["school_id"])

	# @school = db.execute("SELECT * FROM
	# 	schools WHERE schools.id = ?", params["school_id"]).first

	if !@school.nil? # if school is not nil
		# the left outer join returns rows on the left even if they don't match any comments on the right
		# @messages = db.execute("SELECT messages.id, messages.message, messages.timestamp, messages.likes,
		# 						targets.name target_name, schools.name school_name
		# 						FROM messages 
		# 						JOIN targets ON targets.id = messages.target_id
		# 						JOIN schools ON schools.id = messages.school_id
		# 						LEFT OUTER JOIN comments ON comments.message_id = messages.id
		# 						WHERE schools.id = ?
		# 						ORDER BY messages.likes DESC", params["school_id"])
	
		# use :order to specify descending like count
		@messages = Message.all(school: @school, order: [:likes.desc])

		erb File.read("erb/school_page.erb")
	else
		# otherwise, school is nil and it isn't in database so id is invalid
		erb File.read("erb/school_not_found.erb")
	end

end

get "/search" do
	#school_name = titlecase(params["school"])
	school_name = params["school"]
	# like creates case insensitivity
	# @results = db.execute("SELECT * FROM schools WHERE schools.name LIKE ?", school_name)

	# .like equivalent to SQL LIKE, creates
	# case insensitivity
	@results = School.all(:name.like => school_name)

	# puts "seach results: " + @results.inspect
	erb File.read("erb/search.erb")
end

get "/about" do
	erb File.read("erb/aboutme.erb")
end

get "/like/:message_id" do
	message = Message.get(params["message_id"])

	if !message.nil?
		# if message exists, increment likes by 1 [update() saves automatically]
		message.update(likes: message.likes + 1)
	else
		erb File.read("erb/message_not_found.erb")
	end

	# TODO: provide return url for redirection

	# message = db.execute("SELECT messages.id, messages.message, messages.likes, schools.url_name FROM
	# 	messages JOIN schools ON schools.id = messages.school_id
	# 	WHERE messages.id = ?", params["message_id"]).first
	#puts "message: " + message["message"] + "id: " + message["id"].to_s
	#puts "inspected message: " + message.inspect
	#db.execute("UPDATE messages SET likes = ? WHERE messages.id = ?", message["likes"]+1, message["id"])
	#redirect to("/#{message["url_name"]}/recent")
end