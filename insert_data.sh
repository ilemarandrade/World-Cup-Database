#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS ; 
do 
  if [[ "$WINNER" == "winner" ]]
  then
    echo "Start of Sed"
  else
    echo -e "\n~~~~ Review the teams $WINNER and $OPPONENT~~~~\n"

    # echo "$YEAR $ROUND $WINNER $OPPONENT $WINNER_GOALS $OPPONENT_GOALS"
    IS_ADDED_THE_WINNER_TEAM="$($PSQL "SELECT * FROM teams WHERE name='$WINNER'")"
    IS_ADDED_THE_OPPONENT_TEAM="$($PSQL "SELECT * FROM teams WHERE name='$OPPONENT'")"

    if [[ -z $IS_ADDED_THE_WINNER_TEAM ]]
    then
      echo -e "\nThe team $WINNER is not added"
      $PSQL "INSERT INTO teams(name) VALUES('$WINNER')" | echo "Added team $WINNER successfully"
    else
      echo "The team $WINNER is added"
    fi

    if [[ -z $IS_ADDED_THE_OPPONENT_TEAM ]]
    then
      echo -e "\nThe team $OPPONENT is not added"
      $PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')" | echo "Added team $OPPONENT successfully"
    else 
      echo "The team $OPPONENT is added"
    fi

    # get WINNER_ID
    WINNER_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    # get OPPONENT_ID
    OPPONENT_ID="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"

    echo -e "\nWinner: $WINNER_ID | OPPONENT_ID: $OPPONENT_ID\n"
    # To add Games 
    $PSQL "INSERT INTO games(year, winner_id, opponent_id, winner_goals, opponent_goals, round) VALUES($YEAR, $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS, '$ROUND' )" | echo -e "\n~~~~ Add $WINNER vs $OPPONENT game successfully ~~~~\n\n"

  fi
done