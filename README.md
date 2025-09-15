# FastAPI Cloud Deployment Guide

A comprehensive, step-by-step guide for deploying FastAPI applications to all major cloud providers—AWS, Google Cloud, Azure, and Heroku—with robust Docker support and automation.

---


## 🌐 Features

- ☁️ **Multi-cloud deployment templates** (AWS, GCP, Azure, Heroku)
- 🐳 **Docker containerization** and Compose support
- 🔧 **Provider-specific configs** for each cloud platform
- 📋 **Step-by-step deployment** and rollback instructions
- ⚡ **One-command deployment scripts**
- 🔍 **Troubleshooting for common errors**
- 📊 **Health checks** and logging for observability

---

## 🗂️ Project Structure

```
fastapi-cloud-deployment-guide/
├── app/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   └── routes/
│       ├── __init__.py
│       ├── items.py
│       └── users.py
├── cloud-config/
│   ├── aws/
│   │   ├── apprunner.yaml
│   │   └── buildspec.yml
│   ├── google-cloud/
│   │   └── cloudbuild.yaml
│   ├── azure/
│   │   └── azure-pipelines.yml
│   └── heroku/
│       └── heroku.yml
├── scripts/
│   ├── deploy-aws.sh
│   ├── deploy-gcloud.sh
│   ├── deploy-azure.sh
│   └── deploy-heroku.sh
├── Dockerfile
├── docker-compose.yml
├── requirements.txt
├── .dockerignore
├── .gitignore
└── README.md
```

---

## 🔑 Prerequisites

- **Common:**  
  - Docker Desktop (or Docker Engine) installed and running
  - Python 3.8+ (for local testing)
  - Git

- **Cloud CLIs:**  
  - AWS CLI (`aws configure`)
  - Google Cloud SDK (`gcloud init`)
  - Azure CLI (`az login`)
  - Heroku CLI (`heroku login`)

---

## 🚦 Quick Start

### 1. Clone & Set Up the Project

```bash
git clone <your-repo-url>
cd fastapi-cloud-deployment-guide

# Create and activate a virtual environment (optional)
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 2. Local Docker Test

```bash
docker-compose up --build
# Or:
docker build -t fastapi-app .
docker run -p 8000:80 fastapi-app
```

- Visit: [http://localhost:8000](http://localhost:8000)
- Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
- Health: [http://localhost:8000/health](http://localhost:8000/health)

---

## ☁️ Cloud Deployment Guides

### A. AWS App Runner (ECR)

1. **Configure AWS CLI**
   ```bash
   aws configure
   ```

2. **Create ECR repo**
   ```bash
   aws ecr create-repository --repository-name fastapi-app
   ```

3. **Build & Push Image**
   ```bash
   aws ecr get-login-password | docker login --username AWS --password-stdin <ECR_URL>
   docker build -t fastapi-app .
   docker tag fastapi-app:latest <ECR_URL>/fastapi-app:latest
   docker push <ECR_URL>/fastapi-app:latest
   ```

4. **Deploy with AWS App Runner**
   - Go to AWS Console → App Runner → Create Service
   - Point to your ECR image, set port 80, and deploy

5. **Access App**:  
   AWS provides a public URL.

---

### B. Google Cloud Run

1. **Setup gcloud**
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   gcloud config set run/region us-central1
   ```

2. **Deploy**
   ```bash
   gcloud run deploy fastapi-service --source . --platform managed --allow-unauthenticated --memory 512Mi --cpu 1
   ```

3. **Access App**:  
   Cloud Run gives a HTTPS endpoint.

---

### C. Azure Container Apps

1. **Login**
   ```bash
   az login
   ```

2. **Create Resources**
   ```bash
   az group create --name fastapi-rg --location eastus
   az acr create --resource-group fastapi-rg --name fastapiacr --sku Basic
   az acr build --registry fastapiacr --image fastapi-app:latest .
   ```

3. **Deploy**
   ```bash
   az containerapp env create --name fastapi-env --resource-group fastapi-rg --location eastus
   az containerapp create --name fastapi-app --resource-group fastapi-rg --environment fastapi-env --image fastapiacr.azurecr.io/fastapi-app:latest --target-port 80 --ingress 'external'
   ```

4. **Access App**:  
   Azure provides a FQDN.

---

### D. Heroku (Container Registry)

1. **Login**
   ```bash
   heroku login
   heroku container:login
   ```

2. **Create App**
   ```bash
   heroku create your-app-name
   heroku stack:set container -a your-app-name
   ```

3. **Push & Release**
   ```bash
   heroku container:push web -a your-app-name
   heroku container:release web -a your-app-name
   ```

4. **Access App**:  
   Heroku provides a public URL.

---

## 🐞 Troubleshooting & Common Errors

- **ECR 'no basic auth credentials':**  
  Run the Docker ECR login command again.
- **Cloud Run 'container failed to start':**  
  Ensure your app listens on the correct port (default 8080 for Cloud Run, 80 for most others).
- **Heroku H10-App Crashed:**  
  Ensure your app listens on `$PORT` (Heroku sets this env automatically).

---

## ⚙️ Configuration Files

- **Dockerfile**: Multi-platform build, exposes port 80, runs with Gunicorn + Uvicorn
- **cloud-config/**: Contains provider-specific deployment YAML (e.g., App Runner, Cloud Build, Azure Pipelines, Heroku YAML)
- **scripts/**: Convenience scripts for automating deployment

---

## 📝 Health & Monitoring

- All deployments include endpoints:
  - `/health`: 200 OK when healthy
  - `/health/detailed`: Extended info (if `psutil` is installed)

- **Logs:**  
  - AWS: CloudWatch  
  - GCP: Cloud Logging  
  - Azure: Log Analytics  
  - Heroku: `heroku logs --tail`

---

## 💸 Cost Optimization

- AWS App Runner and GCP/Azure scale to zero (low idle cost)
- Use free/eco dynos for Heroku dev/test
- Set memory/CPU limits in each platform's configuration

---

## 🔒 Security Best Practices

- Use environment variables for secrets and config (never commit secrets)
- Minimal base images (e.g., slim python)
- Keep all dependencies up to date
- Only expose port 80/8080 as needed
- Use HTTPS (default for most clouds)
- Enable authentication and authorization for production APIs

---

## 📚 References

- [AWS App Runner Docs](https://docs.aws.amazon.com/apprunner/)
- [Google Cloud Run Docs](https://cloud.google.com/run/docs)
- [Azure Container Apps Docs](https://learn.microsoft.com/en-us/azure/container-apps/)
- [Heroku Container Registry Docs](https://devcenter.heroku.com/articles/container-registry-and-runtime)
- [FastAPI Deployment Docs](https://fastapi.tiangolo.com/deployment/)

---

## 🪪 License

MIT License — feel free to use, adapt, and deploy this guide for your own projects.

---

**Now you can deploy your FastAPI app to any cloud, with confidence and best practices! 🚀**
