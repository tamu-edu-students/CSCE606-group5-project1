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
rails db:create
rails db:migrate
```

### 5. Start the Rails server
Run the Rails server locally:
```bash
rails server
```
Open your browser and navigate to:
```bash
http://localhost:3000
```