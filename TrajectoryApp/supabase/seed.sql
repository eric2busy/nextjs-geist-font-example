-- Seed data for testing

-- Insert sample articles
insert into articles (
    title,
    category,
    date,
    author,
    image_url,
    summary,
    content,
    source_name,
    source_url,
    bias
) values
(
    'The Future of AI in Healthcare',
    'Technology',
    now() - interval '2 days',
    'John Smith',
    'https://example.com/images/ai-healthcare.jpg',
    'Artificial intelligence is revolutionizing healthcare with improved diagnostics and personalized treatment plans.',
    'Full article content about AI in healthcare...',
    'Tech Review',
    'https://techreview.com/ai-healthcare',
    'center'
),
(
    'Global Climate Summit Reaches Historic Agreement',
    'Politics',
    now() - interval '1 day',
    'Sarah Johnson',
    'https://example.com/images/climate-summit.jpg',
    'World leaders agree to ambitious carbon reduction targets at landmark climate conference.',
    'Full article content about climate summit...',
    'World News',
    'https://worldnews.com/climate-summit',
    'center'
),
(
    'Breakthrough in Quantum Computing',
    'Science',
    now() - interval '12 hours',
    'Dr. Michael Chen',
    'https://example.com/images/quantum-computing.jpg',
    'Scientists achieve quantum supremacy with new 1000-qubit processor.',
    'Full article content about quantum computing...',
    'Science Daily',
    'https://sciencedaily.com/quantum-breakthrough',
    'center'
),
(
    'Market Response to Tech Regulations',
    'Business',
    now() - interval '6 hours',
    'Emma Williams',
    'https://example.com/images/tech-regulations.jpg',
    'Global markets react to new technology industry regulations.',
    'Full article content about market response...',
    'Financial Times',
    'https://ft.com/tech-regulations',
    'center'
);

-- Insert related articles to demonstrate trajectory feature
insert into articles (
    title,
    category,
    date,
    author,
    image_url,
    summary,
    content,
    source_name,
    source_url,
    bias
) values
(
    'AI Healthcare Systems Show Promise in Clinical Trials',
    'Technology',
    now() - interval '1 day',
    'Robert Johnson',
    'https://example.com/images/ai-trials.jpg',
    'Clinical trials demonstrate effectiveness of AI-powered diagnostic systems.',
    'Full article content about AI clinical trials...',
    'Med Tech Journal',
    'https://medtech.com/ai-trials',
    'center'
);

-- Create article trajectory relationships
insert into article_trajectories (
    parent_article_id,
    child_article_id,
    relationship_type,
    similarity_score
)
select
    a1.id as parent_article_id,
    a2.id as child_article_id,
    'follow-up' as relationship_type,
    0.85 as similarity_score
from articles a1
join articles a2 on a1.title = 'The Future of AI in Healthcare'
    and a2.title = 'AI Healthcare Systems Show Promise in Clinical Trials';

-- Insert sample user preferences (after user creation in auth.users)
insert into user_preferences (
    user_id,
    notifications_enabled,
    theme,
    text_size,
    selected_categories
) values
(
    '00000000-0000-0000-0000-000000000000'::uuid, -- Replace with actual user ID
    true,
    'System',
    1.0,
    array['Technology', 'Science']
);

-- Insert sample saved articles
insert into saved_articles (
    user_id,
    article_id
)
select
    '00000000-0000-0000-0000-000000000000'::uuid, -- Replace with actual user ID
    id
from articles
where category = 'Technology'
limit 2;

-- Add AI-generated summaries
update articles
set ai_summary = case
    when title = 'The Future of AI in Healthcare'
    then 'AI technologies are transforming healthcare through improved diagnostic accuracy and personalized treatment recommendations. Key developments include machine learning algorithms for medical imaging and predictive analytics for patient outcomes.'
    when title = 'Global Climate Summit Reaches Historic Agreement'
    then 'World leaders have committed to significant carbon reduction targets, marking a turning point in global climate action. The agreement includes specific measures for industrial nations and support for developing countries.'
    when title = 'Breakthrough in Quantum Computing'
    then 'Scientists have achieved a major milestone in quantum computing with a new processor design. This advancement brings us closer to practical quantum applications in cryptography and complex calculations.'
    when title = 'Market Response to Tech Regulations'
    then 'Financial markets have shown mixed reactions to new technology industry regulations, with some sectors seeing increased volatility while others demonstrate resilience and adaptation.'
    else ai_summary
end
where ai_summary is null;
