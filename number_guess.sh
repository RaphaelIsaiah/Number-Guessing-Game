#!/bin/bash
# Number Guessing Game Script
# Author: Raphael
# Description: A guessing game where users try to guess a random number between 1 and 1000.
# Requirements: PostgreSQL database "number_guess" with tables "players" and "game_history"

# Constants
PSQL="psql --username=postgres --dbname=number_guess -t --no-align -c"
PLAYERS_TABLE="players"
GAME_HISTORY_TABLE="game_history"

# Function to check if a username exists in the players table
check_username() {
    echo $($PSQL "SELECT username FROM $PLAYERS_TABLE WHERE username='$1'")
}

# Function to insert a new player into the players table
insert_new_user() {
    echo $($PSQL "INSERT INTO $PLAYERS_TABLE(username) VALUES('$1')")
}

# Function to retrieve player stats (games played and best game)
get_player_stats() {
    echo $($PSQL "SELECT games_played, best_game FROM $PLAYERS_TABLE WHERE username='$1'")
}

# Function to update game results
update_game_results() {
    USERNAME_ID=$($PSQL "SELECT username_id FROM $PLAYERS_TABLE WHERE username='$1'")

    # Insert new game result
    $PSQL "INSERT INTO $GAME_HISTORY_TABLE(username_id, attempts) VALUES($USERNAME_ID, $2)"

    # Update games played
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM $GAME_HISTORY_TABLE WHERE username_id=$USERNAME_ID")
    $PSQL "UPDATE $PLAYERS_TABLE SET games_played=$GAMES_PLAYED WHERE username_id=$USERNAME_ID"

    # Update best game
    BEST_GAME=$($PSQL "SELECT MIN(attempts) FROM $GAME_HISTORY_TABLE WHERE username_id=$USERNAME_ID")
    $PSQL "UPDATE $PLAYERS_TABLE SET best_game=$BEST_GAME WHERE username_id=$USERNAME_ID"
}

# Welcome message and initialization
trap "echo 'Thanks for playing! Exiting now.'; exit" SIGINT

echo "Enter your username:"
read USERNAME

EXISTING_USERNAME=$(check_username "$USERNAME")

if [[ -z $EXISTING_USERNAME ]]; then
    insert_new_user "$USERNAME"
    echo "Welcome, $USERNAME! It looks like this is your first time here."
else
    STATS=$(get_player_stats "$EXISTING_USERNAME")
    GAMES_PLAYED=$(echo $STATS | awk '{print $1}')
    BEST_GAME=$(echo $STATS | awk '{print $2}')

    # Handle pluralizations
    GAME_GAMES=$(if [[ $GAMES_PLAYED -eq 1 ]]; then echo "game"; else echo "games"; fi)
    GUESS_GUESSES=$(if [[ $BEST_GAME -eq 1 ]]; then echo "guess"; else echo "guesses"; fi)

    echo "Welcome back, $EXISTING_USERNAME! You have played $GAMES_PLAYED $GAME_GAMES, and your best game took $BEST_GAME $GUESS_GUESSES."
fi

# Generate the random number
SECRET_NUMBER=$((RANDOM % 1000 + 1))
echo $SECRET_NUMBER

# Initialize attempts counter
ATTEMPTS=0

# Guessing logic
echo "Guess the secret number between 1 and 1000:"
while true; do
    read NUMBER

    if [[ $NUMBER == "exit" ]]; then
        echo "Thanks for playing! Goodbye."
        break
    fi

    # Validate input
    if [[ ! $NUMBER =~ ^[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
    elif ((NUMBER < SECRET_NUMBER)); then
        echo "It's higher than that, guess again:"
    elif ((NUMBER > SECRET_NUMBER)); then
        echo "It's lower than that, guess again:"
    else
        ((ATTEMPTS++))

        TRY_TRIES=$(if [[ $ATTEMPTS -eq 1 ]]; then echo "try"; else echo "tries"; fi)

        echo "You guessed it in $ATTEMPTS $TRY_TRIES. The secret number was $SECRET_NUMBER. Nice job!"

        update_game_results "$USERNAME" "$ATTEMPTS"
        break
    fi

    ((ATTEMPTS++))
done
