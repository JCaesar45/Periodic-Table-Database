#!/bin/bash

# Database connection variable
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if argument is provided
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

# Determine if input is atomic number, symbol, or name
INPUT=$1

# Query based on input type
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  # Input is atomic number
  QUERY_RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type 
    FROM elements e 
    JOIN properties p ON e.atomic_number = p.atomic_number 
    JOIN types t ON p.type_id = t.type_id 
    WHERE e.atomic_number = $INPUT")
else
  # Input is symbol or name
  QUERY_RESULT=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type 
    FROM elements e 
    JOIN properties p ON e.atomic_number = p.atomic_number 
    JOIN types t ON p.type_id = t.type_id 
    WHERE e.symbol = '$INPUT' OR e.name = '$INPUT'")
fi

# Check if element was found
if [[ -z $QUERY_RESULT ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse the result
IFS="|" read ATOMIC_NUMBER NAME SYMBOL ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< "$QUERY_RESULT"

# Output the result
echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
