if [ ! -f .env ]; then
    echo ".env file not found. Please create one or modify .env.example before running this script."
    exit 1
fi

docker compose up --build -d