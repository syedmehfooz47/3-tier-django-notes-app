# Containerized 3-Tier Notes App (DevOps Showcase)

A production-grade, containerized 3-tier application built and optimized by **Syed Mehfooz C S** to demonstrate key DevOps practices including **multi-stage build optimizations**, **reverse-proxy routing**, **automated static asset management**, and **Docker Hub registry pipelines**.

---

## 👤 Author Contact
*   **Name:** Syed Mehfooz C S
*   **Email:** [hello@syedmehfooz.com](mailto:hello@syedmehfooz.com)
*   **GitHub:** [@syedmehfooz47](https://github.com/syedmehfooz47)
*   **Docker Hub:** [syedmehfooz](https://hub.docker.com/u/syedmehfooz)

---

## 🏗️ Decoupled 3-Tier Architecture

In modern production environments, frontends and backends are split into decoupled services. Nginx serves as the single entry point (reverse proxy) on port `80`, routing traffic based on request paths:

```
                      ┌──────────────────────┐
                      │    Client Browser    │
                      └──────────┬───────────┘
                                 │ HTTP (Port 80)
                                 ▼
                      ┌──────────────────────┐
                      │ Nginx Reverse Proxy  │
                      └──────────┬───────────┘
                                 │
             ┌───────────────────┴───────────────────┐
             │ (Serves Static UI Assets)             │ (Proxies APIs)
             ▼                                       ▼
┌─────────────────────────┐             ┌─────────────────────────┐
│  React Presentation     │             │  Django REST Framework  │
│    Tier 1 (Nginx)       │             │   Logic Tier 2 (App)    │
└─────────────────────────┘             └────────────┬────────────┘
                                                     │ SQL (Port 3306)
                                                     ▼
                                        ┌─────────────────────────┐
                                        │ MySQL Database Tier 3   │
                                        └─────────────────────────┘
```

*   **Presentation Tier (Frontend):** React static files compiled at build-time and served directly by Nginx.
*   **Application Tier (Backend):** Django REST Framework served via Gunicorn WSGI. Only handles `/api/` endpoints and `/admin/` requests.
*   **Data Tier (Database):** MySQL container running on a private subnet, utilizing a Docker volume to persist data locally.

### ❓ Why only 3 containers instead of 4?
At runtime, React is purely static HTML/JS/CSS. It does not require a Node.js process to run in production. In our configuration:
1. We use a **temporary Node.js container** during the build stage to compile the React code.
2. The compiled assets are copied directly inside the **Nginx container**.
3. Therefore, Nginx acts as both the **Static Web Server** (serving the React UI) and the **Reverse Proxy** (forwarding API calls to Django). 

This eliminates a 4th running container, saving up to 400MB of host RAM, and increases security by not running a Node development server in production.

---

## ⚡ DevOps & Containerization Features

### 1. Multi-Stage Docker Builds (Image Optimization)
To ensure fast pull times and minimal storage overhead in container registries, both the frontend and backend utilize multi-stage Docker builds.

#### 🔹 React Frontend (`nginx/Dockerfile`)
*   **Stage 1 (Build):** Uses `node:18-alpine` to install packages and compile the code to static bundles (`npm run build`). The heavy `node_modules` are discarded in this stage.
*   **Stage 2 (Run):** Uses a clean `nginx:1.23.3-alpine` image and copies only the compiled static assets.
*   *Outcome:* Avoids shipping a heavy Node.js environment to production.

#### 🔹 Django Backend (`Dockerfile`)
*   **Stage 1 (Build):** Uses `python:3.9-slim` to install compiler requirements (`gcc`, build headers) to compile C dependencies (like `mysqlclient`) inside a virtual environment (`/opt/venv`).
*   **Stage 2 (Run):** Uses a clean `python:3.9-slim` image, installs only the dynamic database runtime library (`default-libmysqlclient-dev`), and copies the compiled virtual environment `/opt/venv` from Stage 1.
*   *Outcome:* Avoids leaving build-essential utilities (`gcc`, headers) in the production image.

#### 📊 Image Size Impact:
| Container Image | Single-Stage Build | Multi-Stage Build | Size Reduction |
| :--- | :---: | :---: | :---: |
| **Django Backend** | `2.09 GB` | `~200 MB` | **~90.4% smaller** |
| **React Frontend** | `~1.10 GB` (Node.js) | `~63 MB` (Nginx) | **~94.2% smaller** |

---

### 2. Intelligent Reverse Proxy Routing (`nginx/default.conf`)
Rather than relying on complex CORS settings or exposing multiple ports, Nginx handles all routing:
*   `location /` ➔ Directly serves the React static SPA bundle.
*   `location /api/` and `location /admin/` ➔ Proxied to Gunicorn on the Django container.
*   `location /static/` ➔ Serves React's local static assets if found; falls back to proxying to Django (handled by `whitenoise`) for admin panel assets.

---

### 3. Container Isolation & Persistence
*   **Network Isolation:** All containers run on a private bridge network (`notes-app-nw`). The database (`db_cont`) does not expose ports to the outside host, preventing external attacks.
*   **Data Persistence:** The database maps storage to the host filesystem: `- ./data/mysql/db:/var/lib/mysql`. The database can be restarted without losing records.

---

## 🚀 How to Run the Infrastructure

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/syedmehfooz47/3-tier-django-notes-app.git
    cd 3-tier-django-notes-app
    ```

2.  **Spin up the infrastructure (Local Dev):**
    ```bash
    docker compose up --build -d
    ```

3.  **Access the application:**
    *   **Live App (Frontend):** [https://3-tier-django-app.projects.syedmehfooz.com](https://3-tier-django-app.projects.syedmehfooz.com)
    *   **Live Admin Panel:** [https://3-tier-django-app.projects.syedmehfooz.com/admin/](https://3-tier-django-app.projects.syedmehfooz.com/admin/)
    *   **Local Development:** [http://localhost](http://localhost) (Nginx port `80`)
