# Use Python as the base image
FROM python:3.10-slim

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Set the working directory in the container
WORKDIR /app

# Update and install necessary packages
RUN apt-get update && apt-get install -y \
	wget \
	bzip2 \
	ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# Install Mambaforge for the appropriate architecture
RUN arch=$(uname -m) && \
	if [ "${arch}" = "x86_64" ]; then \
		wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh" -O mambaforge.sh; \
	elif [ "${arch}" = "aarch64" ]; then \
		wget -q "https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-aarch64.sh" -O mambaforge.sh; \
	else \
		echo "Unsupported architecture: ${arch}"; \
		exit 1; \
	fi && \
	bash mambaforge.sh -b -p /opt/mambaforge && \
	rm mambaforge.sh

# Add Mambaforge to PATH
ENV PATH=/opt/mambaforge/bin:$PATH

# Create a new environment with Python 3.10
RUN mamba create -n team1_env python=3.10 -y

# Activate the new environment
SHELL ["mamba", "run", "-n", "team1_env", "/bin/bash", "-c"]

# Copy requirements.txt into the container
COPY requirements.txt /app/requirements.txt

# Install Python packages from requirements.txt
RUN mamba install --yes --file requirements.txt && mamba clean --all -f -y

# Copy the current directory contents into the container at /app
COPY . /app

# Streamlit port
EXPOSE 5001
# Jupyter Notebook port
#EXPOSE 6001

# Add the conda environment's bin directory to PATH
ENV PATH=/opt/mambaforge/envs/team1_env/bin:$PATH

ENTRYPOINT ["python"]
CMD ["app.py"]
