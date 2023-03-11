# syntax=docker/dockerfile:1
FROM ubuntu:latest

# Install RVM and Ruby binaries
RUN apt-get update && \
    apt-get install -y gpg && \
    apt-get install -y curl && \
    apt-get install -y git && \
    curl -sSL https://rvm.io/mpapis.asc | gpg --import - && \
    curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - && \
    \curl -sSL https://get.rvm.io | bash && \
    /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 3.1.2" && \
    mkdir /code && \
    mkdir /code/nashobmen

COPY . /code/nashobmen/
WORKDIR /code/nashobmen
RUN /bin/bash -l -c "gem install bundler && bundle install"
CMD ["/bin/bash", "-l", "-c", "rackup --host=0.0.0.0 --port=4570"]