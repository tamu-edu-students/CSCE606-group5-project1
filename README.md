LeetPlanner
Your Personal Productivity Companion

This project is a group web application developed for CSCE 606 (Software Engineering) at Texas A&M University.
It aims to help students organize their daily study routines with a special focus on integrating LeetCode problem solving into their schedule.

Core Features
Daily and Weekly Task Planner – create, edit, and manage personal schedules
LeetCode Tracker – log problems solved daily with difficulty and tags
Progress Dashboard – weekly coding statistics and productivity insights
User-Friendly Interface – clean dashboard tailored for students

Agile Development Plan
We are following Agile (Scrum) methodology with 2 sprints to deliver the project before the deadline (Oct 3rd, 2025).

Sprint 1 (Sept 15 – Sept 23): Foundation + Core Features
Goals:

Set up repository, CI/CD, branch protection
Implement user authentication
Build core models (Users, Events, LeetCodeEntries)
Event CRUD (create/read/update/delete)
LeetCodeEntry CRUD (problem name, difficulty, date solved)
Initial acceptance + unit tests (~60–70% coverage)
Draft documentation (README setup + architecture diagram)
Deliverables:

Repo + CI pipeline
Authentication + Calendar CRUD + LeetCode logging working
≥10 user stories in repo
Initial Cucumber + RSpec tests

Sprint 2 (Sept 24 – Oct 2): Advanced Features + Final Polish
Goals:

Weekly stats dashboard (charts/summary)
Filtering & tagging for events/problems
Error handling + UI polish
Documentation (Technical Guide, User Guide, Architecture diagram)
Finalize user stories (≥20 total, SMART/INVEST)
Achieve ≥90% test coverage (acceptance + unit tests)
Deliverables:

Fully functional calendar + LeetCode tracker
Weekly progress insights working
Export feature available
Documentation completed in README.md / docs/
All commits & PRs following standards
User Stories (SMART & INVEST)
Authentication & User Flow
As a visitor, I want to log in via Google OAuth so that I don’t need to create a new account manually. Points: 2
As a user, I want the login screen to be styled nicely so that the UI is pleasant and consistent.Points: 1
As a system, I want to set up the initial repository structure (directories, configuration) so that development starts cleanly.Points: 2
Dashboard / Timer / Core UI
As a user, I want to see a dashboard timer showing time elapsed or remaining so I can track progress. Points: 1
As a developer, I want to refactor the dashboard codebase so that it is cleaner, more maintainable, and easier to extend. Points: 1
As a user, I want the “current event logic” (which event is active) to work correctly so that the dashboard reflects what I’m doing now. Points: 2
Calendar & Event Management
As a user, I want the calendar UI to be polished and visually clear so I can easily see events. Points: 3
As a user, I want to perform CRUD (create, read, update, delete) operations on events in the app so I can manage my schedule. Points: 3
As a user, I want events in my app to sync to my Google Calendar so that my calendars stay up to date. Points: 2
As a user, I want the app to seed initial calendar events (from Google) into my local DB so that I see existing events when I start. Points: 2
LeetCode / Problem Integration
As a system, I want to seed the database with LeetCode problems so that there is initial data to work with. Points: 2
As a user, I want to assign LeetCode problems to calendar events so that I can schedule when to solve which problem. Points: 1
As a user, I want CRUD operations for LeetCode problems in-app (add, view, update, delete) so that I can manage my problem list. Points: 2
Statistics & Emails
As a user, I want to fetch statistics from LeetCode’s API (e.g. solves, last submission) so that I can see my performance. Points: 2
As a user, I want to see those statistics in styled UI (charts, tables) so that I can understand them easily. Points: 1
As a user, I want to receive a weekly email summarizing my progress so that I stay motivated and informed. Points: 2
Profile, Testing, Documentation & Misc
As a user, I want a user profile page (name, settings, etc.) so I can view and edit my account settings. Points: 1
As a developer, I want to set up testing frameworks (unit, integration) so that I can write automated tests and maintain quality. Points: 2
As a team, we want technical documentation (architecture, APIs, setup) so that new contributors can understand the system. Points: 2
As a team, we want a presentation slide deck (for demo or stakeholder review) so that we can communicate what was built and why. Points: 2
Repository Structure (planned)
CSCE606-group5-project1/ │── app/ # Rails app code (models, controllers, views) │── features/ # Cucumber acceptance tests │── spec/ # RSpec unit tests │── docs/ # Technical docs, architecture diagrams │── config/ # Configurations & routes │── db/ # Migrations & schema │── README.md # Project overview & setup

Tech Stack
Backend: Ruby on Rails
Frontend: Rails views (optionally React if time)
Database: PostgreSQL
Testing: Cucumber (acceptance) + RSpec (unit tests)
CI/CD: GitHub Actions
Documentation
•	Technical Guide – setup & deployment steps
•	User Guide – how to use the calendar and LeetCode tracker
•	Architecture Diagram – models, controllers, DB schema
Team
Group 5 – CSCE 606 Fall 2025 • Members: Yafei Li, Shreya Sahni, Tasnia Jamal, Hasitha Tumu