# Use an official Ubuntu base image
FROM ubuntu:22.04

# Avoid prompts from apt during installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Octave and Make (using --no-install-recommends to massively reduce build time)
RUN apt-get update && apt-get install -y --no-install-recommends \
    octave \
    make \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /app

# Copy the entire project directory into the container
COPY . /app/

# Set the default command to run the checker
CMD ["make", "check"]
