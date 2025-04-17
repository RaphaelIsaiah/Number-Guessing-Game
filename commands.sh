# terminal bash commands

psql --username=freecodecamp --dbname=postgres

# Note this, may be useful.
# PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# After creating database
mkdir number_guessing_game
cd number_guessing_game
touch number_guess.sh
chmod +x number_guess.sh
git init
# Note the branch you are on, if not main, create and checkout to main branch
git add .
git commit -m "Initial commit"