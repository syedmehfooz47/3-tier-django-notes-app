# Containerized 3-Tier Notes Application

A modern, production-grade 3-tier Single Page Application (SPA) built and containerized by **Syed Mehfooz C S** to showcase advanced containerization, multi-stage building, and reverse-proxy routing using **Docker**, **Nginx**, **Django REST Framework**, and **MySQL**.

---

## 👤 Author Contact
*   **Name:** Syed Mehfooz C S
*   **Email:** [hello@syedmehfooz.com](mailto:hello@syedmehfooz.com)
*   **GitHub:** [@syedmehfooz47](https://github.com/syedmehfooz47)

---

## 🏗️ Architecture Design

This project is implemented as a fully decoupled **3-tier architecture** to optimize security, scalability, and performance in production environments:

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
│     React Frontend      │             │  Django REST Framework  │
│       (Tier 1)          │             │     Backend (Tier 2)    │
└─────────────────────────┘             └────────────┬────────────┘
                                                     │ SQL (Port 3306)
                                                     ▼
                                        ┌─────────────────────────┐
                                        │     MySQL Database      │
                                        │        (Tier 3)         │
                                        └─────────────────────────┘
```

### 1. Presentation Tier (Frontend)
*   **Technology:** React.js
*   **Containerization:** Built using a **multi-stage Docker build** (`node:18-alpine` for building and `nginx:1.23.3-alpine` for hosting).
*   **Asset Serving:** Static UI assets are served directly by Nginx (incredibly fast and low overhead) rather than hitting the backend application server.

### 2. Application Tier (Backend)
*   **Technology:** Django REST Framework & Gunicorn WSGI server.
*   **Containerization:** Runs in a Python 3.9 container, focusing solely on executing backend APIs (`/api/`) and the administrative panel (`/admin/`).
*   **Static Assets:** Administrative styles and Django REST framework templates are served by `whitenoise` and proxied seamlessly through Nginx.

### 3. Data Tier (Database)
*   **Technology:** MySQL Database.
*   **Containerization:** MySQL runs in its own isolated container, persisting data to a local Docker volume for durability.

---

## ⚡ Prerequisites

To run this application, you only need to have the following installed on your machine:
*   [Docker Desktop](https://www.docker.com/products/docker-desktop/) (includes Docker Compose)

---

## 🚀 Quick Start

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/syedmehfooz47/3-tier-django-notes-app.git
    cd 3-tier-django-notes-app
    ```

2.  **Spin up the infrastructure:**
    Run the following command to build the images and launch the containers:
    ```bash
    docker compose up --build -d
    ```

3.  **Access the application:**
    *   **Live App (Frontend):** [https://3-tier-django-app.projects.syedmehfooz.com](https://3-tier-django-app.projects.syedmehfooz.com)
    *   **Live Django Admin Panel:** [https://3-tier-django-app.projects.syedmehfooz.com/admin/](https://3-tier-django-app.projects.syedmehfooz.com/admin/)
    *   **Live API Endpoints:** [https://3-tier-django-app.projects.syedmehfooz.com/api/notes/](https://3-tier-django-app.projects.syedmehfooz.com/api/notes/)
    *   **Local Development:** [http://localhost](http://localhost) (or port mapped on your host)

---

## ⚙️ How Nginx Routes the Traffic

Nginx acts as the single entry point (reverse proxy) listening on port `80`. It routes incoming traffic based on request paths:
*   `location /api/` ➔ Proxied to the Django Backend container.
*   `location /admin/` ➔ Proxied to the Django Backend container.
*   `location /static/` ➔ Attempts to serve files locally (React built JS/CSS). If not found (e.g. Django Admin assets), it falls back to proxying to Django.
*   `location /` ➔ Serves React's `index.html` and assets directly.
