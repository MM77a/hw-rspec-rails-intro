# Getting Started

## Key concept: the code we wish we had

We will write unit and module-level tests using RSpec.  (RSpec can also be used for integration tests, but we prefer Cucumber for that task since it facilitates dialogue with the customer and automates acceptance as well as integration tests.)  RSpec is a domain-specific language (DSL) for testing Ruby code.  A DSL is a small programming language designed to ease tackling problems within a single area (domain) at the expense of generality.  You've already seen examples of external (standalone) DSLs, such as HTML for describing Web pages. RSpec is an _internal_ or _embedded_ DSL: RSpec code is just Ruby code, but takes advantage of Ruby's features and syntax so as to make up a "mini-language" focused on the job of testing.  Regular expressions are another example of an internal DSL embedded in Ruby.

RSpec's facilities help us capture _expectations_ of how our code should behave.  Such tests are executable specifications or "specs" written in Ruby, hence the name RSpec.

As the text notes, to capture expectations in tests before there is any code to be tested, we write a test that exercises the _code we wish we had_. This step forces us to think not only about what the code will do, but how it will be used by its callers and collaborators (other pieces of code that have to work with it).


In the rest of this exercise we will use TDD to develop the RottenPotatoes functionality that allows a user to look up a movie in TMDb.  Specifically, we will use TDD to create the controller method, which receives the user's request, and the model method, which actually calls the remote TMDb service to get information about the specified movie.

## Setup
If your course staff created a repository for you for this assignment, clone that one, using the URL they gave you:

```
git clone <YOUR_REPO_URL> rspec-rails-intro
cd rspec-rails-intro
```

Otherwise, start from the starter code at [`https://github.com/saasbook/hw-rspec-rails-intro`](https://github.com/saasbook/hw-rspec-rails-intro): make your own **private** repository from that template (you'll be committing an API key to it), and clone that. Or, if you are not pushing your changes to GitHub, clone the template directly:

```
git clone https://github.com/saasbook/hw-rspec-rails-intro.git rspec-rails-intro
cd rspec-rails-intro
```

This is the RottenPotatoes app you finished in CHIPS 5.3, upgraded to Rails 7.1 and Ruby 3.3 (see `.ruby-version`). Run `bundle config set without 'production'` (once; Bundler remembers it for this project), then `bundle install` to set up all the dependencies.

Onwards! In this assignment we will be working with the TMDb API and Guard to automate our workflow. We also make use of [Faraday](https://github.com/lostisland/faraday) - an HTTP client library - to make API calls. So, go ahead and edit the `Gemfile` to include the following gems:

```ruby
gem 'faraday', '~> 2.12'  # in main group; simplifies calling TMDb
group :test do
  gem 'rails-controller-testing'  # assigns() and render_template in controller specs
  gem 'guard-rspec'               # automates re-running tests
end
```

* Rerun `bundle install` to get the gems.  Then run `bundle exec rails generate rspec:install` to create `.rspec`, `spec/spec_helper.rb`, and `spec/rails_helper.rb`, the files RSpec needs.

* The `debug` gem is already in the Gemfile: put `debugger` on any line of your code or specs to stop there and get a debugger prompt while getting tests working.

* Later we will introduce the Guard tool as a way to re-run tests automatically as you code.  Run `bundle exec guard init rspec` to setup the files necessary for Guard, which will result in a new `Guardfile` being created; add that file to your repo.

* Setup the database with the usual commands:

```
bundle exec rails db:prepare
```

(`db:prepare` creates the database, loads the schema, and seeds it with movies.)

* Use this command whenever you want to run the server:

```
bundle exec rails server -b 0.0.0.0
```

---

[← Intro to RSpec and TDD](01-Intro-to-RSpec-and-TDD.md) | [Contents](README.md) | [Part 1: TDD drives creating route, view, and controller method →](03-Part-1--TDD-drives-creating-route--view--and-controller-method.md)
