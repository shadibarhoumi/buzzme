require 'sinatra'
require './Model'

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
	
	erb :home
end

post "/" do
	# put school and target field values into titlecase for database lookup and display
	school_name = titlecase(params["school"])
	target_name = titlecase(params["target"])

	schools = School.all(name: school_name)
	if schools.length == 1
		# if school exists and there's only one
		school = schools.first
		
		# find first target matching name and school, or create new one
		target = Target.first_or_create(name: target_name, school: school)

		# TODO: validate that message is not empty...
		Message.create(body: params["message"], target: target, school: school)

		# redirect to school's page
		redirect to("/school/#{school["id"]}/recent")

	elsif schools.empty? || schools.length > 1 
		# if school doesn't exist or there are multiple schools
		# TODO: redirect to search of schools with query string
		redirect to("/create/school")
	end


end

get "/create/school" do
	erb :create_school
end

post "/create/school" do
	school_name = titlecase(params["school"])

	school = School.create(name: school_name, zipcode: params["zipcode"])

	# redirect to school's recent feed
	redirect to("/school/#{school.id}/recent")
end

# handle trending and recent routes in one go!
get "/school/:school_id/:sort" do

	@school = School.get(params["school_id"])

	if !@school.nil? # if school is not nil
	
		if params["sort"] == "recent"
			# use :order to specify descending timestamp order
			@messages = Message.all(school: @school, order: [:created_at.desc])
		elsif params["sort"] == "trending"
			# use :order to specify descending like count
			@messages = Message.all(school: @school, order: [:likes.desc])
		end

		erb :school_page
	else
		# otherwise, school is nil and it isn't in database so id is invalid
		erb :not_found
	end
end

get "/feed" do
	@messages = Message.all(order: [:created_at.desc])
	
	erb :all_school_feed
end

post "/school/:school_id/*" do
	
	school = School.get(params["school_id"])
	target_name = titlecase(params["target"])
		
	# find first target matching name and school, or create new one
	target = Target.first_or_create(name: target_name, school: school)

	# TODO: validate that message is not empty...
	Message.create(body: params["message"], target: target, school: school)

	redirect to("/school/#{params["school_id"]}/recent")
end

get "/target/:target_id/:sort" do

	@target = Target.get(params["target_id"])

	if !@target.nil?
		
		@school = @target.school

		if params["sort"] == "recent"
			@messages = Message.all(target: @target, order: [:created_at.desc])
		elsif params["sort"] == "trending"
			@messages = Message.all(target: @target, order: [:likes.desc])
		end

		erb :target_page
	else
		erb :not_found
	end
end

post "/target/:target_id/*" do

	target = Target.get(params["target_id"])
	
	message = Message.create(target: target, body: params["message"], school: target.school)

	redirect to("/target/#{target.id}/recent")
end

get "/search" do
	school_name = params["school"]

	# .like equivalent to SQL LIKE, creates case insensitivity
	@results = School.all(:name.like => school_name)

	erb :search
end

get "/about" do
	erb :aboutme
end

post "/like/:message_id" do
	message = Message.get(params["message_id"])

	if !message.nil?
		# if message exists, increment likes by 1 [update() saves automatically]
		message.update(likes: message.likes + 1)

		if request.xhr?
			return message.likes.to_s
		else
			# redirect using return url in form
			redirect to(params["return"])
		end
	else
		erb :not_found
	end
end