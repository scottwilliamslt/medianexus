# This is the official Dockerfile for building the MediaNexus backend application.
# It uses a multi-stage build to keep the final image small and secure.

# --- Build Stage ---
# This stage installs dependencies
FROM python:3.11-slim as builder

WORKDIR /app

# Install build dependencies
RUN pip install --upgrade pip

# Copy the requirements file and install python packages
# This is done in a separate step to leverage Docker's layer caching.
# The requirements will only be re-installed if the requirements.txt file changes.
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt


# --- Final Stage ---
# This stage creates the final, lean image
FROM python:3.11-slim

WORKDIR /app

# Copy the installed packages from the builder stage
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the application source code
COPY . .

# Expose the internal port that the application will run on
EXPOSE 9339

# Set the command to run the application using the Uvicorn server
# --host 0.0.0.0 makes it accessible from outside the container
# --port 9339 matches the exposed port
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9339"]

