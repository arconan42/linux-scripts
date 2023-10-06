#!/bin/bash

# Stop and then start all running Docker containers
docker restart $(docker ps -q)
