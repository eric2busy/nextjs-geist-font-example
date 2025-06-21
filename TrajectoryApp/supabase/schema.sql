-- Enable necessary extensions
create extension if not exists "uuid-ossp";
create extension if not exists "pgcrypto";

-- Create enum types
create type user_theme as enum ('System', 'Light', 'Dark');
create type article_bias as enum ('left', 'center', 'right');

-- Articles table
create table articles (
    id uuid primary key default uuid_generate_v4(),
    title text not null,
    category text not null,
    date timestamp with time zone not null default now(),
    author text not null,
    image_url text,
    summary text not null,
    content text not null,
    source_name text not null,
    source_url text not null,
    bias article_bias,
    ai_summary text,
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now(),
    
    constraint articles_title_source_unique unique (title, source_name)
);

-- Create index for full-text search
create index articles_fts_idx on articles using gin (
    to_tsvector('english',
        coalesce(title, '') || ' ' ||
        coalesce(summary, '') || ' ' ||
        coalesce(content, '') || ' ' ||
        coalesce(author, '') || ' ' ||
        coalesce(source_name, '')
    )
);

-- Saved articles table
create table saved_articles (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id) on delete cascade,
    article_id uuid references articles(id) on delete cascade,
    created_at timestamp with time zone default now(),
    
    constraint saved_articles_user_article_unique unique (user_id, article_id)
);

-- Create index for faster lookups
create index saved_articles_user_id_idx on saved_articles(user_id);
create index saved_articles_article_id_idx on saved_articles(article_id);

-- User preferences table
create table user_preferences (
    id uuid primary key default uuid_generate_v4(),
    user_id uuid references auth.users(id) on delete cascade,
    notifications_enabled boolean default true,
    theme user_theme default 'System',
    text_size double precision default 1.0,
    selected_categories text[] default array[]::text[],
    created_at timestamp with time zone default now(),
    updated_at timestamp with time zone default now(),
    
    constraint user_preferences_user_unique unique (user_id)
);

-- Article trajectories table (for tracking story evolution)
create table article_trajectories (
    id uuid primary key default uuid_generate_v4(),
    parent_article_id uuid references articles(id) on delete cascade,
    child_article_id uuid references articles(id) on delete cascade,
    relationship_type text not null,
    similarity_score double precision,
    created_at timestamp with time zone default now(),
    
    constraint article_trajectories_unique unique (parent_article_id, child_article_id),
    constraint different_articles check (parent_article_id != child_article_id)
);

-- Create indexes for trajectory queries
create index article_trajectories_parent_idx on article_trajectories(parent_article_id);
create index article_trajectories_child_idx on article_trajectories(child_article_id);

-- Update timestamps function
create or replace function update_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Create triggers for updating timestamps
create trigger update_articles_updated_at
    before update on articles
    for each row
    execute function update_updated_at();

create trigger update_user_preferences_updated_at
    before update on user_preferences
    for each row
    execute function update_updated_at();

-- Row Level Security (RLS) policies

-- Articles are readable by all authenticated users
alter table articles enable row level security;
create policy "Articles are viewable by all users"
    on articles for select
    to authenticated
    using (true);

-- Saved articles are only accessible by the owner
alter table saved_articles enable row level security;
create policy "Users can view their own saved articles"
    on saved_articles for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can save articles"
    on saved_articles for insert
    to authenticated
    with check (auth.uid() = user_id);

create policy "Users can unsave articles"
    on saved_articles for delete
    to authenticated
    using (auth.uid() = user_id);

-- User preferences are only accessible by the owner
alter table user_preferences enable row level security;
create policy "Users can view their own preferences"
    on user_preferences for select
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can update their own preferences"
    on user_preferences for update
    to authenticated
    using (auth.uid() = user_id);

create policy "Users can insert their preferences"
    on user_preferences for insert
    to authenticated
    with check (auth.uid() = user_id);

-- Article trajectories are readable by all authenticated users
alter table article_trajectories enable row level security;
create policy "Article trajectories are viewable by all users"
    on article_trajectories for select
    to authenticated
    using (true);

-- Functions

-- Function to get related articles
create or replace function get_related_articles(article_id uuid)
returns setof articles as $$
begin
    return query
    select distinct a.*
    from articles a
    join article_trajectories t
    on (t.parent_article_id = article_id and t.child_article_id = a.id)
    or (t.child_article_id = article_id and t.parent_article_id = a.id)
    order by a.date desc;
end;
$$ language plpgsql security definer;

-- Function to get article trajectory
create or replace function get_article_trajectory(article_id uuid)
returns table (
    id uuid,
    title text,
    date timestamp with time zone,
    relationship_type text,
    similarity_score double precision
) as $$
begin
    return query
    with recursive trajectory as (
        -- Base case: start with the given article
        select 
            a.id,
            a.title,
            a.date,
            null::text as relationship_type,
            null::double precision as similarity_score
        from articles a
        where a.id = article_id
        
        union
        
        -- Recursive case: find related articles
        select
            a.id,
            a.title,
            a.date,
            t.relationship_type,
            t.similarity_score
        from trajectory tr
        join article_trajectories t
        on tr.id = t.parent_article_id
        join articles a
        on t.child_article_id = a.id
    )
    select * from trajectory
    order by date;
end;
$$ language plpgsql security definer;
