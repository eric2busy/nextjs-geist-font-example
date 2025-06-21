# Trajectory App - Supabase Backend

This directory contains the Supabase configuration and database setup for the Trajectory iOS app.

## Quick Start

1. Install the Supabase CLI:
   ```bash
   # macOS
   brew install supabase/tap/supabase

   # Windows
   scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
   scoop install supabase
   ```

2. Set up your environment:
   ```bash
   # Set your Supabase access token
   export SUPABASE_ACCESS_TOKEN="your_access_token"
   
   # Set database password
   export DB_PASSWORD="your_db_password"
   ```

3. Run the initialization script:
   ```bash
   cd TrajectoryApp/supabase
   ./init.sh
   ```

## Manual Setup

If you prefer to set up the database manually:

1. Apply the schema:
   ```bash
   psql -h db.fxrhtizseumgqyeuvoyn.supabase.co -U postgres -d postgres -f schema.sql
   ```

2. Load test data:
   ```bash
   psql -h db.fxrhtizseumgqyeuvoyn.supabase.co -U postgres -d postgres -f seed.sql
   ```

## Database Structure

### Tables

1. `articles`
   - Stores news articles with full content and metadata
   - Includes AI-generated summaries and bias analysis
   - Full-text search enabled for content discovery

2. `saved_articles`
   - Junction table for user's saved articles
   - Implements many-to-many relationship between users and articles
   - Row-level security ensures users can only access their saved articles

3. `user_preferences`
   - Stores user-specific settings and preferences
   - Includes notification settings, theme preference, and text size
   - One-to-one relationship with auth.users

4. `article_trajectories`
   - Tracks relationships between related articles
   - Enables story evolution tracking and trajectory visualization
   - Includes similarity scores and relationship types

### Security

- Row Level Security (RLS) policies implemented for all tables
- Articles are readable by all authenticated users
- User-specific data (saved articles, preferences) restricted to owners
- JWT-based authentication using Supabase Auth

## Setup Instructions

1. Create a new Supabase project:
   ```bash
   supabase init
   ```

2. Configure environment variables:
   - Copy `config.toml` to your Supabase project
   - Update the following values:
     - `jwt_secret`
     - `site_url`
     - Apple Sign-In credentials

3. Initialize the database:
   ```bash
   # Apply the schema
   supabase db reset
   
   # Load seed data (for development)
   psql -f seed.sql
   ```

4. Update iOS app configuration:
   ```swift
   // SupabaseService.swift
   let supabaseURL = URL(string: "YOUR_PROJECT_URL")!
   let supabaseKey = "YOUR_ANON_KEY"
   ```

## Database Functions

### `get_related_articles(article_id uuid)`
Returns articles related to the given article based on trajectory relationships.

### `get_article_trajectory(article_id uuid)`
Returns the evolution path of a story, including all related articles in chronological order.

## Row Level Security (RLS) Policies

### Articles
- SELECT: Allowed for all authenticated users
- INSERT/UPDATE: Restricted to service role

### Saved Articles
- SELECT/INSERT/DELETE: Limited to article owner
- UPDATE: Not allowed

### User Preferences
- All operations limited to preference owner

## Development Guidelines

1. Always use prepared statements to prevent SQL injection
2. Test RLS policies thoroughly when adding new features
3. Keep article relationships updated for trajectory feature
4. Monitor query performance with provided indexes

## Monitoring

The following metrics are tracked:
- Query performance (slow query threshold: 2000ms)
- API rate limits (100 requests per minute)
- Connection pool usage (max 100 connections)

## Backup and Recovery

Supabase automatically handles:
- Daily backups (retained for 7 days)
- Point-in-time recovery
- Continuous replication

## Troubleshooting

Common issues and solutions:

1. Connection pool exhaustion:
   - Check for unclosed connections
   - Verify connection timeout settings

2. Slow queries:
   - Review query plans
   - Check index usage
   - Optimize full-text search queries

3. Auth issues:
   - Verify JWT configuration
   - Check RLS policies
   - Validate user session handling

## API Rate Limits

- 100 points per minute per IP
- Authenticated endpoints have higher limits
- Custom limits can be configured in `config.toml`

## Future Improvements

1. Implement article categorization using AI
2. Add real-time updates for article trajectories
3. Enhance full-text search with better ranking
4. Add content moderation system
5. Implement caching layer for frequently accessed articles

## Contributing

1. Follow SQL style guide
2. Test RLS policies
3. Update documentation
4. Add migration scripts for schema changes
