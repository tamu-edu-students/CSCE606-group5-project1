# CSCE606-group5-project1
This project is a group web application developed for a graduate level Software Engineering course at Texas A&amp;M University. It aims to help students organize their daily study routines with a special focus on integrating LeetCode problem solving into their schedule.

📅 Core Features (Planned):

- Daily and weekly task planner
- Integration with LeetCode to schedule coding problems
- Progress tracking and productivity insights
- User-friendly dashboard tailored for students

---

## 🚀 Setup Instructions

Follow these steps to set up and run the project locally.

### 1. Install PostgreSQL (version 14 recommended)

If you don’t have PostgreSQL installed, here’s how to install version 14 on macOS using Homebrew:

```bash
brew update
brew install postgresql@14
brew services start postgresql@14
```
### 2. Clone the repository
```bash
git clone git@github.com:tamu-edu-students/CSCE606-group5-project1.git
cd CSCE606-group5-project1
```

### 3. Install dependencies
Make sure you have Ruby and Bundler installed. Then run:
```bash
bundle install
```

### 4. Setup the database and run migrations
Create and migrate the database with:
```bash
bin/rails db:create
bin/rails db:migrate
```

### 5. Start the Rails server
Run the Rails server locally:
```bash
bin/dev
```
Open your browser and navigate to:
```bash
http://localhost:3000
---

## 📧 Weekly Progress Summary Email

The application includes an automated weekly email feature that sends progress summaries to active students.

### Running the Weekly Report Locally

To manually trigger the weekly report email task:

```bash
bundle exec rake weekly_report:send
```

This will:
- Identify all active users with registered email addresses
- Compute their weekly statistics
- Send personalized progress summary emails

### Heroku Scheduler Setup

For production deployment on Heroku, set up a scheduled job to run weekly:

1. Install the Heroku Scheduler add-on:
   ```bash
   heroku addons:create scheduler:standard
   ```

2. Open the Heroku Scheduler dashboard:
   ```bash
   heroku addons:open scheduler
   ```

3. Create a new job with:
   - **Task**: `rake weekly_report:send`
   - **Frequency**: Weekly
   - **Next Due**: Sunday at 23:55 (app timezone)

### Email Content

The weekly summary email includes:
- Number of problems solved this week
- Current consecutive practice streak (in days)
- Total problems solved to date
- Highlights (longest historical streak and hardest problem solved this week)

### Demo Data

To populate demo data for testing the weekly report:

```bash
bin/rails db:seed
```

This creates sample users, problems, and solved problem records spanning multiple weeks.

### Seed Leetcode Problems

To populate leetcode problems from API

```bash
bin/rails leet_code:seed
---

## 📊 LeetCode Statistics

The Statistics page displays LeetCode solved problem counts for users who have set their LeetCode username in their profile.

### Configuration

Set the `LEETCODE_API_BASE` environment variable to the API base URL (default: `https://alfa-leetcode-api.onrender.com`).

### Features

- Fetches solved problem counts (total, easy, medium, hard) from the alfa-leetcode-api
- Displays stats in a clean grid layout using existing CSS
- Caches API responses for 10 minutes
- Shows zero counts if no username is set or API fails

### API Endpoint Used

- `GET /:username/solved` - Returns problem counts by difficulty
```