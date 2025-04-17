#!/bin/bash

PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"

# A script that generates a random number that users have to guess

# get username
echo "Enter your username:"
read USERNAME

# get username from database
EXISTING_USERNAME=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")

# if username does not exist
if [[ -z $EXISTING_USERNAME ]]; then
    # store new username to database
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    # get existing info of username
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$EXISTING_USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$EXISTING_USERNAME'")
    # Format singular or plural
    GAME_GAMES=$(if [[ $GAMES_PLAYED -eq 1 ]]; then echo "game"; else echo "games"; fi)
    GUESS_GUESSES=$(if [[ $BEST_GAME -eq 1 ]]; then echo "guess"; else echo "guesses"; fi)

    echo "Welcome back, $EXISTING_USERNAME! You have played $GAMES_PLAYED $GAME_GAMES, and your best game took $BEST_GAME $GUESS_GUESSES."
fi

# generate random number from 1 to 1000
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo $SECRET_NUMBER

# initialize counter
ATTEMPTS=0

# guess the number
echo "Guess the secret number between 1 and 1000:"
read NUMBER

while true; do

    # if input is not an integer
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
    # if guessed number is lower
    elif ((NUMBER < SECRET_NUMBER)); then
        echo "It's higher than that, guess again:"
    # if guessed number is higher
    elif ((NUMBER > SECRET_NUMBER)); then
        echo "It's lower than that, guess again:"
    # if input is successful
    else

        # increment number of tries
        ((ATTEMPTS++))

        # get username id
        USERNAME_ID=$($PSQL "SELECT username_id FROM players WHERE username='$USERNAME' OR username='$EXISTING_USERNAME'")
        # insert new game result
        INSERT_GAME_RESULT=$($PSQL "INSERT INTO game_history(username_id, attempts) VALUES($USERNAME_ID, $ATTEMPTS)")
        # get count of games played
        GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM game_history WHERE username_id=$USERNAME_ID")
        # insert games played
        INSERT_GAMES_PLAYED_RESULT=$($PSQL "UPDATE players SET games_played=$GAMES_PLAYED WHERE username_id=$USERNAME_ID")
        # get best game
        BEST_GAME=$($PSQL "SELECT MIN(attempts) FROM game_history WHERE username_id=$USERNAME_ID")
        # insert best game
        INSERT_BEST_GAME_RESULT=$($PSQL "UPDATE players SET best_game=$BEST_GAME WHERE username_id=$USERNAME_ID")
        # Format singular or plural
        TRY_TRIES=$(if [[ $ATTEMPTS -eq 1 ]]; then echo "try"; else echo "tries"; fi)

        echo "You guessed it in $ATTEMPTS $TRY_TRIES. The secret number was $SECRET_NUMBER. Nice job!"
        break
    fi

    # increment number of tries
    ((ATTEMPTS++))
    # get new guess
    read NUMBER

done
