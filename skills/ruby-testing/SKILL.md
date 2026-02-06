---
name: ruby-testing
description: Ruby testing patterns with RSpec and Minitest, including mocking, test data, TDD workflow, and async testing strategies
---

# Ruby Testing Patterns

Comprehensive Ruby testing patterns covering RSpec and Minitest frameworks for writing maintainable, reliable tests following TDD methodology.

## When to Activate

- Writing new Ruby classes or methods
- Adding test coverage to existing Ruby code
- Setting up test frameworks for Ruby projects
- Following TDD workflow in Ruby applications
- Testing Rails applications or Ruby libraries

## RSpec Structure and Best Practices

### Core RSpec Concepts

RSpec uses a behavior-driven development (BDD) syntax with `describe`, `context`, and `it` blocks:

```ruby
# spec/calculator_spec.rb
require 'spec_helper'

RSpec.describe Calculator do
  # describe - groups related tests for a class/module
  describe '#add' do
    # context - describes a specific scenario
    context 'with positive numbers' do
      # it - defines a single test case
      it 'returns the sum' do
        calculator = Calculator.new
        result = calculator.add(2, 3)
        expect(result).to eq(5)
      end
    end

    context 'with negative numbers' do
      it 'returns the correct sum' do
        calculator = Calculator.new
        result = calculator.add(-1, -2)
        expect(result).to eq(-3)
      end
    end

    context 'with zero' do
      it 'returns the other number' do
        calculator = Calculator.new
        expect(calculator.add(5, 0)).to eq(5)
        expect(calculator.add(0, 3)).to eq(3)
      end
    end
  end

  describe '#divide' do
    it 'returns the quotient' do
      calculator = Calculator.new
      expect(calculator.divide(10, 2)).to eq(5)
    end

    context 'when dividing by zero' do
      it 'raises a ZeroDivisionError' do
        calculator = Calculator.new
        expect { calculator.divide(10, 0) }.to raise_error(ZeroDivisionError)
      end
    end
  end
end
```

### RSpec Subject and Let

Use `subject` and `let` for DRY test code:

```ruby
RSpec.describe User do
  # subject - the main object under test
  subject(:user) { User.new(name: 'Alice', email: 'alice@example.com') }

  # let - lazy-evaluated variable (only created when used)
  let(:admin) { User.new(name: 'Bob', role: 'admin') }

  # let! - eager evaluation (created before each test)
  let!(:saved_user) { User.create(name: 'Charlie', email: 'charlie@example.com') }

  describe '#full_profile' do
    it 'includes name and email' do
      expect(user.full_profile).to include('Alice', 'alice@example.com')
    end
  end

  describe '#admin?' do
    context 'when user is admin' do
      subject(:user) { admin }

      it 'returns true' do
        expect(user.admin?).to be true
      end
    end

    context 'when user is not admin' do
      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end
end
```

### Before and After Hooks

```ruby
RSpec.describe Database do
  # Runs before each test in this describe block
  before(:each) do
    @connection = Database.connect
  end

  # Runs after each test
  after(:each) do
    @connection.close
  end

  # Runs once before all tests in this describe block
  before(:all) do
    @test_db = setup_test_database
  end

  # Runs once after all tests
  after(:all) do
    @test_db.teardown
  end

  # around - wraps each test
  around(:each) do |example|
    Database.transaction do
      example.run
      raise ActiveRecord::Rollback # Rollback after each test
    end
  end

  it 'performs a query' do
    result = @connection.query('SELECT 1')
    expect(result).not_to be_nil
  end
end
```

### RSpec Matchers

```ruby
RSpec.describe 'RSpec Matchers' do
  describe 'Equality matchers' do
    it 'uses eq for value equality' do
      expect(1 + 1).to eq(2)
    end

    it 'uses eql for value and type equality' do
      expect(2.0).not_to eql(2)
      expect(2).to eql(2)
    end

    it 'uses equal for object identity' do
      a = 'hello'
      b = a
      expect(a).to equal(b)
      expect(a).not_to equal('hello') # Different object
    end
  end

  describe 'Comparison matchers' do
    it 'checks greater than' do
      expect(5).to be > 3
      expect(5).to be >= 5
    end

    it 'checks less than' do
      expect(3).to be < 5
      expect(3).to be <= 3
    end

    it 'checks between' do
      expect(5).to be_between(1, 10).inclusive
      expect(5).to be_between(1, 10).exclusive
    end
  end

  describe 'Type matchers' do
    it 'checks class type' do
      expect('hello').to be_a(String)
      expect(123).to be_an(Integer)
      expect([1, 2]).to be_an_instance_of(Array)
    end

    it 'checks for nil' do
      expect(nil).to be_nil
      expect('text').not_to be_nil
    end

    it 'checks truthiness' do
      expect(true).to be_truthy
      expect(false).to be_falsey
      expect(nil).to be_falsey
      expect(0).to be_truthy # 0 is truthy in Ruby
    end
  end

  describe 'Collection matchers' do
    it 'checks inclusion' do
      expect([1, 2, 3]).to include(2)
      expect([1, 2, 3]).to include(1, 3)
      expect({ a: 1, b: 2 }).to include(a: 1)
    end

    it 'checks array contents' do
      expect([1, 2, 3]).to match_array([3, 2, 1]) # Order doesn't matter
      expect([1, 2, 3]).to eq([1, 2, 3]) # Order matters
      expect([1, 2, 3]).to contain_exactly(3, 2, 1)
    end

    it 'checks emptiness' do
      expect([]).to be_empty
      expect([1]).not_to be_empty
    end
  end

  describe 'String matchers' do
    it 'checks string content' do
      expect('hello world').to start_with('hello')
      expect('hello world').to end_with('world')
      expect('hello world').to match(/wo\w+d/)
    end
  end

  describe 'Error matchers' do
    it 'checks for raised errors' do
      expect { 1 / 0 }.to raise_error(ZeroDivisionError)
      expect { raise 'boom' }.to raise_error('boom')
      expect { raise ArgumentError, 'bad arg' }.to raise_error(ArgumentError, /bad/)
    end
  end

  describe 'Change matchers' do
    it 'checks for state changes' do
      array = []
      expect { array << 1 }.to change { array.size }.from(0).to(1)
      expect { array << 2 }.to change { array.size }.by(1)
    end
  end

  describe 'Predicate matchers' do
    it 'converts predicates to matchers' do
      expect([]).to be_empty # Calls .empty?
      expect(0).to be_zero # Calls .zero?
      expect(nil).to be_nil # Calls .nil?
    end

    it 'uses have_ for collection predicates' do
      expect([1, 2, 3]).to have_attributes(size: 3)
    end
  end
end
```

### Shared Examples

```ruby
# spec/support/shared_examples/searchable.rb
RSpec.shared_examples 'searchable' do
  describe '#search' do
    it 'finds matching records' do
      expect(described_class.search('test')).to include(matching_record)
    end

    it 'returns empty array when no matches' do
      expect(described_class.search('nonexistent')).to be_empty
    end
  end
end

# spec/models/user_spec.rb
RSpec.describe User do
  let(:matching_record) { User.create(name: 'test user') }

  it_behaves_like 'searchable'
end

# spec/models/post_spec.rb
RSpec.describe Post do
  let(:matching_record) { Post.create(title: 'test post') }

  it_behaves_like 'searchable'
end

# Shared context
RSpec.shared_context 'with authenticated user' do
  let(:user) { create(:user) }
  let(:auth_token) { generate_token(user) }

  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
  end
end

# Usage
RSpec.describe PostsController do
  include_context 'with authenticated user'

  it 'allows post creation' do
    post :create, params: { post: { title: 'Test' } }
    expect(response).to have_http_status(:created)
  end
end
```

## Minitest Patterns

### Basic Minitest Structure

```ruby
# test/calculator_test.rb
require 'minitest/autorun'

class CalculatorTest < Minitest::Test
  def setup
    @calculator = Calculator.new
  end

  def teardown
    # Cleanup after each test
  end

  def test_add_positive_numbers
    result = @calculator.add(2, 3)
    assert_equal 5, result
  end

  def test_add_negative_numbers
    result = @calculator.add(-1, -2)
    assert_equal(-3, result)
  end

  def test_divide_by_zero_raises_error
    assert_raises(ZeroDivisionError) do
      @calculator.divide(10, 0)
    end
  end

  def test_multiply_returns_product
    assert_equal 12, @calculator.multiply(3, 4)
  end
end
```

### Minitest Spec Style (RSpec-like syntax)

```ruby
require 'minitest/autorun'

describe Calculator do
  before do
    @calculator = Calculator.new
  end

  describe '#add' do
    it 'adds two positive numbers' do
      _(@calculator.add(2, 3)).must_equal 5
    end

    it 'adds negative numbers' do
      expect(@calculator.add(-1, -2)).must_equal(-3)
    end
  end

  describe '#divide' do
    it 'raises error when dividing by zero' do
      _ { @calculator.divide(10, 0) }.must_raise ZeroDivisionError
    end
  end
end
```

### Minitest Assertions

```ruby
class AssertionsTest < Minitest::Test
  def test_equality
    assert_equal 4, 2 + 2
    refute_equal 5, 2 + 2
  end

  def test_nil
    assert_nil nil
    refute_nil 'value'
  end

  def test_inclusion
    assert_includes [1, 2, 3], 2
    refute_includes [1, 2, 3], 4
  end

  def test_match
    assert_match(/hello/, 'hello world')
    refute_match(/goodbye/, 'hello world')
  end

  def test_empty
    assert_empty []
    refute_empty [1]
  end

  def test_instance_of
    assert_instance_of String, 'hello'
    assert_kind_of Numeric, 42
  end

  def test_responds_to
    assert_responds_to 'string', :upcase
  end

  def test_operator
    assert_operator 5, :>, 3
    assert_operator 10, :<=, 10
  end

  def test_raises
    assert_raises(ArgumentError) { raise ArgumentError }
  end

  def test_silent
    assert_silent { 1 + 1 }
  end

  def test_output
    assert_output("Hello\n") { puts 'Hello' }
  end
end
```

### When to Use RSpec vs Minitest

**Use RSpec when:**
- Building Rails applications (most common convention)
- Team prefers BDD-style syntax
- Need extensive mocking capabilities out of the box
- Want rich matcher library and extensive ecosystem
- Working on projects with existing RSpec suites

**Use Minitest when:**
- Building Ruby libraries
- Want minimal dependencies (ships with Ruby)
- Prefer simpler, more Ruby-like test syntax
- Need faster test suite performance
- Want lower memory footprint
- Following Rails defaults (Rails 4+ uses Minitest by default)

## Test Organization

### RSpec Directory Structure

```
spec/
├── spec_helper.rb           # RSpec configuration
├── rails_helper.rb          # Rails-specific configuration (if using Rails)
├── support/                 # Shared helpers and configurations
│   ├── factory_bot.rb
│   ├── database_cleaner.rb
│   └── shared_examples/
│       └── searchable.rb
├── models/                  # Model tests
│   ├── user_spec.rb
│   └── post_spec.rb
├── controllers/             # Controller tests
│   └── posts_controller_spec.rb
├── services/                # Service object tests
│   └── user_registration_spec.rb
├── lib/                     # Library code tests
│   └── calculator_spec.rb
├── requests/                # API/Integration tests
│   └── api/
│       └── users_spec.rb
├── features/                # Feature/Acceptance tests (with Capybara)
│   └── user_login_spec.rb
└── system/                  # System tests (Rails 5.1+)
    └── user_signup_spec.rb
```

### Minitest Directory Structure

```
test/
├── test_helper.rb           # Test configuration
├── support/                 # Shared helpers
│   └── factory_helper.rb
├── models/                  # Model tests
│   ├── user_test.rb
│   └── post_test.rb
├── controllers/             # Controller tests
│   └── posts_controller_test.rb
├── integration/             # Integration tests
│   └── user_login_test.rb
├── lib/                     # Library code tests
│   └── calculator_test.rb
└── fixtures/                # Test data (if using fixtures)
    ├── users.yml
    └── posts.yml
```

### Test Naming Conventions

```ruby
# RSpec - use descriptive strings
RSpec.describe User do
  describe '.find_by_email' do
    context 'when email exists' do
      it 'returns the user' do
      end
    end

    context 'when email does not exist' do
      it 'returns nil' do
      end
    end
  end
end

# Minitest - use test_ prefix
class UserTest < Minitest::Test
  def test_find_by_email_when_email_exists
    # ...
  end

  def test_find_by_email_when_email_does_not_exist
    # ...
  end
end
```

## Mocking and Stubbing

### RSpec Mocks

```ruby
RSpec.describe UserService do
  describe '#send_welcome_email' do
    it 'sends email via mailer' do
      user = User.new(email: 'test@example.com')
      mailer = instance_double(UserMailer)

      # Stub method call
      allow(UserMailer).to receive(:new).and_return(mailer)
      allow(mailer).to receive(:send_welcome)

      service = UserService.new
      service.send_welcome_email(user)

      # Verify method was called
      expect(mailer).to have_received(:send_welcome).with(user)
    end
  end

  describe '#process_payment' do
    it 'charges the credit card' do
      payment_gateway = instance_double(PaymentGateway)

      # Stub with return value
      allow(payment_gateway).to receive(:charge).and_return(
        { success: true, transaction_id: '123' }
      )

      service = UserService.new(payment_gateway: payment_gateway)
      result = service.process_payment(100)

      expect(result[:success]).to be true
      expect(payment_gateway).to have_received(:charge).with(100)
    end

    it 'handles payment failure' do
      payment_gateway = instance_double(PaymentGateway)

      # Stub to raise error
      allow(payment_gateway).to receive(:charge).and_raise(PaymentError, 'Card declined')

      service = UserService.new(payment_gateway: payment_gateway)

      expect {
        service.process_payment(100)
      }.to raise_error(PaymentError, 'Card declined')
    end
  end
end
```

### Test Doubles

```ruby
# Double - generic test double
double = double('user', name: 'Alice', email: 'alice@example.com')
expect(double.name).to eq('Alice')

# Instance double - verifies methods exist on class
user = instance_double(User, name: 'Bob', email: 'bob@example.com')
# This would raise error if User doesn't have save method:
allow(user).to receive(:save).and_return(true)

# Class double - for class methods
user_class = class_double(User)
allow(user_class).to receive(:find).with(1).and_return(user)

# Object double - wraps real object
real_user = User.new(name: 'Charlie')
user_double = object_double(real_user, name: 'Charlie')

# Spy - records all method calls
user_spy = spy('user')
service = UserService.new(user: user_spy)
service.update_profile(name: 'New Name')
expect(user_spy).to have_received(:update).with(name: 'New Name')

# Partial stubbing - stub some methods on real object
user = User.new(name: 'Alice')
allow(user).to receive(:save).and_return(true)
# Other methods work normally
expect(user.name).to eq('Alice')
```

### Minitest Mocks

```ruby
require 'minitest/mock'

class UserServiceTest < Minitest::Test
  def test_sends_welcome_email
    user = User.new(email: 'test@example.com')
    mailer = Minitest::Mock.new

    # Expect method call
    mailer.expect(:send_welcome, nil, [user])

    service = UserService.new(mailer: mailer)
    service.send_welcome_email(user)

    # Verify expectations were met
    mailer.verify
  end

  def test_processes_payment
    payment_gateway = Minitest::Mock.new
    payment_gateway.expect(:charge, { success: true, id: '123' }, [100])

    service = UserService.new(payment_gateway: payment_gateway)
    result = service.process_payment(100)

    assert result[:success]
    payment_gateway.verify
  end

  def test_with_stub
    user = User.new(name: 'Alice')

    # Stub a method temporarily
    user.stub :admin?, true do
      assert user.admin?
    end

    # Original behavior restored
    refute user.admin?
  end
end
```

## Test Data with FactoryBot

### Defining Factories

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    first_name { 'John' }
    last_name { 'Doe' }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }

    # Trait for variations
    trait :admin do
      role { 'admin' }
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

  factory :post do
    title { 'Sample Post' }
    body { 'This is a sample post body' }
    association :user
    published_at { Time.now }

    trait :draft do
      published_at { nil }
    end

    trait :with_comments do
      after(:create) do |post|
        create_list(:comment, 2, post: post)
      end
    end
  end

  factory :comment do
    body { 'Great post!' }
    association :user
    association :post
  end
end
```

### Using FactoryBot

```ruby
RSpec.describe User do
  # build - builds object without saving
  let(:user) { build(:user) }

  # create - builds and saves object
  let(:saved_user) { create(:user) }

  # build_stubbed - builds object with stubbed persistence
  let(:stubbed_user) { build_stubbed(:user) }

  # create with overrides
  let(:admin) { create(:user, :admin, email: 'admin@example.com') }

  # create_list - create multiple objects
  let(:users) { create_list(:user, 5) }

  # create with traits
  let(:user_with_posts) { create(:user, :with_posts, posts_count: 10) }

  describe '#admin?' do
    it 'returns false for regular user' do
      expect(user.admin?).to be false
    end

    it 'returns true for admin user' do
      expect(admin.admin?).to be true
    end
  end

  describe '#posts' do
    it 'has associated posts' do
      expect(user_with_posts.posts.count).to eq(10)
    end
  end
end
```

### FactoryBot vs Fixtures

**FactoryBot Pros:**
- Dynamic data generation
- Easy to override attributes
- Better for complex object graphs
- Self-documenting factories
- Traits for variations

**FactoryBot Cons:**
- Slower than fixtures (database writes)
- Can lead to over-reliance on database
- Memory intensive for large test suites

**Fixtures Pros:**
- Very fast (loaded once)
- Lightweight
- Good for stable, reference data
- Built into Rails

**Fixtures Cons:**
- Static YAML files
- Hard to maintain relationships
- Difficult to customize per test
- Can create brittle tests

```ruby
# Fixtures example - test/fixtures/users.yml
alice:
  name: Alice
  email: alice@example.com
  role: admin

bob:
  name: Bob
  email: bob@example.com
  role: user

# Usage in Minitest
class UserTest < ActiveSupport::TestCase
  test "alice is admin" do
    alice = users(:alice)
    assert alice.admin?
  end
end

# Generally prefer FactoryBot for most tests
# Use fixtures only for:
# - Reference data (countries, categories)
# - Performance-critical test suites
# - Simple, stable data that doesn't change
```

## Test Coverage

### SimpleCov Configuration

```ruby
# spec/spec_helper.rb or test/test_helper.rb
require 'simplecov'

SimpleCov.start 'rails' do
  # Exclude directories from coverage
  add_filter '/spec/'
  add_filter '/test/'
  add_filter '/config/'
  add_filter '/vendor/'

  # Group coverage by type
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Services', 'app/services'
  add_group 'Libraries', 'lib'

  # Set minimum coverage thresholds
  minimum_coverage 80
  minimum_coverage_by_file 70

  # Refuse coverage below threshold
  refuse_coverage_drop :file, 5
end
```

### Coverage Expectations

| Code Type | Target Coverage |
|-----------|----------------|
| Critical business logic | 100% |
| Models and services | 90%+ |
| Controllers | 85%+ |
| Libraries | 90%+ |
| Background jobs | 85%+ |
| Views/helpers | 70%+ |

### Running Coverage Reports

```bash
# RSpec with SimpleCov
rspec

# View HTML report
open coverage/index.html

# Minitest with SimpleCov
rake test

# CI environments
COVERAGE=true bundle exec rspec
```

## TDD Workflow in Ruby

### RED-GREEN-REFACTOR Cycle

```ruby
# Step 1: RED - Write failing test first
RSpec.describe UserRegistration do
  describe '#register' do
    it 'creates a new user account' do
      registration = UserRegistration.new(
        email: 'test@example.com',
        password: 'password123'
      )

      result = registration.register

      expect(result).to be_success
      expect(User.count).to eq(1)
      expect(User.last.email).to eq('test@example.com')
    end
  end
end

# Run: rspec spec/services/user_registration_spec.rb
# Result: FAIL - UserRegistration class doesn't exist

# Step 2: GREEN - Write minimal code to pass
class UserRegistration
  def initialize(email:, password:)
    @email = email
    @password = password
  end

  def register
    User.create(email: @email, password: @password)
    Result.success
  end
end

# Run: rspec spec/services/user_registration_spec.rb
# Result: PASS

# Step 3: REFACTOR - Improve code while keeping tests green
class UserRegistration
  def initialize(email:, password:)
    @email = email
    @password = password
  end

  def register
    return Result.failure(:invalid_email) unless valid_email?
    return Result.failure(:weak_password) unless strong_password?

    user = User.create(email: @email, password: @password)
    send_welcome_email(user)

    Result.success(user: user)
  end

  private

  def valid_email?
    @email =~ URI::MailTo::EMAIL_REGEXP
  end

  def strong_password?
    @password.length >= 8
  end

  def send_welcome_email(user)
    UserMailer.welcome(user).deliver_later
  end
end

# Run tests again: PASS
# Add more tests for edge cases
```

### TDD Best Practices

```ruby
# 1. Start with the simplest test
RSpec.describe Calculator do
  it 'adds two numbers' do
    expect(Calculator.add(2, 3)).to eq(5)
  end
end

# 2. Write just enough code to pass
class Calculator
  def self.add(a, b)
    5 # Simplest implementation
  end
end

# 3. Add more specific tests
it 'adds different numbers' do
  expect(Calculator.add(1, 1)).to eq(2)
end

# 4. Now implement properly
def self.add(a, b)
  a + b
end

# 5. Test edge cases
context 'with edge cases' do
  it 'handles zero' do
    expect(Calculator.add(0, 0)).to eq(0)
  end

  it 'handles negative numbers' do
    expect(Calculator.add(-5, -3)).to eq(-8)
  end

  it 'handles large numbers' do
    expect(Calculator.add(1_000_000, 2_000_000)).to eq(3_000_000)
  end
end

# 6. Refactor with confidence
```

## Testing Asynchronous Code

### Testing Background Jobs

```ruby
# RSpec with ActiveJob
RSpec.describe SendWelcomeEmailJob do
  include ActiveJob::TestHelper

  describe '#perform' do
    it 'sends welcome email' do
      user = create(:user)

      expect {
        SendWelcomeEmailJob.perform_later(user.id)
      }.to have_enqueued_job(SendWelcomeEmailJob).with(user.id)
    end

    it 'processes job successfully' do
      user = create(:user)
      mailer = instance_double(UserMailer)
      allow(UserMailer).to receive(:welcome).and_return(mailer)
      allow(mailer).to receive(:deliver_now)

      perform_enqueued_jobs do
        SendWelcomeEmailJob.perform_later(user.id)
      end

      expect(UserMailer).to have_received(:welcome).with(user)
    end

    it 'retries on failure' do
      user = create(:user)
      allow(UserMailer).to receive(:welcome).and_raise(Net::SMTPServerBusy)

      expect {
        perform_enqueued_jobs do
          SendWelcomeEmailJob.perform_later(user.id)
        end
      }.to raise_error(Net::SMTPServerBusy)

      expect(SendWelcomeEmailJob).to have_been_enqueued.at_least(:twice)
    end
  end
end
```

### Testing with Timecop or Rails Time Helpers

```ruby
RSpec.describe Subscription do
  describe '#expired?' do
    it 'returns false when not expired' do
      subscription = create(:subscription, expires_at: 1.week.from_now)
      expect(subscription.expired?).to be false
    end

    it 'returns true when expired' do
      subscription = create(:subscription, expires_at: 1.week.ago)
      expect(subscription.expired?).to be true
    end

    # Using Rails time helpers
    it 'expires after expiration date' do
      subscription = create(:subscription, expires_at: 3.days.from_now)

      travel_to(2.days.from_now) do
        expect(subscription.expired?).to be false
      end

      travel_to(4.days.from_now) do
        expect(subscription.expired?).to be true
      end
    end
  end

  describe '.expire_today' do
    # Freeze time for consistent results
    it 'finds subscriptions expiring today' do
      freeze_time do
        expiring_today = create(:subscription, expires_at: Date.today.end_of_day)
        expiring_tomorrow = create(:subscription, expires_at: 1.day.from_now)
        expired_yesterday = create(:subscription, expires_at: 1.day.ago)

        result = Subscription.expire_today

        expect(result).to include(expiring_today)
        expect(result).not_to include(expiring_tomorrow, expired_yesterday)
      end
    end
  end
end
```

### Testing Callbacks and Observers

```ruby
RSpec.describe User do
  describe 'callbacks' do
    it 'sends welcome email after creation' do
      mailer = instance_double(UserMailer)
      allow(UserMailer).to receive(:welcome).and_return(mailer)
      allow(mailer).to receive(:deliver_later)

      user = create(:user)

      expect(UserMailer).to have_received(:welcome).with(user)
    end

    it 'generates token before validation' do
      user = build(:user, auth_token: nil)
      user.valid?
      expect(user.auth_token).not_to be_nil
    end

    it 'normalizes email before save' do
      user = create(:user, email: 'USER@EXAMPLE.COM')
      expect(user.reload.email).to eq('user@example.com')
    end
  end
end
```

### Testing Concurrent Code

```ruby
RSpec.describe Counter do
  describe 'thread safety' do
    it 'handles concurrent increments' do
      counter = Counter.new(0)
      threads = []

      10.times do
        threads << Thread.new do
          100.times { counter.increment }
        end
      end

      threads.each(&:join)
      expect(counter.value).to eq(1000)
    end
  end
end

# Testing with timeout
RSpec.describe LongRunningOperation do
  it 'completes within timeout', timeout: 5 do
    result = LongRunningOperation.execute
    expect(result).to be_success
  end
end
```

## Integration vs Unit Test Strategies

### Unit Tests

Test individual classes/methods in isolation:

```ruby
# Unit test - tests Calculator in isolation
RSpec.describe Calculator do
  describe '#add' do
    it 'returns sum of two numbers' do
      calculator = Calculator.new
      expect(calculator.add(2, 3)).to eq(5)
    end
  end
end

# Unit test with mocked dependencies
RSpec.describe OrderProcessor do
  describe '#process' do
    it 'charges customer and sends confirmation' do
      order = build(:order, total: 100)
      payment_gateway = instance_double(PaymentGateway)
      mailer = instance_double(OrderMailer)

      allow(payment_gateway).to receive(:charge).and_return(true)
      allow(mailer).to receive(:send_confirmation)

      processor = OrderProcessor.new(
        payment_gateway: payment_gateway,
        mailer: mailer
      )
      processor.process(order)

      expect(payment_gateway).to have_received(:charge).with(order.total)
      expect(mailer).to have_received(:send_confirmation).with(order)
    end
  end
end
```

### Integration Tests

Test multiple components working together:

```ruby
# Integration test - tests full workflow
RSpec.describe 'Order processing workflow' do
  it 'processes order from creation to fulfillment' do
    user = create(:user, email: 'customer@example.com')
    product = create(:product, price: 50)

    # Create order
    order = Order.create(user: user, items: [product])
    expect(order).to be_pending

    # Process payment
    payment_result = PaymentService.new.process(order)
    expect(payment_result).to be_success
    expect(order.reload).to be_paid

    # Fulfill order
    FulfillmentService.new.ship(order)
    expect(order.reload).to be_shipped

    # Check email sent
    expect(ActionMailer::Base.deliveries.last.to).to include('customer@example.com')
  end
end

# Rails request spec (integration test)
RSpec.describe 'Users API' do
  describe 'POST /api/users' do
    it 'creates new user and returns user data' do
      post '/api/users', params: {
        user: {
          email: 'test@example.com',
          password: 'password123'
        }
      }, headers: { 'Content-Type': 'application/json' }

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['email']).to eq('test@example.com')
      expect(User.last.email).to eq('test@example.com')
    end
  end
end
```

### Test Strategy Guidelines

**Unit Tests (70-80% of tests):**
- Fast execution
- Test single responsibility
- Mock external dependencies
- Test edge cases and error conditions
- Run frequently during development

**Integration Tests (15-25% of tests):**
- Test component interactions
- Use real database (with cleanup)
- Test critical user workflows
- Fewer mocks
- Run before commits

**System/E2E Tests (5-10% of tests):**
- Test from user perspective
- Use real browser (Capybara/Selenium)
- Test happy paths
- Expensive to run and maintain
- Run in CI pipeline

```ruby
# Test pyramid in practice
# spec/
#   models/           (Unit tests - 40%)
#   services/         (Unit tests - 30%)
#   lib/              (Unit tests - 10%)
#   requests/         (Integration tests - 15%)
#   system/           (E2E tests - 5%)

# Fast feedback loop:
# 1. Run unit tests: rspec spec/models spec/services --tag ~slow
# 2. Run integration tests: rspec spec/requests
# 3. Run full suite: rspec
```

## Best Practices

**DO:**
- Write tests FIRST (TDD)
- Keep tests simple and focused
- Use descriptive test names
- Test behavior, not implementation
- Use factories over fixtures
- Clean up test data (DatabaseCleaner, transactions)
- Run tests frequently
- Keep test suite fast (< 5 minutes for full suite)
- Use shared examples for common behavior
- Test happy path AND error cases

**DON'T:**
- Test private methods directly
- Use sleep in tests (use proper waits/stubs)
- Create brittle tests coupled to implementation
- Ignore flaky tests
- Over-mock (prefer real objects when fast enough)
- Test framework code (Rails, gems)
- Leave commented-out test code
- Create test data in before(:all) blocks

## Running Tests

```bash
# RSpec commands
rspec                                    # Run all specs
rspec spec/models                        # Run specific directory
rspec spec/models/user_spec.rb           # Run specific file
rspec spec/models/user_spec.rb:23        # Run specific line
rspec --tag focus                        # Run focused specs
rspec --tag ~slow                        # Exclude slow specs
rspec --format documentation             # Verbose output
rspec --profile                          # Show slowest examples
rspec --fail-fast                        # Stop on first failure
rspec --only-failures                    # Run only failed specs

# Minitest commands
rake test                                # Run all tests
ruby test/models/user_test.rb            # Run specific file
rake test TEST=test/models/user_test.rb  # Run with rake
rake test:models                         # Run model tests
rake test TESTOPTS="-v"                  # Verbose output
rake test TESTOPTS="--name=/user/"       # Run tests matching pattern

# With coverage
COVERAGE=true rspec
COVERAGE=true rake test

# With Spring for faster startup
spring rspec
spring rake test

# Parallel execution
parallel_rspec spec/
parallel_test test/
```

## Summary

Ruby testing combines powerful frameworks (RSpec, Minitest) with excellent tooling (FactoryBot, SimpleCov) to enable comprehensive test coverage. Key principles:

1. **Follow TDD** - Write tests first, code second
2. **Choose appropriate framework** - RSpec for BDD, Minitest for simplicity
3. **Organize tests logically** - Mirror application structure
4. **Use test data effectively** - FactoryBot for flexibility
5. **Mock judiciously** - Balance isolation with integration
6. **Maintain high coverage** - Aim for 80%+ overall
7. **Test asynchronously** - Handle time, jobs, callbacks
8. **Balance test types** - Mostly unit, some integration, few E2E
9. **Keep tests fast** - Fast feedback enables TDD
10. **Write maintainable tests** - Tests are code too

Remember: Good tests are your safety net for refactoring and your documentation for how code should behave.
