## Web Scraper + Vector Search Chatbot (Monorepo)

### Overview
This monorepo contains:
- `scraper_api` (Ruby on Rails 8, API-only): scraping, embedding, storage, and search
- `chatbot-ui` (React): chatbot interface that queries the Rails API
- PostgreSQL with `pgvector` extension for vector similarity search

### Architecture
- **Rails API**: endpoints to scrape URLs, create OpenAI embeddings (text-embedding-3-small), store vectors in Postgres (`vector` type), and perform similarity search.
- **PostgreSQL**: primary datastore, with `vector` extension enabled.
- **React UI**: chat interface that sends user questions to the API; responses are based on nearest-neighbor results from embeddings.

### Setup
1) Backend
 - Ensure PostgreSQL is running locally and `CREATE EXTENSION IF NOT EXISTS vector;` is enabled via migration.
 - Copy `scraper_api/.env.example` to `.env` and set `OPENAI_API_KEY` and DB settings.
 - From `scraper_api`:
   - `bundle install`
   - `bin/rails db:create db:migrate`
   - `bin/rails server`

2) Frontend
 - Copy `chatbot-ui/.env.example` to `.env` and set `REACT_APP_API_BASE_URL`.
 - From `chatbot-ui`:
   - `npm install`
   - `npm start`

### Monorepo decision
Using a monorepo for shared versioning and simpler local dev. CI/CD can deploy frontend and backend independently.


