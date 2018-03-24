require 'yaml'

class Hangman
	attr_accessor :secret_word, :secret_word_compare, :guessed_letters, :clue, :misses_left, :player

	def initialize(player)
		@player = player
		@secret_word = generate_secret_word
		@secret_word_compare = @secret_word.chars
		@guessed_letters = Hash.new(26)
		('a'..'z').each { |letter| @guessed_letters[letter] = false}
		@clue = Array.new(@secret_word.length)
		@misses_left = 6
	end

	# Selects a random secret word from included list of terms
	def generate_secret_word
		dictionary = File.readlines("files/5desk.txt")
		word_count = dictionary.length
		secret_word = ""
		loop do
			secret_word = dictionary[Random.rand(word_count)].chomp
			break if secret_word.length >= 5 && secret_word.length <= 12
		end
		secret_word.downcase
	end

	# One complete player turn, with save option
	def player_turn
		puts "Incorrect guesses left: #{@misses_left}"
		puts
		print_clue
		puts
		guess = get_guess
		if guess == "1"
			save_file
			exit
		end
		@guessed_letters[guess] = true
		puts
		match_letters(guess)
	end

	# The clue is printed, with blanks for missing letters
	def print_clue
		@clue.each do |letter| 
			print letter || '_'
			print " "
		end
		print "\n\n"
	end

	# Asks player for a letter and validates input; "1" is flag for save
	def get_guess
		begin
			print "Guess a letter (or press '1' to save and quit): "
			guess = gets.chomp.downcase
			raise ArgumentError if guess.empty? || guess.length > 1 || (!(guess =~ /[[:alpha:]]/) && guess != "1")
			raise DuplicateGuessError if @guessed_letters[guess] unless guess == "1"
		rescue DuplicateGuessError
			puts "You have already guessed the letter '#{guess}'."
			puts
			retry
		rescue ArgumentError
			puts "Please guess a single letter only!"
			puts
			retry
		end
		guess
	end

	# Finds matches in clue and fills in values; decreases @misses_left counter if guess is incorrect
	def match_letters(guess)
		incorrect_guess = true
		@secret_word_compare.each_with_index do |letter, index|
			if letter == guess
				@clue[index] = guess
				incorrect_guess = false
			end
		end
		@misses_left -= 1 if incorrect_guess
	end

	# Returns true if the player has won
	def win?
		@clue.each { |letter| return false if !letter }
		true
	end

	# Returns true if the player has lost
	def lose?
		(@misses_left == 0 && !win?) ? true : false
	end

	# At the start of the game, determines whether the player want to load a save file
	def self.load_game?
		return false if !File.exists?("files/savefile.sav")
		begin
			puts "Enter '1' to start a new game or '2' to load a save file: "
			start_option = gets.chomp
			raise ArgumentError if start_option != '1' && start_option != '2'
		rescue
			puts
			puts "Invalid selection!"
			retry
		end
		start_option == '2' ? true : false
	end

	#Saves current game and ends session
	def save_file
		save_file = File.open('files/savefile.sav', 'w')
		save_file.write(self.to_yaml)
		save_file.close

		puts
		puts "Thank you for playing, #{@player.name}!"
	end

	# Displays list of save files and loads the file selected by the player
	def self.load_save
		save_file = File.open('files/savefile.sav', 'r')
		YAML.load(save_file)
	end
end

class DuplicateGuessError < ArgumentError

end

class Player
	attr_accessor :name, :wins, :losses, :total

	def initialize(name, wins, losses, total)
		@name = name
		@wins = wins
		@losses = losses
		@total = total
	end

	# Returns the name of a new player
	def self.get_name
		begin
			print "Please enter your name: "
			name = gets.chomp
			puts
			raise ArgumentError if !name || name.empty?
		rescue
			retry
		end

		puts

		name
	end
end

first_game = true
game = ""
loop do
	if first_game
		game = Hangman.load_game? ? Hangman.load_save : Hangman.new(Player.new(Player.get_name, 0, 0, 0))

		puts "Welcome to Hangman, #{game.player.name}!"
	else
		game = Hangman.new(game.player)
	end

	puts
		while !game.win? && !game.lose?
			game.player_turn
	end
	puts

	if game.win?
		puts "You win!"
		game.player.wins += 1
	else
		puts "You lose!"
		game.player.losses += 1
	end
	game.player.total += 1

	puts
	puts "The secret word is #{game.secret_word}."
	puts

	puts "You currently have #{game.player.wins} wins and #{game.player.losses} losses out of #{game.player.total} games."
	puts
	begin
		print "Do you want to play again? (y/n): "
		play_again = gets.chomp.downcase
		puts
		raise ArgumentError if play_again != "y" && play_again != "n" && play_again != "yes" && play_again != "no"
	rescue
		retry
	end

	if play_again == "n" || play_again == "no"
		begin
			print "Would you like to save the game? (y/n): "
			save = gets.chomp.downcase
			puts
		raise ArgumentError if save != "y" && save != "n" && save != "yes" && save != "no"
		rescue
			retry
		end
		if save == "y" || save == "yes"
			game = Hangman.new(game.player)
			game.save_file
		end
		break
	end
	first_game = false	
end