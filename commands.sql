-- psql commands to create the database

CREATE DATABASE number_guess;
\c number_guess

CREATE TABLE users();
ALTER TABLE users add COLUMN user_id SERIAL PRIMARY KEY;
ALTER TABLE users add COLUMN username VARCHAR(22) NOT NULL UNIQUE;

CREATE TABLE games();
ALTER TABLE games ADD COLUMN game_id SERIAL PRIMARY KEY;
ALTER TABLE games ADD COLUMN user_id INT NOT NULL;
ALTER TABLE games ADD CONSTRAINT fk_users_games FOREIGN KEY (user_id) REFERENCES users(user_id);
ALTER TABLE games ADD COLUMN guesses INT NOT NULL DEFAULT(0);

-- psql -d number_guess -f number_guess.sql
-- psql -U postgres -d number_guess -f number_guess.sql
TRUNCATE TABLE players, game_history RESTART IDENTITY CASCADE;