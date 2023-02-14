#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

function FIND_ELEMENT() {

  QUERY_RESULT=""
  # query based on type of user input
  if [[ $1 =~ [0-9] ]] 
    then
      QUERY_RESULT="$($PSQL "SELECT * FROM elements WHERE atomic_number = $1")"
  elif [[ $1 =~ [a-zA-Z]{3,} ]]
    then
      QUERY_RESULT="$($PSQL "SELECT * FROM elements WHERE name = '$1'")"
  elif [[ $1 =~ [a-zA-Z]{1,2} ]] 
    then
      QUERY_RESULT="$($PSQL "SELECT * FROM elements WHERE symbol = '$1'")"
  fi
  # if query is successful then return element
  if [[ $QUERY_RESULT ]] 
    then 
    echo $QUERY_RESULT | cat | while IFS='|' read ATOMIC_NUMBER SYMBOL NAME
      do 
      PROPERTY_RESULT=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
      if [[ $PROPERTY_RESULT ]] 
        then
          echo $PROPERTY_RESULT | cat | while IFS='|' read MASS MELTING_POINT BOILING_POINT TYPE_ID
            do
              ELEMENT_TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
              echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $ELEMENT_TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
            done
      fi
      done
    # if query was not successful
    else 
      echo "I could not find that element in the database."
  fi

}

# if user added an argument
if [[ $1 ]]
  then
    FIND_ELEMENT $1
  else 
    echo "Please provide an element as an argument."
fi

