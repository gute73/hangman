class Hangman
	def initialize(player)
		@player = player
		@secret_word = generate_secret_word
		@guessed_letters = Hash.new(26)
		['a'..'z'].each { |letter| @guessed_letters[letter] = false}
		puts @secret_word
	end

	# Selects a random secret word from included list of terms
	def generate_secret_word
		dictionary = File.readlines("files/5desk.txt")
		word_count = dictionary.length
		secret_word = ""
		loop do
			secret_word = dictionary[Random.rand(word_count)]
			break if secret_word.length >= 5 && secret_word.length <= 12
		end
		secret_word
	end
end

class Player
	def initialize
		puts "Welcome to Hangman!"
		begin
			print "Please enter a username: "
			@username = gets.chomp
			raise ArgumentError if username_invalid?
		rescue
			puts "The username that you entered is invalid. Please choose a username that begins with a letter and is from 4 to 20 characters long."
			retry
		end

		begin
			print "Please enter a password: "
			@password = gets.chomp
			raise ArgumentError if password_invalid?
		rescue
			retry
		end

		@wins = 0
		@losses = 0
	end

	# Returns true if username is blank, is less than 4 characters, is greater than 20 characters, or begins with a non-alphabetic character 
	def username_invalid?
		if @username.empty? || !@username || @username.length < 4 || @username.length > 20 || !(@username[0] =~ /[[:alpha:]]/) || @username =~ /\s/
			true
		else
			false
		end
	end

	# Returns true if password is blank
	def password_invalid?
		return true if @password.empty? || !@password || @password =~ /\s/
		false
	end
end

player = Player.new
game = Hangman.new(player)
