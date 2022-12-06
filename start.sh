#!/bin/sh

# echo What is Your Name?

# read name

echo =======================================
echo Hello welcome Darshan
echo =======================================


sleep 5

echo Time to Build Service------------------
docker-compose build

sleep 5

echo Starting all services------------------
docker-compose up -d

echo process completed