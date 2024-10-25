#!/bin/bash

# Function to run a make command and print its output
run_make_command() {
    local command=$1
    echo "Running make $command..."
    make $command
    echo "Finished make $command."
    echo ""
}

# Function to check if the PostgreSQL container is running
check_postgres_container() {
    echo "Checking if PostgreSQL container is running..."
    if [ "$(docker ps -q -f name=some-postgres)" ]; then
        echo "PostgreSQL container is running."
    else
        echo "PostgreSQL container is not running."
    fi
    echo ""
}

# Function to test the PostgreSQL connection
test_postgres_connection() {
    echo "Testing PostgreSQL connection..."
    docker exec -it some-postgres psql -U postgres -c "\conninfo"
    echo "Finished testing PostgreSQL connection."
    echo ""
}

# Run each make command
run_make_command "setup"
run_make_command "start-postgres"
check_postgres_container
test_postgres_connection
run_make_command "run-scrapy"
run_make_command "compress"
run_make_command "stop-postgres"
check_postgres_container
run_make_command "clean"
run_make_command "help"

echo "All make commands and PostgreSQL container have been tested."
