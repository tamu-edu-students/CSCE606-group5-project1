# System Architecture Diagrams

## 1. Overall System Architecture (System Architecture)

```mermaid
flowchart TD
    U[User] --> B[Browser]
    B --> R[Rails Application]
    R --> V[Views<br/>ERB Templates]
    R --> C[Controllers<br/>Handles Requests]
    C --> M[Models<br/>Business Logic]
    M --> DB[(PostgreSQL<br/>Database)]
    DB --> M
    C --> Auth[Google OAuth<br/>Authentication]
    Auth --> C
    R --> Mail[Mailgun<br/>Email Service]
    Mail --> R
    R --> H[Heroku<br/>Deployment<br/>Staging + Production]
    H --> DB
    H --> Mail
    H --> Auth
    C --> JT[Background Job<br/>Weekly Report Generation]
    JT --> Mail
```

## 2. Database Schema (Database Schema)

```mermaid
erDiagram
    users ||--o{ leet_code_sessions : "has many"
    leet_code_sessions ||--o{ leet_code_session_problems : "has many"
    leet_code_problems ||--o{ leet_code_session_problems : "has many"

    users {
        bigint id PK
        string netid
        string email UK
        string first_name
        string last_name
        string role
        datetime last_login_at
        datetime created_at
        datetime updated_at
        integer current_streak
        integer longest_streak
        text preferred_topics
        boolean active
        string leetcode_username
        string google_access_token
        string google_refresh_token
        datetime google_token_expires_at 
    }

    leet_code_problems {
        bigint id PK
        string leetcode_id UK
        string title
        string difficulty
        string url
        text tags
        datetime created_at
        datetime updated_at
    }

    leet_code_sessions {
        bigint id PK
        bigint user_id FK
        datetime scheduled_time
        integer duration_minutes
        string status
        datetime created_at
        datetime updated_at
    }

    leet_code_session_problems {
        bigint id PK
        bigint leet_code_session_id FK
        bigint leet_code_problem_id FK
        boolean solved
        datetime solved_at
        datetime created_at
        datetime updated_at
    }
```

## 3. Rails MVC Architecture (Rails MVC)

```mermaid
flowchart TD
    V[Views<br/>ERB Templates] --> C[Controllers<br/>UsersController<br/>SessionsController<br/>etc.]
    C --> M[Models<br/>User<br/>Event<br/>LeetCodeSession<br/>etc.]
    M --> DB[(PostgreSQL<br/>Database)]
    DB --> M
    C --> Mailer[WeeklyReportMailer<br/>Sends Emails]
    Mailer --> Mail[Mailgun<br/>Email Service]
    C --> Auth[Google OAuth<br/>Authentication Service]
    Auth --> C
    C --> Job[Background Jobs<br/>Weekly Report Task<br/>lib/tasks/weekly_report.rake]
    Job --> Mailer
    V --> C
    C --> V
