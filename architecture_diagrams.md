# System Architecture Diagrams

## 1. Overall System Architecture (System Architecture)

```mermaid
flowchart TD
    U[User] --> B[Browser]
    B --> R[Rails Application]
    R --> V[Views<br/>ERB Templates<br/>Bootstrap/Propshaft]
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
    users ||--o{ events : "has many"
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
    }

    events {
        bigint id PK
        string summary
        datetime start_time
        datetime end_time
        bigint user_id FK
        datetime created_at
        datetime updated_at
    }

    leet_code_entries {
        bigint id PK
        integer problem_number
        string problem_title
        integer difficulty
        date solved_on
        datetime created_at
        datetime updated_at
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
    V[Views<br/>ERB Templates<br/>Bootstrap UI] --> C[Controllers<br/>UsersController<br/>SessionsController<br/>etc.]
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