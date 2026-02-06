---
name: rails-tdd
description: Test-driven development for Ruby on Rails with RSpec, model/controller/request/system tests, Capybara, FactoryBot, test database management, and TDD workflow with 80%+ coverage
---

# Rails TDD Workflow

Test-driven development patterns for Ruby on Rails applications using RSpec, FactoryBot, and Capybara with comprehensive coverage of models, controllers, requests, and system tests.

## When to Activate

- Writing new Rails features or endpoints
- Adding functionality to existing Rails applications
- Fixing bugs in Rails codebase
- Refactoring Rails code
- Setting up test infrastructure for Rails projects
- Testing background jobs and mailers

## TDD Workflow

### Red-Green-Refactor Cycle

```ruby
# Step 1: RED - Write failing test
RSpec.describe User do
  it "validates email presence" do
    user = User.new(name: "John Doe")
    expect(user).not_to be_valid
    expect(user.errors[:email]).to include("can't be blank")
  end
end

# Step 2: GREEN - Make test pass
class User < ApplicationRecord
  validates :email, presence: true
end

# Step 3: REFACTOR - Improve while keeping tests green
class User < ApplicationRecord
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
end
```

### TDD Principles

1. **Write tests first** - Define expected behavior before implementation
2. **Minimal implementation** - Write just enough code to pass
3. **Refactor with confidence** - Tests ensure nothing breaks
4. **Fast feedback** - Run tests frequently during development
5. **Test behavior, not implementation** - Focus on outcomes

## Test Structure

### RSpec Configuration

**spec/rails_helper.rb:**
```ruby
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("Running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'factory_bot_rails'
require 'capybara/rspec'

# Load support files
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # Database cleanup
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # Devise helpers (if using Devise)
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::ControllerHelpers, type: :controller
end
```

**spec/spec_helper.rb:**
```ruby
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.filter_run_when_matching :focus
  config.example_status_persistence_file_path = "spec/examples.txt"
  config.disable_monkey_patching!
  config.default_formatter = "doc" if config.files_to_run.one?

  config.order = :random
  Kernel.srand config.seed
end
```

### Directory Structure

```
spec/
├── rails_helper.rb
├── spec_helper.rb
├── support/
│   ├── factory_bot.rb
│   ├── database_cleaner.rb
│   └── shared_examples/
├── factories/
│   ├── users.rb
│   ├── posts.rb
│   └── comments.rb
├── models/
│   ├── user_spec.rb
│   ├── post_spec.rb
│   └── concerns/
├── controllers/
│   └── posts_controller_spec.rb
├── requests/
│   └── api/
│       └── posts_spec.rb
├── system/
│   ├── user_authentication_spec.rb
│   └── post_management_spec.rb
└── jobs/
    └── notification_job_spec.rb
```

## Model Tests

### Basic Model Testing

**spec/models/user_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:password).is_at_least(8) }

    context "email format" do
      it "accepts valid email addresses" do
        user = build(:user, email: "user@example.com")
        expect(user).to be_valid
      end

      it "rejects invalid email addresses" do
        user = build(:user, email: "invalid-email")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("is invalid")
      end
    end
  end

  describe "associations" do
    it { should have_many(:posts).dependent(:destroy) }
    it { should have_many(:comments) }
    it { should have_one(:profile).dependent(:destroy) }
  end

  describe "callbacks" do
    it "normalizes email before save" do
      user = create(:user, email: "USER@EXAMPLE.COM")
      expect(user.reload.email).to eq("user@example.com")
    end

    it "sends welcome email after creation" do
      expect {
        create(:user)
      }.to have_enqueued_job(WelcomeEmailJob)
    end
  end

  describe "scopes" do
    let!(:active_user) { create(:user, active: true) }
    let!(:inactive_user) { create(:user, active: false) }

    describe ".active" do
      it "returns only active users" do
        expect(User.active).to include(active_user)
        expect(User.active).not_to include(inactive_user)
      end
    end

    describe ".recent" do
      it "orders users by creation date descending" do
        older_user = create(:user, created_at: 2.days.ago)
        newer_user = create(:user, created_at: 1.day.ago)

        expect(User.recent.first).to eq(newer_user)
        expect(User.recent.last).to eq(older_user)
      end
    end
  end

  describe "instance methods" do
    let(:user) { create(:user) }

    describe "#full_name" do
      it "returns first and last name" do
        user = build(:user, first_name: "John", last_name: "Doe")
        expect(user.full_name).to eq("John Doe")
      end
    end

    describe "#admin?" do
      it "returns true for admin users" do
        admin = create(:user, role: "admin")
        expect(admin).to be_admin
      end

      it "returns false for regular users" do
        user = create(:user, role: "user")
        expect(user).not_to be_admin
      end
    end
  end
end
```

### Model with Complex Logic

**spec/models/post_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "validations" do
    subject { build(:post) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_uniqueness_of(:slug).scoped_to(:user_id) }
    it { should validate_length_of(:title).is_at_least(5).is_at_most(100) }

    context "when published" do
      before { allow(subject).to receive(:published?).and_return(true) }
      it { should validate_presence_of(:published_at) }
    end
  end

  describe "state machine" do
    let(:post) { create(:post, :draft) }

    it "starts as draft" do
      expect(post).to be_draft
    end

    describe "#publish!" do
      it "transitions from draft to published" do
        expect { post.publish! }.to change { post.state }.from("draft").to("published")
      end

      it "sets published_at timestamp" do
        expect { post.publish! }.to change { post.published_at }.from(nil)
      end

      it "sends notifications" do
        expect {
          post.publish!
        }.to have_enqueued_job(NotificationJob).with(post.id)
      end
    end

    describe "#archive!" do
      let(:post) { create(:post, :published) }

      it "transitions from published to archived" do
        expect { post.archive! }.to change { post.state }.from("published").to("archived")
      end
    end
  end

  describe ".search" do
    let!(:matching_post) { create(:post, title: "Rails Testing Guide") }
    let!(:other_post) { create(:post, title: "Python Tutorial") }

    it "finds posts matching title" do
      results = Post.search("Rails")
      expect(results).to include(matching_post)
      expect(results).not_to include(other_post)
    end

    it "finds posts matching body" do
      post = create(:post, body: "This post is about Rails testing")
      results = Post.search("Rails testing")
      expect(results).to include(post)
    end
  end
end
```

## Controller Tests

### RESTful Controller Testing

**spec/controllers/posts_controller_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }
  let(:post) { create(:post, user: user) }

  describe "GET #index" do
    it "returns success response" do
      get :index
      expect(response).to be_successful
    end

    it "assigns @posts" do
      posts = create_list(:post, 3)
      get :index
      expect(assigns(:posts)).to match_array(posts)
    end

    it "renders index template" do
      get :index
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    it "returns success response" do
      get :show, params: { id: post.id }
      expect(response).to be_successful
    end

    it "assigns @post" do
      get :show, params: { id: post.id }
      expect(assigns(:post)).to eq(post)
    end

    context "when post does not exist" do
      it "raises ActiveRecord::RecordNotFound" do
        expect {
          get :show, params: { id: 999999 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "GET #new" do
    context "when user is signed in" do
      before { sign_in user }

      it "returns success response" do
        get :new
        expect(response).to be_successful
      end

      it "assigns new post" do
        get :new
        expect(assigns(:post)).to be_a_new(Post)
      end
    end

    context "when user is not signed in" do
      it "redirects to sign in page" do
        get :new
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST #create" do
    before { sign_in user }

    context "with valid parameters" do
      let(:valid_params) { { post: attributes_for(:post) } }

      it "creates a new post" do
        expect {
          post :create, params: valid_params
        }.to change(Post, :count).by(1)
      end

      it "redirects to created post" do
        post :create, params: valid_params
        expect(response).to redirect_to(Post.last)
      end

      it "sets success flash message" do
        post :create, params: valid_params
        expect(flash[:notice]).to eq("Post was successfully created.")
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { post: { title: "" } } }

      it "does not create post" do
        expect {
          post :create, params: invalid_params
        }.not_to change(Post, :count)
      end

      it "renders new template" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it "returns unprocessable entity status" do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH #update" do
    before { sign_in user }

    context "with valid parameters" do
      let(:new_attributes) { { title: "Updated Title" } }

      it "updates the post" do
        patch :update, params: { id: post.id, post: new_attributes }
        post.reload
        expect(post.title).to eq("Updated Title")
      end

      it "redirects to the post" do
        patch :update, params: { id: post.id, post: new_attributes }
        expect(response).to redirect_to(post)
      end
    end

    context "with invalid parameters" do
      let(:invalid_attributes) { { title: "" } }

      it "does not update the post" do
        original_title = post.title
        patch :update, params: { id: post.id, post: invalid_attributes }
        post.reload
        expect(post.title).to eq(original_title)
      end

      it "renders edit template" do
        patch :update, params: { id: post.id, post: invalid_attributes }
        expect(response).to render_template(:edit)
      end
    end

    context "when user is not the owner" do
      let(:other_user) { create(:user) }

      before { sign_in other_user }

      it "does not allow update" do
        patch :update, params: { id: post.id, post: { title: "Hacked" } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE #destroy" do
    before { sign_in user }

    it "destroys the post" do
      post # create the post
      expect {
        delete :destroy, params: { id: post.id }
      }.to change(Post, :count).by(-1)
    end

    it "redirects to posts list" do
      delete :destroy, params: { id: post.id }
      expect(response).to redirect_to(posts_url)
    end
  end
end
```

## Request Tests

### API Testing

**spec/requests/api/posts_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe "Api::Posts", type: :request do
  let(:user) { create(:user) }
  let(:auth_headers) { { 'Authorization' => "Bearer #{user.auth_token}" } }

  describe "GET /api/posts" do
    let!(:posts) { create_list(:post, 10) }

    it "returns posts" do
      get "/api/posts"
      expect(response).to have_http_status(:success)
    end

    it "returns JSON" do
      get "/api/posts"
      expect(response.content_type).to match(a_string_including("application/json"))
    end

    it "returns paginated posts" do
      get "/api/posts", params: { page: 1, per_page: 5 }
      json = JSON.parse(response.body)
      expect(json['posts'].length).to eq(5)
    end

    it "filters by published status" do
      published_post = create(:post, :published)
      draft_post = create(:post, :draft)

      get "/api/posts", params: { status: "published" }
      json = JSON.parse(response.body)
      ids = json['posts'].map { |p| p['id'] }

      expect(ids).to include(published_post.id)
      expect(ids).not_to include(draft_post.id)
    end
  end

  describe "GET /api/posts/:id" do
    let(:post) { create(:post) }

    it "returns the post" do
      get "/api/posts/#{post.id}"
      expect(response).to have_http_status(:success)
    end

    it "includes post attributes" do
      get "/api/posts/#{post.id}"
      json = JSON.parse(response.body)

      expect(json['post']['id']).to eq(post.id)
      expect(json['post']['title']).to eq(post.title)
      expect(json['post']['body']).to eq(post.body)
    end

    it "includes associated user" do
      get "/api/posts/#{post.id}"
      json = JSON.parse(response.body)

      expect(json['post']['user']).to be_present
      expect(json['post']['user']['id']).to eq(post.user_id)
    end

    context "when post does not exist" do
      it "returns 404" do
        get "/api/posts/999999"
        expect(response).to have_http_status(:not_found)
      end

      it "returns error message" do
        get "/api/posts/999999"
        json = JSON.parse(response.body)
        expect(json['error']).to eq("Post not found")
      end
    end
  end

  describe "POST /api/posts" do
    let(:valid_params) do
      { post: attributes_for(:post) }
    end

    context "with authentication" do
      it "creates a post" do
        expect {
          post "/api/posts", params: valid_params, headers: auth_headers
        }.to change(Post, :count).by(1)
      end

      it "returns created status" do
        post "/api/posts", params: valid_params, headers: auth_headers
        expect(response).to have_http_status(:created)
      end

      it "returns created post" do
        post "/api/posts", params: valid_params, headers: auth_headers
        json = JSON.parse(response.body)
        expect(json['post']['title']).to eq(valid_params[:post][:title])
      end

      context "with invalid params" do
        let(:invalid_params) { { post: { title: "" } } }

        it "does not create post" do
          expect {
            post "/api/posts", params: invalid_params, headers: auth_headers
          }.not_to change(Post, :count)
        end

        it "returns unprocessable entity status" do
          post "/api/posts", params: invalid_params, headers: auth_headers
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "returns errors" do
          post "/api/posts", params: invalid_params, headers: auth_headers
          json = JSON.parse(response.body)
          expect(json['errors']).to be_present
        end
      end
    end

    context "without authentication" do
      it "returns unauthorized status" do
        post "/api/posts", params: valid_params
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "PATCH /api/posts/:id" do
    let(:post_record) { create(:post, user: user) }
    let(:update_params) { { post: { title: "Updated Title" } } }

    context "with authentication" do
      it "updates the post" do
        patch "/api/posts/#{post_record.id}",
              params: update_params,
              headers: auth_headers

        post_record.reload
        expect(post_record.title).to eq("Updated Title")
      end

      it "returns success status" do
        patch "/api/posts/#{post_record.id}",
              params: update_params,
              headers: auth_headers

        expect(response).to have_http_status(:success)
      end
    end

    context "when user is not the owner" do
      let(:other_user) { create(:user) }
      let(:other_headers) { { 'Authorization' => "Bearer #{other_user.auth_token}" } }

      it "returns forbidden status" do
        patch "/api/posts/#{post_record.id}",
              params: update_params,
              headers: other_headers

        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /api/posts/:id" do
    let!(:post_record) { create(:post, user: user) }

    context "with authentication" do
      it "destroys the post" do
        expect {
          delete "/api/posts/#{post_record.id}", headers: auth_headers
        }.to change(Post, :count).by(-1)
      end

      it "returns no content status" do
        delete "/api/posts/#{post_record.id}", headers: auth_headers
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
```

## System Tests with Capybara

### Feature Testing

**spec/system/post_management_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe "Post Management", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:selenium_chrome_headless)
    sign_in user
  end

  describe "creating a post" do
    it "allows user to create a post" do
      visit posts_path
      click_link "New Post"

      expect(page).to have_current_path(new_post_path)

      fill_in "Title", with: "My First Post"
      fill_in "Body", with: "This is the content of my post"
      click_button "Create Post"

      expect(page).to have_content("Post was successfully created")
      expect(page).to have_content("My First Post")
      expect(page).to have_content("This is the content of my post")
    end

    it "shows validation errors for invalid post" do
      visit new_post_path

      fill_in "Title", with: ""
      click_button "Create Post"

      expect(page).to have_content("Title can't be blank")
      expect(page).to have_current_path(posts_path)
    end

    it "allows adding tags to post" do
      create(:tag, name: "Rails")
      create(:tag, name: "Testing")

      visit new_post_path

      fill_in "Title", with: "Tagged Post"
      fill_in "Body", with: "Post body"
      check "Rails"
      check "Testing"
      click_button "Create Post"

      expect(page).to have_content("Rails")
      expect(page).to have_content("Testing")
    end
  end

  describe "editing a post" do
    let!(:post) { create(:post, user: user, title: "Original Title") }

    it "allows user to edit their post" do
      visit post_path(post)
      click_link "Edit"

      fill_in "Title", with: "Updated Title"
      click_button "Update Post"

      expect(page).to have_content("Post was successfully updated")
      expect(page).to have_content("Updated Title")
      expect(page).not_to have_content("Original Title")
    end
  end

  describe "deleting a post" do
    let!(:post) { create(:post, user: user) }

    it "allows user to delete their post" do
      visit post_path(post)

      accept_confirm do
        click_link "Delete"
      end

      expect(page).to have_content("Post was successfully deleted")
      expect(page).not_to have_content(post.title)
    end
  end

  describe "viewing posts" do
    let!(:published_posts) { create_list(:post, 3, :published) }
    let!(:draft_posts) { create_list(:post, 2, :draft) }

    it "shows only published posts to visitors" do
      sign_out
      visit posts_path

      published_posts.each do |post|
        expect(page).to have_content(post.title)
      end

      draft_posts.each do |post|
        expect(page).not_to have_content(post.title)
      end
    end
  end

  describe "searching posts" do
    let!(:matching_post) { create(:post, title: "Rails Testing Guide", :published) }
    let!(:other_post) { create(:post, title: "Python Tutorial", :published) }

    it "finds posts matching search query" do
      visit posts_path

      fill_in "Search", with: "Rails"
      click_button "Search"

      expect(page).to have_content("Rails Testing Guide")
      expect(page).not_to have_content("Python Tutorial")
    end
  end

  describe "pagination" do
    before { create_list(:post, 25, :published) }

    it "paginates posts" do
      visit posts_path

      expect(page).to have_css(".post", count: 20)
      expect(page).to have_link("Next")

      click_link "Next"

      expect(page).to have_css(".post", count: 5)
    end
  end
end
```

### Authentication System Testing

**spec/system/user_authentication_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe "User Authentication", type: :system do
  before { driven_by(:selenium_chrome_headless) }

  describe "sign up" do
    it "allows new user to register" do
      visit root_path
      click_link "Sign Up"

      fill_in "Email", with: "newuser@example.com"
      fill_in "Password", with: "password123"
      fill_in "Password confirmation", with: "password123"
      click_button "Sign Up"

      expect(page).to have_content("Welcome! You have signed up successfully")
      expect(page).to have_content("newuser@example.com")
    end

    it "shows validation errors" do
      visit new_user_registration_path

      fill_in "Email", with: "invalid-email"
      fill_in "Password", with: "short"
      click_button "Sign Up"

      expect(page).to have_content("Email is invalid")
      expect(page).to have_content("Password is too short")
    end
  end

  describe "sign in" do
    let(:user) { create(:user, password: "password123") }

    it "allows existing user to sign in" do
      visit root_path
      click_link "Sign In"

      fill_in "Email", with: user.email
      fill_in "Password", with: "password123"
      click_button "Sign In"

      expect(page).to have_content("Signed in successfully")
      expect(page).to have_content(user.email)
    end

    it "shows error for invalid credentials" do
      visit new_user_session_path

      fill_in "Email", with: "nonexistent@example.com"
      fill_in "Password", with: "wrongpassword"
      click_button "Sign In"

      expect(page).to have_content("Invalid Email or password")
    end
  end

  describe "sign out" do
    let(:user) { create(:user) }

    it "allows user to sign out" do
      sign_in user
      visit root_path

      click_link "Sign Out"

      expect(page).to have_content("Signed out successfully")
      expect(page).to have_link("Sign In")
    end
  end
end
```

## Test Database Management

### Database Cleaner Setup

**spec/support/database_cleaner.rb:**
```ruby
RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # For system tests that use a separate thread
  config.before(:each, type: :system) do
    DatabaseCleaner.strategy = :truncation
  end

  config.after(:each, type: :system) do
    DatabaseCleaner.strategy = :transaction
  end
end
```

### Test Data with FactoryBot

**spec/factories/users.rb:**
```ruby
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    name { Faker::Name.name }
    confirmed_at { Time.current }

    trait :admin do
      role { "admin" }
    end

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :with_posts do
      transient do
        posts_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:post, evaluator.posts_count, user: user)
      end
    end
  end
end
```

**spec/factories/posts.rb:**
```ruby
FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "Post Title #{n}" }
    body { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    association :user

    trait :published do
      published { true }
      published_at { 1.day.ago }
    end

    trait :draft do
      published { false }
      published_at { nil }
    end

    trait :with_comments do
      transient do
        comments_count { 5 }
      end

      after(:create) do |post, evaluator|
        create_list(:comment, evaluator.comments_count, post: post)
      end
    end

    trait :with_tags do
      transient do
        tags_count { 3 }
      end

      after(:create) do |post, evaluator|
        create_list(:tag, evaluator.tags_count, posts: [post])
      end
    end
  end
end
```

**spec/support/factory_bot.rb:**
```ruby
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end
```

### Fixtures vs Factories

Use **FactoryBot** for:
- Dynamic test data
- Complex object graphs
- Customizable test scenarios
- Most test cases

Use **Fixtures** for:
- Reference data (countries, categories)
- Data that rarely changes
- Performance-critical test suites

## Testing Background Jobs

### ActiveJob Testing

**spec/jobs/notification_job_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe NotificationJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let(:post) { create(:post, :published) }
    let(:subscribers) { create_list(:user, 3) }

    before do
      subscribers.each { |user| post.subscribers << user }
    end

    it "sends notifications to all subscribers" do
      expect {
        NotificationJob.perform_now(post.id)
      }.to change { ActionMailer::Base.deliveries.count }.by(3)
    end

    it "enqueues the job" do
      expect {
        NotificationJob.perform_later(post.id)
      }.to have_enqueued_job(NotificationJob).with(post.id)
    end

    it "enqueues with delay" do
      expect {
        NotificationJob.set(wait: 1.hour).perform_later(post.id)
      }.to have_enqueued_job(NotificationJob)
        .with(post.id)
        .at(1.hour.from_now)
    end

    it "handles missing post gracefully" do
      expect {
        NotificationJob.perform_now(999999)
      }.not_to raise_error
    end

    context "with job execution" do
      around do |example|
        perform_enqueued_jobs do
          example.run
        end
      end

      it "actually sends emails" do
        NotificationJob.perform_later(post.id)
        expect(ActionMailer::Base.deliveries.count).to eq(3)
      end
    end
  end
end
```

### Sidekiq Testing

**spec/workers/hard_worker_spec.rb:**
```ruby
require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe HardWorker do
  describe "#perform" do
    let(:post) { create(:post) }

    it "enqueues job" do
      expect {
        HardWorker.perform_async(post.id)
      }.to change(HardWorker.jobs, :size).by(1)
    end

    context "inline execution" do
      around do |example|
        Sidekiq::Testing.inline! do
          example.run
        end
      end

      it "processes the job" do
        expect_any_instance_of(HardWorker).to receive(:perform).with(post.id)
        HardWorker.perform_async(post.id)
      end
    end
  end
end
```

## Testing Mailers

**spec/mailers/user_mailer_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe "welcome_email" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.welcome_email(user) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to My App")
      expect(mail.to).to eq([user.email])
      expect(mail.from).to eq(["noreply@myapp.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match(user.name)
      expect(mail.body.encoded).to match("Welcome to My App")
    end

    it "includes confirmation link" do
      expect(mail.body.encoded).to match(confirm_email_url(user.confirmation_token))
    end

    it "sends the email" do
      expect {
        mail.deliver_now
      }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "password_reset" do
    let(:user) { create(:user) }
    let(:mail) { UserMailer.password_reset(user) }

    it "includes reset link" do
      expect(mail.body.encoded).to match(reset_password_url(user.reset_token))
    end

    it "has correct subject" do
      expect(mail.subject).to eq("Password Reset Instructions")
    end
  end

  describe "notification_email" do
    let(:user) { create(:user) }
    let(:post) { create(:post) }
    let(:mail) { UserMailer.notification_email(user, post) }

    it "includes post information" do
      expect(mail.body.encoded).to match(post.title)
      expect(mail.body.encoded).to match(post_url(post))
    end

    it "has user's name in greeting" do
      expect(mail.body.encoded).to match("Hi #{user.name}")
    end
  end
end
```

## Testing Concerns

**spec/models/concerns/publishable_spec.rb:**
```ruby
require 'rails_helper'

RSpec.describe Publishable do
  let(:dummy_class) do
    Class.new(ApplicationRecord) do
      self.table_name = 'posts'
      include Publishable
    end
  end

  let(:instance) { dummy_class.new }

  describe "scopes" do
    before do
      create(:post, :published)
      create(:post, :draft)
    end

    it "includes published scope" do
      expect(dummy_class.published.count).to eq(1)
    end

    it "includes draft scope" do
      expect(dummy_class.draft.count).to eq(1)
    end
  end

  describe "#publish!" do
    it "sets published_at" do
      expect {
        instance.publish!
      }.to change { instance.published_at }.from(nil)
    end

    it "sets published to true" do
      expect {
        instance.publish!
      }.to change { instance.published }.from(false).to(true)
    end
  end

  describe "#published?" do
    it "returns true when published_at is set" do
      instance.published_at = Time.current
      expect(instance).to be_published
    end

    it "returns false when published_at is nil" do
      instance.published_at = nil
      expect(instance).not_to be_published
    end
  end
end
```

## Coverage Goals

### SimpleCov Configuration

**spec/spec_helper.rb (top of file):**
```ruby
require 'simplecov'

SimpleCov.start 'rails' do
  add_filter '/spec/'
  add_filter '/config/'
  add_filter '/vendor/'

  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Jobs', 'app/jobs'
  add_group 'Mailers', 'app/mailers'

  minimum_coverage 80
  minimum_coverage_by_file 70
end
```

### Coverage Targets

| Component | Target Coverage |
|-----------|----------------|
| Models | 90%+ |
| Controllers | 85%+ |
| Services | 95%+ |
| Background Jobs | 90%+ |
| Mailers | 85%+ |
| API Endpoints | 90%+ |
| Overall | 80%+ |

### Running Coverage

```bash
# Run all tests with coverage
rspec

# View HTML report
open coverage/index.html

# Run specific test types
rspec spec/models
rspec spec/controllers
rspec spec/system

# Run with specific format
rspec --format documentation

# Run failed tests only
rspec --only-failures

# Run tests matching pattern
rspec --tag focus
rspec --tag ~slow
```

## Testing Best Practices

### DO

- **Write tests first** - Follow TDD cycle
- **Test behavior, not implementation** - Focus on outcomes
- **Use factories** - Dynamic, flexible test data
- **Keep tests fast** - Use `build` over `create` when possible
- **Use descriptive names** - Clear test intentions
- **Test edge cases** - Nil values, empty collections, boundaries
- **Mock external services** - Don't hit real APIs in tests
- **Use shared examples** - DRY up common test patterns
- **Test callbacks** - Ensure side effects work
- **Test validations** - All validation rules
- **Use transactions** - Fast database cleanup
- **Test permissions** - Authorization logic

### DON'T

- **Don't test Rails internals** - Trust the framework
- **Don't test third-party gems** - Trust the library
- **Don't ignore flaky tests** - Fix or remove them
- **Don't over-mock** - Use real objects when fast enough
- **Don't test private methods** - Test public interface
- **Don't leave pending tests** - Complete or remove
- **Don't use sleep** - Use proper waits in system tests
- **Don't test implementation details** - Test behavior
- **Don't create brittle tests** - Avoid tight coupling
- **Don't skip test database setup** - Maintain schema

## Quick Reference

### Common Matchers

```ruby
# Equality
expect(value).to eq(expected)
expect(value).to be_truthy
expect(value).to be_nil

# Collections
expect(array).to include(item)
expect(array).to match_array([1, 2, 3])
expect(array).to be_empty

# Strings
expect(string).to start_with("prefix")
expect(string).to end_with("suffix")
expect(string).to match(/regex/)

# Numbers
expect(number).to be > 10
expect(number).to be_between(1, 10)

# Changes
expect { action }.to change { object.attribute }.from(old).to(new)
expect { action }.to change { Model.count }.by(1)

# Errors
expect { action }.to raise_error(ErrorClass)
expect { action }.not_to raise_error

# Jobs
expect { action }.to have_enqueued_job(JobClass)
expect { action }.to have_enqueued_job(JobClass).with(args)

# HTTP
expect(response).to have_http_status(:success)
expect(response).to redirect_to(path)
expect(response).to render_template(:template)
```

### Factory Usage

```ruby
# Build (in memory)
user = build(:user)

# Create (save to database)
user = create(:user)

# Build with stubbed persistence
user = build_stubbed(:user)

# With traits
user = create(:user, :admin, :with_posts)

# With overrides
user = create(:user, email: "specific@example.com")

# Create multiple
users = create_list(:user, 5)
users = create_list(:user, 3, :admin)

# Build associations
post = create(:post, user: user)
```

### Capybara Commands

```ruby
# Navigation
visit path
click_link "Link Text"
click_button "Button Text"

# Forms
fill_in "Field Name", with: "value"
check "Checkbox"
uncheck "Checkbox"
choose "Radio Button"
select "Option", from: "Select"
attach_file "File", "path/to/file"

# Assertions
expect(page).to have_content("text")
expect(page).to have_css(".class")
expect(page).to have_link("Link")
expect(page).to have_button("Button")
expect(page).to have_field("Field")
expect(page).to have_current_path(path)

# JavaScript
accept_confirm { action }
dismiss_confirm { action }
accept_alert { action }

# Waiting
expect(page).to have_content("text", wait: 5)
```

## Summary

Rails TDD combines RSpec, FactoryBot, and Capybara for comprehensive testing. Follow the Red-Green-Refactor cycle, test at multiple levels (models, controllers, requests, system), maintain high coverage (80%+), test background jobs and mailers, and keep tests fast and maintainable. Write tests first to drive implementation and ensure code quality.
