# Easy Claude Code Docker Sandbox

A safe, isolated environment for running Claude Code on your projects.

## What This Is

This Docker sandbox allows you to work with Claude Code on your projects with environment isolation. Claude Code operates inside a container where it can experiment, make changes, and work with Docker—all while keeping everything outside your project directory protected.

## What This Protects Against ✅

- **Files outside your project**: Claude Code cannot access any files on your computer except the mounted project directory
- **System files**: Your computer's system files are completely inaccessible
- **Other projects**: Only the mounted project is visible to Claude Code
- **Environment pollution**: Installing packages, changing configs, etc. stays in the container
- **Accidental commits**: Changes only go to GitHub if you explicitly push them

If Claude Code does something catastrophic, just delete the container and start fresh. Everything outside your project directory remains untouched.

## What This Does NOT Protect Against ⚠️

- **Files in your mounted project**: Claude Code can modify files in your project directory (but git protects you - commit before sessions, revert if needed)
- **Malicious pushes to GitHub**: If Claude Code pushes bad code and you don't catch it, it's in your repo (but you can revert)
- **Host Docker daemon**: The container shares your computer's Docker daemon (can see host containers, but unlikely to cause issues)
- **Network access**: The container can make network requests

**Bottom line**: This protects everything on your computer EXCEPT the specific project you're working on. For the project itself, git is your safety net (commit often, review before pushing).

## Setup

### Prerequisites
- Docker installed and running
- Anthropic subscription or API key
- Git configured with your GitHub credentials

### Initial Setup

1. **Update start.sh with your project path:**
   
   Edit `start.sh` and replace the path with your actual project location:
   ```bash
   -v /path/to/your/project:/workspace/mounted-project \
   ```

2. **Build the sandbox image:**
   ```bash
   ./start.sh
   ```
   (First run will build the image automatically - takes 3-5 minutes)

3. **OPTIONAL: Set your API key** (choose one method):
   
   This step is not required if you are using a Claude subscription.

   **Option A: Environment variable (recommended)**
   ```bash
   export ANTHROPIC_API_KEY="your-key-here"
   ./start.sh
   ```
   
   **Option B: Set inside container each time**
   ```bash
   ./start.sh
   # Inside container:
   export ANTHROPIC_API_KEY="your-key-here"
   ```

4. **GitHub authentication** (for pushing):
   
   Generate a Personal Access Token at https://github.com/settings/tokens
   
   When you push, use:
   - Username: your GitHub username
   - Password: your personal access token

## Quick Reference Commands

### Starting and Stopping

```bash
# Start/enter the sandbox
./start.sh

# Exit sandbox (keeps container running)
exit
# or Ctrl+D

# Stop the sandbox
docker stop claude-sandbox

# Start stopped sandbox
./start.sh
# (will restart existing container automatically)

# Get into running sandbox from another terminal
docker exec -it claude-sandbox /bin/bash

# Check if sandbox is running
docker ps | grep claude-sandbox

# Check if sandbox exists (running or stopped)
docker ps -a | grep claude-sandbox
```

### Working Inside the Sandbox

```bash
# Navigate to your project (already mounted!)
cd /workspace/mounted-project

# Run Claude Code
claude

# Build your Docker project
docker build -t myapp .

# Run your Docker project
docker run myapp

# Run docker-compose
docker compose up

# Check git status
git status

# Commit changes
git add .
git commit -m "Description of changes"

# Push to GitHub (review changes first!)
git push

# Pull latest from GitHub
git pull
```

### Cleanup and Maintenance

```bash
# Remove the sandbox completely (start fresh)
./cleanup.sh
# or manually:
docker stop claude-sandbox
docker rm claude-sandbox

# Rebuild the sandbox image (if you update Dockerfile)
docker build -t claude-sandbox .

# View container logs
docker logs claude-sandbox

# See disk space used by Docker
docker system df

# Clean up Docker resources
docker system prune
```

## Typical Workflow

1. **Commit your current work (important!):**
   ```bash
   cd /path/to/your/project
   git add -A
   git commit -m "Before Claude Code session"
   ```

2. **Start the sandbox:**
   ```bash
   cd /path/to/claude-sandbox
   ./start.sh
   ```

3. **Work with Claude Code:**
   ```bash
   cd /workspace/mounted-project
   claude
   ```

4. **Review and push changes:**
   ```bash
   git status
   git diff
   # If changes look good:
   git add .
   git commit -m "Implemented feature X"
   git push
   ```
   
   **If changes are bad:**
   ```bash
   git reset --hard HEAD~1  # Undo last commit
   # or
   git reset --hard HEAD  # Discard all changes
   ```

5. **Exit when done:**
   ```bash
   exit
   ```

## Tips

- **ALWAYS commit before Claude Code sessions** - this is your safety net
- **Review changes carefully** before pushing to GitHub
- **Use branches** for experimental work: `git checkout -b experiment`
- **Keep the sandbox** between sessions—your work persists until you remove it
- **Docker just works** - no need to start daemons or configure storage drivers

## Troubleshooting

**"The path /path/to/your is not shared from the host"**
- Make sure you updated the path in `start.sh` to your actual project location
- The path should be absolute (e.g., `/path/to/your/project`)

**"Cannot connect to Docker daemon"**
- Make sure Docker Desktop is running on your computer
- Try: `docker ps` on your computer to verify Docker works

**"Permission denied" when using Docker inside sandbox**
- The Docker socket mount should handle this
- Restart Docker Desktop if issues persist

**"Authentication failed" when pushing to GitHub**
- Generate a new Personal Access Token at https://github.com/settings/tokens
- Make sure the token has `repo` scope
- Use the token as your password, not your GitHub password

**"Command not found: claude"**
- The image may not have built correctly
- Rebuild: `./cleanup.sh && docker rmi claude-sandbox && ./start.sh`

**See your own container when running `docker ps`**
- This is normal! Socket mounting means you're using your computer's Docker daemon
- You'll see all containers running on your computer, including the sandbox itself

**Verify environment isolation**
```bash
# Inside container - these should all fail:
ls /path/to/any/other/local/folder/  # Fails - not mounted

# This works - your mounted project:
ls /workspace/mounted-project/   # Works
```

## Security Notes

- This uses socket mounting - shares your computer's Docker daemon
- Only your project directory is mounted - everything else on your computer is protected
- Your API key is passed into the container—don't share container snapshots
- **Git is your primary protection for project files** - commit before sessions
- Use branches for experimental work to avoid affecting main

## How It Works

This sandbox uses **socket mounting** for reliable Docker access:

1. The sandbox container mounts `/var/run/docker.sock` from your computer
2. Docker commands inside the sandbox talk to your computer's Docker daemon
3. Your project directory is mounted at `/workspace/mounted-project`
4. Everything else on your computer is invisible and inaccessible to the container

**Advantages:**
- ✅ Fast and reliable - no Docker-in-Docker issues
- ✅ Protects everything except your project directory
- ✅ Docker Compose and volume mounts just work
- ✅ Simple and stable

**Trade-offs:**
- ⚠️ Project files are directly accessible (use git for protection)
- ⚠️ Shares Docker daemon with host (minor concern in practice)

## File Structure

```
claude-sandbox/        # Clone this repo anywhere you like
├── Dockerfile         # Sandbox environment definition
├── start.sh           # Script to start/enter sandbox
├── cleanup.sh         # Script to remove sandbox
└── README.md          # This file
```

Inside the container:
```
/workspace/
└── mounted-project/   # Your mounted project
```

On your computer:
```
/path/to/your
└── project/           # Your actual project (mounted into container)
```

## Advanced Usage

### Mounting Multiple Projects

Edit `start.sh` to mount additional directories:

```bash
-v /path/to/your/project1:/workspace/project1 \
-v /path/to/your/project2:/workspace/project2 \
```

### Custom Docker Builds

Any existing Docker configurations in your project should work normally without changes.

---

**Remember**: Always commit your work before Claude Code sessions. Git is your safety net!