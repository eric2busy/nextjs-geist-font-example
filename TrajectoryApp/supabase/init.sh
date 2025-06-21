#!/bin/bash

# Supabase project configuration
PROJECT_ID="fxrhtizseumgqyeuvoyn"
DB_PASSWORD="0s2mALHgsRrC2Ant"
DB_HOST="db.$PROJECT_ID.supabase.co"
DB_USER="postgres"
DB_NAME="postgres"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🚀 Initializing Supabase database for Trajectory App..."

# Test database connection
echo "🔄 Testing database connection..."
if PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c '\conninfo'; then
    echo -e "${GREEN}✓ Database connection successful${NC}"
else
    echo -e "${RED}✗ Failed to connect to database${NC}"
    exit 1
fi

# Function to run SQL file
run_sql_file() {
    local file=$1
    local description=$2
    
    echo -e "\n📝 $description..."
    
    if [ -f "$file" ]; then
        # Using psql to execute the SQL file
        PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f $file
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Successfully executed $file${NC}"
        else
            echo -e "${RED}✗ Failed to execute $file${NC}"
            exit 1
        fi
    else
        echo -e "${RED}✗ File not found: $file${NC}"
        exit 1
    fi
}

# Initialize database schema
run_sql_file "schema.sql" "Creating database schema"

# Load seed data
run_sql_file "seed.sql" "Loading seed data"

echo -e "\n${GREEN}✨ Database initialization complete!${NC}"

# Verify setup
echo -e "\n🔍 Verifying database setup..."

# List tables
PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "\dt"

# Show row counts
echo -e "\n📊 Row counts:"
tables=("articles" "saved_articles" "user_preferences" "article_trajectories")

for table in "${tables[@]}"; do
    count=$(PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM $table")
    echo "$table: $count rows"
done

echo -e "\n${GREEN}✅ Setup verification complete${NC}"
echo "You can now use the Trajectory app with your Supabase database!"
