#!/bin/bash

# Check if an argument is provided
if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Database connection details
DB_NAME="periodic_table"
USER="postgres"

# Query the database for the element
ELEMENT_DATA=$(psql -U "$USER" -d "$DB_NAME" -t --no-align -c "
  SELECT elements.atomic_number, elements.name, elements.symbol, properties.atomic_mass, 
         properties.melting_point_celsius, properties.boiling_point_celsius, types.type AS element_type
  FROM elements 
  INNER JOIN properties USING(atomic_number) 
  INNER JOIN types ON properties.type_id = types.type_id
  WHERE elements.atomic_number::TEXT = '$1' OR elements.symbol = '$1' OR elements.name = '$1';
")

# Check if element exists
if [[ -z "$ELEMENT_DATA" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

# Extract values
IFS="|" read -r atomic_number name symbol mass mp bp element_type <<< "$ELEMENT_DATA"

# Display the formatted output
echo "The element with atomic number $atomic_number is $name ($symbol). It's a $element_type, with a mass of $mass amu. $name has a melting point of $mp celsius and a boiling point of $bp celsius."

exit 0
