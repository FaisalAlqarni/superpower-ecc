---
name: rails-verification
description: Verification loop for Rails projects: migrations, routes, security, performance, tests with coverage, asset pipeline, and deployment readiness checks before release or PR.
---

# Rails Verification Loop

Run before PRs, after major changes, and pre-deploy to ensure Rails application quality, security, and production readiness.

## Phase 1: Environment Check

```bash
# Verify Ruby version
ruby --version  # Should match .ruby-version

# Check bundler and gems
bundle --version
bundle outdated

# Verify Rails version
rails --version

# Check for environment variables
ruby -e "puts 'SECRET_KEY_BASE set' if ENV['SECRET_KEY_BASE']; puts 'DATABASE_URL set' if ENV['DATABASE_URL']"

# Verify Node.js (for asset pipeline)
node --version
yarn --version  # or npm --version
```

If environment is misconfigured, stop and fix before proceeding.

## Phase 2: Code Quality & Formatting

```bash
# RuboCop linting
bundle exec rubocop -a  # Auto-correct safe issues
bundle exec rubocop --auto-gen-config  # Generate config for existing violations

# Rails best practices check
bundle exec rails_best_practices .

# Reek for code smells
bundle exec reek

# Rails-specific checks
bundle exec rails zeitwerk:check  # Verify autoloading
```

Common issues:
- Style violations (indentation, string quotes, trailing whitespace)
- N+1 query detection in controllers
- Long methods or classes
- Autoloading issues with class/module naming

## Phase 3: Migration Verification

```bash
# Check for pending migrations
bundle exec rails db:migrate:status

# Validate migration reversibility
bundle exec rails db:migrate
bundle exec rails db:rollback STEP=1
bundle exec rails db:migrate  # Re-apply

# Check for migration conflicts
git diff --name-only | grep db/migrate

# Verify migration data safety
# Review each migration for:
# - Data loss operations (remove_column, drop_table)
# - Missing default values for NOT NULL columns
# - Large table alterations without batching
```

**Migration Checklist:**
- [ ] All migrations are reversible (use `change` or implement `down`)
- [ ] No data loss without explicit backfill strategy
- [ ] New columns have sensible defaults or allow NULL
- [ ] Indexes added for foreign keys and frequently queried columns
- [ ] Zero-downtime compatible (no removed columns/tables still in use)
- [ ] Large data migrations use batching (find_each, in_batches)
- [ ] Constraints (NOT NULL, unique) added safely in separate migrations
- [ ] Migration timestamps don't conflict with other branches

**Zero-Downtime Migration Pattern:**

```ruby
# Step 1: Add new column with default
add_column :users, :full_name, :string, default: ""

# Step 2: Backfill data in background job
# User.find_each { |u| u.update(full_name: "#{u.first_name} #{u.last_name}") }

# Step 3: Add validation in model (soft enforcement)
# validates :full_name, presence: true

# Step 4: Add NOT NULL constraint (next deploy)
# change_column_null :users, :full_name, false

# Step 5: Remove old columns (next deploy)
# remove_column :users, :first_name
# remove_column :users, :last_name
```

## Phase 4: Route Verification

```bash
# Display all routes
bundle exec rails routes > routes.txt

# Check for route coverage (routes used in code)
bundle exec rails routes:coverage  # If rake_routes_coverage gem installed

# Find unused routes
bundle exec rails routes | grep -v "rails/active_storage"

# Verify RESTful compliance
# Review routes.txt for:
# - Excessive custom routes (should use RESTful actions when possible)
# - Missing constraints on route parameters
# - Namespace consistency
```

**Route Security Checklist:**
- [ ] Admin routes protected behind authentication/authorization
- [ ] API routes use proper versioning (api/v1, api/v2)
- [ ] Sensitive routes use HTTPS in production
- [ ] Route constraints validate parameters (format, id ranges)
- [ ] No wildcard routes exposing internal actions
- [ ] CORS configured correctly for API endpoints

**RESTful Route Review:**

```ruby
# Good: Standard RESTful routes
resources :posts do
  resources :comments, only: [:index, :create, :destroy]
end

# Warning: Too many custom routes
resources :posts do
  member do
    post :publish
    post :unpublish
    post :archive
    get :preview
    post :restore
  end
end
# Consider: Use state machine or nested resources instead

# Bad: Exposing dangerous routes
# DELETE /users/:id/destroy_with_data  # Should require confirmation
```

## Phase 5: Security Scan

```bash
# Brakeman security scanner
bundle exec brakeman -q -z

# Bundle-audit for CVE vulnerabilities
bundle exec bundle-audit check --update

# Secrets detection
bundle exec rails credentials:show  # Verify encrypted credentials work
git diff | grep -iE "password|secret|api_key|token" | grep -v "# "

# Check for insecure configurations
grep -r "config.force_ssl = false" config/
grep -r "protect_from_forgery" app/controllers/
```

**OWASP Rails Security Checklist:**

- [ ] **SQL Injection**: No string interpolation in queries
  ```ruby
  # Bad: User.where("name = '#{params[:name]}'")
  # Good: User.where(name: params[:name])
  ```

- [ ] **Mass Assignment**: Strong parameters in all controllers
  ```ruby
  # params.permit(:name, :email)  # Explicit allowlist
  ```

- [ ] **CSRF**: `protect_from_forgery with: :exception` in ApplicationController

- [ ] **XSS**: No `html_safe` or `raw` without sanitization
  ```ruby
  # Bad: <%= raw @user.bio %>
  # Good: <%= sanitize @user.bio, tags: %w[p br strong em] %>
  ```

- [ ] **Authentication**: Devise/Sorcery configured with secure defaults
  - Password complexity requirements
  - Account lockout after failed attempts
  - Session timeout configured
  - Secure password reset flow

- [ ] **Authorization**: Pundit/CanCanCan policies for all actions
  ```ruby
  # authorize @post  # In every controller action
  ```

- [ ] **Secrets Management**:
  - `config/master.key` not committed to git
  - `Rails.application.credentials` used for API keys
  - Environment variables for deployment-specific config

- [ ] **Security Headers**: Configured in production
  ```ruby
  # config/application.rb
  config.force_ssl = true
  config.ssl_options = { hsts: { subdomains: true } }

  # Content Security Policy
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self, :unsafe_inline
  end
  ```

- [ ] **Rate Limiting**: API endpoints protected with rack-attack
  ```ruby
  # config/initializers/rack_attack.rb
  Rack::Attack.throttle('api/ip', limit: 300, period: 5.minutes)
  ```

- [ ] **File Uploads**: ActiveStorage with validation
  ```ruby
  # validates :avatar, content_type: ['image/png', 'image/jpg']
  # validates :avatar, size: { less_than: 5.megabytes }
  ```

## Phase 6: Performance Checks

```bash
# Bullet gem for N+1 query detection
# Add to Gemfile: gem 'bullet', group: :development
# Enable in config/environments/development.rb
bundle exec rails server  # Then browse app and check logs

# Database query analysis
bundle exec rails db:analyze  # If available

# Check for missing indexes
bundle exec rails db:schema:dump
# Review schema.rb for foreign keys without indexes
```

**Performance Checklist:**

- [ ] **N+1 Queries Eliminated**:
  ```ruby
  # Bad: @posts.each { |p| p.user.name }
  # Good: @posts.includes(:user).each { |p| p.user.name }
  ```

- [ ] **Database Indexes**:
  - All foreign keys indexed
  - Frequently queried columns indexed
  - Composite indexes for multi-column queries
  - Unique indexes for unique constraints
  ```ruby
  add_index :posts, :user_id
  add_index :posts, [:user_id, :published_at]
  add_index :users, :email, unique: true
  ```

- [ ] **Caching Strategy**:
  - Fragment caching for expensive views
  - Russian Doll caching for nested resources
  - HTTP caching headers (ETag, Last-Modified)
  - Cache expiration strategy defined
  ```ruby
  # <%= cache @post do %>
  #   <%= render @post %>
  # <% end %>
  ```

- [ ] **Background Jobs**:
  - Sidekiq/DelayedJob configured for async work
  - Email sending moved to background
  - External API calls in jobs
  - Heavy computations queued
  ```ruby
  # UserMailer.welcome_email(@user).deliver_later
  # ProcessReportJob.perform_later(@report.id)
  ```

- [ ] **Database Query Optimization**:
  - `select` to limit columns retrieved
  - `pluck` instead of `map` for simple attributes
  - `find_each`/`find_in_batches` for large datasets
  - Counter caches for associations
  ```ruby
  # belongs_to :user, counter_cache: true
  # add_column :users, :posts_count, :integer, default: 0
  ```

- [ ] **Pagination**:
  - Large result sets paginated (kaminari, pagy)
  - API responses paginated
  ```ruby
  # @posts = Post.page(params[:page]).per(25)
  ```

- [ ] **Eager Loading**:
  - `includes` for multiple associations
  - `preload` when conditions not needed
  - `joins` for filtering by association
  ```ruby
  # Post.includes(:user, comments: :user)
  ```

## Phase 7: Asset Pipeline Verification

```bash
# Precompile assets (production mode)
RAILS_ENV=production bundle exec rails assets:precompile

# Check for asset compilation errors
# Review public/assets/ for generated files

# Verify asset paths
bundle exec rails runner "puts ActionController::Base.helpers.asset_path('application.css')"

# Check for uncompiled assets in views
grep -r "javascript_include_tag\|stylesheet_link_tag" app/views/ | grep -v "application"

# Clean up old assets
bundle exec rails assets:clean
```

**Asset Pipeline Checklist:**

- [ ] **Precompilation**:
  - All assets compile without errors
  - Source maps generated for debugging
  - Assets versioned with digest hashes

- [ ] **CDN Configuration**:
  ```ruby
  # config/environments/production.rb
  config.asset_host = ENV['CDN_HOST']  # 'https://cdn.example.com'
  ```

- [ ] **Compression**:
  - Gzip compression enabled
  - Images optimized (ImageOptim, imgproxy)
  - Minification for JS/CSS

- [ ] **Webpacker/Shakapacker** (if used):
  ```bash
  bundle exec rails webpacker:compile
  yarn run webpack:build
  ```

- [ ] **Asset Organization**:
  - Vendor assets in vendor/assets
  - Lib assets in lib/assets
  - Manifests correctly require dependencies

## Phase 8: Environment Configuration

```bash
# Compare environment configs
diff config/environments/development.rb config/environments/production.rb

# Verify environment-specific settings
bundle exec rails runner "puts Rails.env; puts Rails.configuration.action_mailer.delivery_method"

# Check for missing ENV variables
bundle exec rails runner "puts ENV.keys.grep(/^APP_/).inspect"
```

**Environment Configuration Checklist:**

**Development:**
- [ ] Detailed error pages enabled
- [ ] Asset debugging enabled
- [ ] Caching disabled (or selectively enabled)
- [ ] Mailer delivery method: letter_opener/test
- [ ] Bullet gem active for N+1 detection

**Test:**
- [ ] Fixtures/factories loaded properly
- [ ] Test database isolated
- [ ] Transactional tests enabled
- [ ] Background jobs run inline (or with test adapter)

**Staging:**
- [ ] Production-like configuration
- [ ] Error tracking enabled (Sentry, Rollbar)
- [ ] Performance monitoring active (New Relic, Scout)
- [ ] Separate database from production

**Production:**
- [ ] `config.force_ssl = true`
- [ ] `config.log_level = :info`
- [ ] `config.consider_all_requests_local = false`
- [ ] `config.action_controller.perform_caching = true`
- [ ] `config.assets.compile = false` (precompiled assets only)
- [ ] `config.active_storage.service = :amazon` (or appropriate service)
- [ ] `config.action_mailer.delivery_method = :smtp`
- [ ] Error tracking configured
- [ ] Log aggregation configured (Papertrail, Loggly)

## Phase 9: Tests + Coverage

```bash
# Run full test suite with SimpleCov
COVERAGE=true bundle exec rspec

# Or with Minitest
COVERAGE=true bundle exec rails test

# Run specific test types
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
bundle exec rspec spec/requests/
bundle exec rspec spec/system/

# Check coverage report
open coverage/index.html
```

**Test Coverage Report:**
- Total tests: X passed, Y failed, Z skipped
- Overall coverage: XX%
- Per-component breakdown

**Coverage Targets:**

| Component | Target |
|-----------|--------|
| Models | 90%+ |
| Controllers | 80%+ |
| Serializers | 85%+ |
| Services/POROs | 90%+ |
| Jobs | 85%+ |
| Mailers | 80%+ |
| Overall | 80%+ |

**Test Quality Checks:**
- [ ] All models have unit tests
- [ ] Controllers have request/integration tests
- [ ] Happy path and error cases covered
- [ ] Edge cases tested (nil, empty, boundary values)
- [ ] Authentication/authorization tested
- [ ] Background jobs tested
- [ ] Mailers have tests

## Phase 10: Deployment Readiness

```bash
# Health check endpoint
curl http://localhost:3000/health
# Should return 200 OK with system status

# Database connectivity
bundle exec rails runner "ActiveRecord::Base.connection.execute('SELECT 1')"

# Cache connectivity (Redis)
bundle exec rails runner "Rails.cache.write('test', 'value'); puts Rails.cache.read('test')"

# Background job processor
# Ensure Sidekiq/DelayedJob is running
bundle exec sidekiq -C config/sidekiq.yml &
```

**Deployment Checklist:**

- [ ] **Health Checks**:
  ```ruby
  # config/routes.rb
  get '/health', to: 'health#check'

  # app/controllers/health_controller.rb
  class HealthController < ApplicationController
    def check
      render json: {
        status: 'ok',
        database: database_ok?,
        cache: cache_ok?,
        timestamp: Time.current
      }
    end
  end
  ```

- [ ] **Monitoring**:
  - Application performance monitoring (APM) configured
  - Error tracking with context (Sentry, Rollbar, Honeybadger)
  - Uptime monitoring (Pingdom, UptimeRobot)
  - Database query monitoring

- [ ] **Logging**:
  - Structured logging (lograge gem)
  - Log rotation configured
  - Sensitive data filtered (passwords, tokens)
  - Request IDs tracked across services
  ```ruby
  # config/initializers/lograge.rb
  Rails.application.configure do
    config.lograge.enabled = true
    config.lograge.custom_options = lambda do |event|
      { params: event.payload[:params].except('controller', 'action') }
    end
  end
  ```

- [ ] **Error Tracking**:
  ```ruby
  # config/initializers/sentry.rb
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]
    config.traces_sample_rate = 0.1
  end
  ```

- [ ] **Database Backups**:
  - Automated daily backups configured
  - Backup restoration tested
  - Point-in-time recovery available
  - Backup retention policy defined

- [ ] **Scaling Readiness**:
  - Stateless application servers
  - Session store externalized (Redis, database)
  - File uploads to cloud storage (S3, GCS)
  - Database connection pooling configured

## Phase 11: Database Verification

```bash
# Check database schema consistency
bundle exec rails db:schema:dump
git diff db/schema.rb  # Should show expected changes only

# Validate seed data
bundle exec rails db:seed
bundle exec rails runner "puts User.count; puts Post.count"

# Test database backup/restore
pg_dump myapp_production > backup.sql
createdb myapp_test_restore
psql myapp_test_restore < backup.sql

# Check for database bloat (PostgreSQL)
bundle exec rails dbconsole << EOF
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC LIMIT 10;
EOF
```

**Database Checklist:**
- [ ] Schema.rb matches actual database structure
- [ ] Seeds.rb creates necessary default data
- [ ] Foreign key constraints defined
- [ ] No orphaned records in production
- [ ] Database indexes optimized
- [ ] Slow query log reviewed
- [ ] Connection pool sized appropriately
- [ ] Database vacuuming scheduled (PostgreSQL)

## Phase 12: Code Quality Audit

```bash
# Run static analysis tools
bundle exec rubocop --format offenses

# Code complexity analysis
bundle exec flog app/  # Lower scores are better
bundle exec flay app/  # Detects duplicate code

# Security-specific linting
bundle exec brakeman -A  # All checks, including warnings

# Dependency analysis
bundle exec bundle-audit check
bundle exec license_finder  # Check gem licenses
```

**Code Quality Metrics:**

- [ ] **RuboCop Compliance**: 0 offenses (or documented exceptions)
- [ ] **Flog Score**: < 40 for methods, < 200 for classes
- [ ] **Duplicate Code**: < 5% duplication (flay)
- [ ] **Documentation**: Public API methods documented
- [ ] **Test Coverage**: ≥ 80% overall

## Phase 13: Diff Review

```bash
# Show diff statistics
git diff --stat origin/main

# Show actual changes
git diff origin/main

# Show changed files
git diff --name-only origin/main

# Check for common issues
git diff origin/main | grep -i "todo\|fixme\|hack\|xxx"
git diff origin/main | grep "binding.pry"  # Debug statements
git diff origin/main | grep "puts \|pp \|p "  # Print debugging
git diff origin/main | grep -i "password.*=\|api_key.*="  # Hardcoded secrets
```

**Diff Review Checklist:**
- [ ] No debugging statements (puts, pp, binding.pry, debugger)
- [ ] No TODO/FIXME in critical code paths
- [ ] No hardcoded secrets or credentials
- [ ] Database migrations included for model changes
- [ ] Routes added/modified are documented
- [ ] Configuration changes documented in README or deploy notes
- [ ] Error handling present for external calls
- [ ] Transaction management where needed
- [ ] Logging added for important operations
- [ ] Comments explain "why" not "what"

## Output Template

```
RAILS VERIFICATION REPORT
=========================

Phase 1: Environment Check
  ✓ Ruby 3.2.2
  ✓ Rails 7.1.0
  ✓ Bundler 2.4.10
  ✓ Node.js 20.10.0
  ✓ All environment variables set

Phase 2: Code Quality
  ✓ RuboCop: 0 offenses
  ✓ Reek: No code smells
  ✓ Rails best practices: Clean
  ✓ Zeitwerk: All classes loadable

Phase 3: Migration Verification
  ✓ No pending migrations
  ✓ All migrations reversible
  ✓ No data loss operations
  ✓ Foreign keys indexed
  ✓ Zero-downtime compatible

Phase 4: Route Verification
  ✓ 247 routes defined
  ✓ All admin routes protected
  ✓ API versioning consistent
  ✓ RESTful compliance: 95%
  ⚠ 3 unused routes detected

Phase 5: Security Scan
  ✓ Brakeman: 0 security issues
  ⚠ Bundle-audit: 2 vulnerabilities (update nokogiri, loofah)
  ✓ No hardcoded secrets
  ✓ CSRF protection enabled
  ✓ Strong parameters enforced
  ✓ Force SSL enabled in production

Phase 6: Performance
  ✓ No N+1 queries detected (Bullet scan)
  ✓ All foreign keys indexed
  ✓ Counter caches configured
  ✓ Background jobs for async work
  ✓ Fragment caching implemented
  ⚠ Consider pagination for /posts (500+ records)

Phase 7: Asset Pipeline
  ✓ Assets precompile successfully
  ✓ CDN configured
  ✓ Gzip compression enabled
  ✓ Source maps generated

Phase 8: Environment Configuration
  ✓ Production config secure
  ✓ Staging mirrors production
  ✓ Environment variables documented
  ✓ Force SSL enabled
  ✓ Log level: info

Phase 9: Tests + Coverage
  Tests: 1,247 examples, 0 failures, 12 pending
  Coverage:
    Overall: 87.3%
    Models: 92.1%
    Controllers: 84.5%
    Services: 91.8%
    Jobs: 88.3%
    Mailers: 82.4%

Phase 10: Deployment Readiness
  ✓ Health check endpoint: 200 OK
  ✓ Database connectivity verified
  ✓ Redis cache reachable
  ✓ Sidekiq running
  ✓ Error tracking (Sentry) configured
  ✓ APM (New Relic) configured
  ✓ Log aggregation (Papertrail) active

Phase 11: Database
  ✓ Schema consistent
  ✓ Seeds runnable
  ✓ Backups configured
  ✓ Foreign keys enforced
  ✓ No orphaned records

Phase 12: Code Quality
  ✓ RuboCop: 0 offenses
  ✓ Flog: Average complexity 15.2
  ✓ Flay: 2.3% duplication
  ✓ Documentation complete

Phase 13: Diff Review
  Files changed: 34
  +1,247 lines, -523 lines
  ✓ No debug statements
  ✓ No hardcoded secrets
  ✓ Migrations included
  ✓ Error handling present

RECOMMENDATIONS:
1. ⚠ Update nokogiri and loofah (security vulnerabilities)
2. ⚠ Add pagination to /posts endpoint
3. ⚠ Remove 3 unused routes

OVERALL STATUS: ⚠️ FIX WARNINGS BEFORE DEPLOY

NEXT STEPS:
1. bundle update nokogiri loofah
2. Implement pagination for high-volume endpoints
3. Remove unused routes
4. Re-run verification
5. Deploy to staging for final testing
```

## Pre-Deployment Checklist

**Critical (Blockers):**
- [ ] All tests passing (0 failures)
- [ ] Coverage ≥ 80%
- [ ] No critical security vulnerabilities (Brakeman, bundle-audit)
- [ ] No pending migrations (or plan to run them)
- [ ] `config.force_ssl = true` in production
- [ ] `SECRET_KEY_BASE` properly set
- [ ] Database backups configured and tested

**High Priority:**
- [ ] Error tracking configured (Sentry, Rollbar, Honeybadger)
- [ ] APM configured (New Relic, Scout, Skylight)
- [ ] Logging configured and log rotation active
- [ ] Health check endpoint responding
- [ ] Assets precompiled and CDN configured
- [ ] Background job processor running
- [ ] Redis/cache backend configured
- [ ] Database connection pooling sized correctly

**Medium Priority:**
- [ ] Uptime monitoring configured
- [ ] Rate limiting configured (rack-attack)
- [ ] CORS configured correctly for APIs
- [ ] Session store externalized
- [ ] File uploads to cloud storage
- [ ] Email delivery configured (SMTP, SendGrid, Mailgun)
- [ ] Content Security Policy configured
- [ ] HSTS headers enabled

**Nice to Have:**
- [ ] Feature flags configured (Flipper, Rollout)
- [ ] A/B testing framework (if needed)
- [ ] Internationalization (I18n) configured
- [ ] Sitemap generation
- [ ] RSS feeds (if applicable)
- [ ] OpenAPI/Swagger documentation (for APIs)

## Continuous Integration

### GitHub Actions Example

```yaml
# .github/workflows/rails-verification.yml
name: Rails Verification

on: [push, pull_request]

jobs:
  verify:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

      redis:
        image: redis:7
        options: >-
          --health-cmd "redis-cli ping"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: 3.2
          bundler-cache: true

      - name: Set up Node
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'yarn'

      - name: Install dependencies
        run: |
          bundle install
          yarn install

      - name: Setup database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: |
          bundle exec rails db:create
          bundle exec rails db:schema:load

      - name: Run RuboCop
        run: bundle exec rubocop

      - name: Run Brakeman
        run: bundle exec brakeman -q -z

      - name: Run bundle-audit
        run: bundle exec bundle-audit check --update

      - name: Compile assets
        run: bundle exec rails assets:precompile
        env:
          RAILS_ENV: test

      - name: Run tests
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
          REDIS_URL: redis://localhost:6379/0
        run: |
          bundle exec rspec --format documentation

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        if: always()
```

## Quick Reference

| Check | Command |
|-------|---------|
| Environment | `ruby --version && rails --version` |
| Linting | `bundle exec rubocop -a` |
| Security | `bundle exec brakeman -q && bundle-audit check` |
| Migrations | `bundle exec rails db:migrate:status` |
| Routes | `bundle exec rails routes` |
| Tests | `bundle exec rspec` |
| Coverage | `COVERAGE=true bundle exec rspec` |
| Assets | `RAILS_ENV=production bundle exec rails assets:precompile` |
| Code quality | `bundle exec rails_best_practices .` |
| Diff stats | `git diff --stat` |

## Common Issues & Solutions

**Issue: Asset precompilation fails in production**
```bash
# Solution: Check for missing gems in production group
bundle exec rails assets:precompile RAILS_ENV=production
# Review error messages for missing gems or Node.js issues
```

**Issue: Database migration fails in production**
```bash
# Solution: Test migration on production copy
pg_dump production_db | psql staging_db
RAILS_ENV=staging bundle exec rails db:migrate
```

**Issue: Tests pass locally but fail in CI**
```bash
# Common causes:
# 1. Database not reset between runs
bundle exec rails db:test:prepare

# 2. Time zone differences
# Add to spec_helper.rb: Time.zone = 'UTC'

# 3. Flaky tests (race conditions)
# Run with --seed to reproduce: bundle exec rspec --seed 12345
```

**Issue: N+1 queries in production**
```bash
# Detection: Enable Bullet in production (carefully)
# Or use APM tools (New Relic, Scout)

# Fix: Use includes/preload
# Before: @posts.each { |p| p.user.name }
# After:  @posts.includes(:user).each { |p| p.user.name }
```

**Issue: Memory bloat in background jobs**
```bash
# Solution: Process in batches
User.find_in_batches(batch_size: 100) do |batch|
  batch.each { |user| process_user(user) }
end
```

Remember: Automated verification catches common issues but doesn't replace manual code review, staging environment testing, and production monitoring. Always have a rollback plan.
