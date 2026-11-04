# Submission Instructions

You will be tested on both correctness and testability of your app. Each team member, even if pair programming for this assignment, should complete a deploy and submit the link for their own personal app individually.

## Deploying

Deploy your app to Render or Heroku, as in CHIPS 5.3, with a PostgreSQL production database. This repo is already set up for that: `config/database.yml` points production at the database in `DATABASE_URL`, the `pg` gem is in the Gemfile's `production` group, and `bin/render-build.sh` is the build script for Render. Commit and push your work first, including `Gemfile.lock` (Render installs exactly the gems it lists, so run `bundle install` and commit the lockfile after adding gems), because the app is deployed from your repo.

Your deployed app calls TMDb with the API key in `find_in_tmdb`, so make sure the code you deploy has your working key (or, if you read it from an environment variable such as `TMDB_API_KEY`, set that variable on your app too).

### Render

1. In the [Render Dashboard](https://dashboard.render.com/), click **New +** and select **Postgres**. Give it a **Name** (e.g. `chip-8-5-YOUR_NAME`), choose the **Free** plan, and click **Create Database**. Once it is "Available", copy its **internal** connection URL (the one starting with `postgresql://` under "Internal").
2. Click **New +**, select **Web Service**, and connect the GitHub repo for this assignment. Use these settings:
   * **Language:** `Ruby`
   * **Branch:** the branch you are deploying, e.g. `main`
   * **Build Command:** `./bin/render-build.sh`
   * **Start Command:** `bundle exec rails server`
   * **Instance Type:** `Free`
3. Under **Environment Variables**, add:
   * `DATABASE_URL` = the internal connection URL from step 1
   * `SECRET_KEY_BASE` = click **Generate** for a random value. Rails will not boot in production without a secret, and it reads this one instead of a `config/master.key`.
4. Click **Deploy Web Service**. Every deploy migrates the database and, while it is still empty, seeds it. From then on, pushing to that branch redeploys the app.

### Heroku

Heroku sets `SECRET_KEY_BASE` for you, and usually attaches a PostgreSQL database when it detects the `pg` gem; if `heroku addons -a <YOUR_APP_NAME>` lists none, run `heroku addons:create heroku-postgresql -a <YOUR_APP_NAME>`. Add your app as a git remote and push, as in CHIPS 5.3:

```sh
heroku git:remote -a <YOUR_APP_NAME>
git push heroku <YOUR_BRANCH>:main
heroku run rails db:migrate db:seed -a <YOUR_APP_NAME>
```

If you are deploying to Heroku with an app you already pushed a different repo to (such as your CHIPS 5.3 app), Heroku will reject the push because the histories differ; add `--force` to the `git push` to replace that code with this repo's.

## Submitting

Once you are confident the functionality works correctly on your deployed app, submit its URL in `rottenpotatoes-url.txt`, the text file at the top level of your app, with no other contents. Submit the URL exactly as your browser shows it, e.g. `https://your-app.onrender.com` (on Heroku, `https://your-app.herokuapp.com`). Either `https://` or `http://` works; the autograder falls back to `http://` if it cannot connect over `https://`. On Render, free services sleep after 15 minutes of inactivity and take about a minute to wake up, so **open your app in a browser right before you submit**.

On Gradescope, submit your whole app (a zip of your repo, or your GitHub repo) together with `rottenpotatoes-url.txt`. The autograder runs the same tests twice, worth 25 points each (50 in total):

1. **Deployed app:** against the app at the URL in `rottenpotatoes-url.txt`.
2. **Local app:** against the code you submitted, which the autograder sets up with `bin/rails db:prepare` and starts itself with `bin/rails server`.

A missing deployment, or a repo that will not start, therefore costs you only that half. Before you submit, check that a clean clone of your repo runs with `bin/rails db:prepare` followed by `bin/rails server`.

The autograder lists every test with its score, and says what it expected when a test fails, but to track down why your app fails a test, write your own specs. Looking into the TMDb API more thoroughly and fuzz testing could be good approaches to finding bugs in your app.

When the autograder runs your code itself (the **Local app** tests), its TMDb searches are answered from TMDb responses recorded in advance, so those tests do not depend on your API key or on TMDb being up. Your deployed app is tested against the live TMDb API with your own key, so make sure the key on your deployed app works.

The tests add movies from TMDb to your app's database, so **running the autograder will make changes to your deployed app's database** (the local pass always starts from a fresh database). That does not affect your grade on later submissions, but if you want your deployed app's movie list back to its seed data, reset its database.

On Render, the free tier gives you no production shell, so reset the data from the build phase instead: temporarily add this line to `bin/render-build.sh`, push to trigger a deploy, then take it out again.

```sh
bundle exec rails runner 'Movie.delete_all; Rails.application.load_seed'
```

On Heroku:

```sh
heroku pg:reset DATABASE_URL -a <YOUR_APP_NAME> --confirm <YOUR_APP_NAME>
heroku run rails db:schema:load db:seed -a <YOUR_APP_NAME>
```

> **Submission (50 points)**
>
> You should now be ready to submit your assignment. Remember to run your test cases once more, then submit your files to Gradescope, Codio or whichever platform your course is using.

---

[← Part 5: Implementing find_in_tmdb, and Stubbing the Internet](07-Part-5--Implementing-find-in-tmdb--and-Stubbing-the-Internet.md) | [Contents](README.md)
