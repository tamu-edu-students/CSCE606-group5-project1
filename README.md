# CSCE606 Group 5 – Project 1  

This project is a group web application developed for **CSCE 606 (Software Engineering)** at Texas A&M University.  
It aims to help students organize their daily study routines with a special focus on **integrating LeetCode problem solving into their schedule**.  

---

## 📌 Core Features (Planned)  

- **Daily and Weekly Task Planner** – create, edit, and manage personal schedules  
- **LeetCode Tracker** – log problems solved daily with difficulty and tags  
- **Progress Dashboard** – weekly coding statistics and productivity insights  
- **User-Friendly Interface** – clean dashboard tailored for students  
- **Export Options** – download schedule and solved problems as PDF/CSV  

---

## 🏃 Agile Development Plan  

We are following **Agile (Scrum)** methodology with **2 sprints** to deliver the project before the deadline (**Oct 3rd, 2025**).  

### **Sprint 1 (Sept 15 – Sept 23): Foundation + Core Features**  
**Goals**:  
- Set up repository, CI/CD, branch protection  
- Implement user authentication  
- Build core models (Users, Events, LeetCodeEntries)  
- Event CRUD (create/read/update/delete)  
- LeetCodeEntry CRUD (problem name, difficulty, date solved)  
- Initial acceptance + unit tests (~60–70% coverage)  
- Draft documentation (README setup + architecture diagram)  

**Deliverables**:  
- Repo + CI pipeline  
- Authentication + Calendar CRUD + LeetCode logging working  
- ≥10 user stories in repo  
- Initial Cucumber + RSpec tests  

---

### **Sprint 2 (Sept 24 – Oct 2): Advanced Features + Final Polish**  
**Goals**:  
- Weekly stats dashboard (charts/summary)  
- Filtering & tagging for events/problems  
- Export feature (PDF/CSV)  
- Error handling + UI polish  
- Documentation (Technical Guide, User Guide, Architecture diagram)  
- Finalize user stories (≥20 total, SMART/INVEST)  
- Achieve ≥90% test coverage (acceptance + unit tests)  

**Deliverables**:  
- Fully functional calendar + LeetCode tracker  
- Weekly progress insights working  
- Export feature available  
- Documentation completed in `README.md` / `docs/`  
- All commits & PRs following standards  

---

## 📌 User Stories (SMART & INVEST)  

1. As a student, I want to **sign up** so that I can save my personal calendar and progress.  
2. As a student, I want to **log in and out** so that I can securely access my account.  
3. As a student, I want to **reset my password** so that I can recover access if I forget it.  
4. As a student, I want to **create daily events** so that I can track my study schedule.  
5. As a student, I want to **edit and delete events** so that my calendar stays accurate.  
6. As a student, I want to **view a daily calendar** so that I can see my tasks for the day.  
7. As a student, I want to **view a weekly calendar** so that I can plan my entire week.  
8. As a student, I want to **log solved LeetCode problems** so that I can track my coding practice.  
9. As a student, I want to **tag problems by difficulty** so that I can analyze my strengths and weaknesses.  
10. As a student, I want to **see a combined daily view of events and problems solved** so I can track both academics and coding practice.  
11. As a student, I want to **filter events by categories** (academic, personal, coding) so that I can stay organized.  
12. As a student, I want to **search for past LeetCode problems I solved** so that I can review them later.  
13. As a student, I want to **see weekly statistics of solved problems** so I can measure my progress.  
14. As a student, I want to **visualize my progress in charts** so that I stay motivated.  
15. As a student, I want to **mark tasks as completed** so that I can feel a sense of accomplishment.  
16. As a student, I want to **export my schedule and solved problems** as PDF/CSV so that I can share with my mentor.  
17. As a student, I want to **get error messages when I enter invalid input** so that I know how to fix mistakes.  
18. As a student, I want to **navigate the dashboard easily** so that I can quickly find what I need.  
19. As a student, I want to **see my study history** so that I can reflect on my long-term progress.  
20. As a student, I want to **use the application on both desktop and mobile** so that I can update my schedule anywhere.  

---

## 📂 Repository Structure (planned)  

CSCE606-group5-project1/
│── app/                # Rails app code (models, controllers, views)
│── features/           # Cucumber acceptance tests
│── spec/               # RSpec unit tests
│── docs/               # Technical docs, architecture diagrams
│── config/             # Configurations & routes
│── db/                 # Migrations & schema
│── README.md           # Project overview & setup

---

## 🛠️ Tech Stack  

- **Backend**: Ruby on Rails  
- **Frontend**: Rails views (optionally React if time)  
- **Database**: PostgreSQL  
- **Testing**: Cucumber (acceptance) + RSpec (unit tests)  
- **CI/CD**: GitHub Actions  

---
## 📖 Documentation
	•	Technical Guide – setup & deployment steps
	•	User Guide – how to use the calendar and LeetCode tracker
	•	Architecture Diagram – models, controllers, DB schema

⸻

## 👥 Team

Group 5 – CSCE 606 Fall 2025
	•	Members: Yafei Li, TODO