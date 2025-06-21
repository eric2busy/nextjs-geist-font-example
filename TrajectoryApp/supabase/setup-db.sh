#!/bin/bash

# Supabase project configuration
PROJECT_ID="fxrhtizseumgqyeuvoyn"
ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ4cmh0aXpzZXVtZ3F5ZXV2b3luIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA0NjI1MTksImV4cCI6MjA2NjAzODUxOX0.n256SWA7S3F8QdPYWourA7zgWizuRxV6OFImCaQq5vE"
API_URL="https://$PROJECT_ID.supabase.co/rest/v1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo "🚀 Initializing Supabase database for Trajectory App..."

# Test connection
echo "🔄 Testing API connection..."
response=$(curl -s -X GET \
    -H "apikey: $ANON_KEY" \
    -H "Authorization: Bearer $ANON_KEY" \
    "$API_URL/articles?limit=0")

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ API connection successful${NC}"
else
    echo -e "${RED}✗ Failed to connect to API${NC}"
    echo "Error: $response"
    exit 1
fi

# Function to execute SQL via Supabase API
execute_sql() {
    local sql_file=$1
    local description=$2
    
    echo -e "\n📝 $description..."
    
    if [ -f "$sql_file" ]; then
        # Read SQL file content
        sql_content=$(cat "$sql_file")
        
        # Execute SQL via API
        response=$(curl -s -X POST \
            "https://$PROJECT_ID.supabase.co/rest/v1/rpc/exec_sql" \
            -H "apikey: $ANON_KEY" \
            -H "Authorization: Bearer $ANON_KEY" \
            -H "Content-Type: application/json" \
            -H "Prefer: return=minimal" \
            -d "{\"sql_query\": \"$sql_content\"}")
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Successfully executed $sql_file${NC}"
        else
            echo -e "${RED}✗ Failed to execute $sql_file${NC}"
            echo "Error: $response"
            exit 1
        fi
    else
        echo -e "${RED}✗ File not found: $sql_file${NC}"
        exit 1
    fi
}

# Create schema
execute_sql "schema.sql" "Creating database schema"

# Load seed data
execute_sql "seed.sql" "Loading seed data"

# Verify setup
echo -e "\n🔍 Verifying database setup..."

# Check tables
tables=("articles" "saved_articles" "user_preferences" "article_trajectories")

for table in "${tables[@]}"; do
    count=$(curl -s -X GET \
        -H "apikey: $ANON_KEY" \
        -H "Authorization: Bearer $ANON_KEY" \
        "$API_URL/$table?select=count" | jq length)
    echo "$table: $count rows"
done

echo -e "\n${GREEN}✅ Setup verification complete${NC}"
echo "You can now use the Trajectory app with your Supabase database!"
