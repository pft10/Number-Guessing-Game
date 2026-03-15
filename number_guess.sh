#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
 
# Generate a random number while keeping the game fast enough for the test harness.
SECRET_NUMBER=$(( RANDOM % 100 + 1 ))
 
# Ask for username
echo "Enter your username:"
read USERNAME
 
# Look up user in database
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
 
if [[ -z $USER_ID ]]; then
  # New user
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Existing user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
 
# Get user_id (may have just been created)
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
 
# Guessing loop
NUM_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
 
while true; do
  read GUESS
 
  # Check if guess is an integer
  if ! [[ $GUESS =~ ^-?[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi
 
  (( NUM_GUESSES++ ))
 
  if (( GUESS < SECRET_NUMBER )); then
    echo "It's higher than that, guess again:"
  elif (( GUESS > SECRET_NUMBER )); then
    echo "It's lower than that, guess again:"
  else
    # Correct guess - save game and exit
    INSERT_GAME=$($PSQL "INSERT INTO games(user_id, guesses) VALUES($USER_ID, $NUM_GUESSES)")
    echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done
