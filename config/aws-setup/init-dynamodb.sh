#!/bin/bash
# LocalStack DynamoDB Initialization Script
# Creates DynamoDB tables for artifact testing

set -e

AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

echo "🗄️  Initializing DynamoDB tables in LocalStack..."

# Define tables with their key schemas
create_table() {
  local table_name=$1
  local pk_name=$2
  local pk_type=$3
  local sk_name=$4
  local sk_type=$5

  echo "Creating DynamoDB table: $table_name"

  if [ -n "$sk_name" ]; then
    # Table with sort key
    aws dynamodb create-table \
      --table-name "$table_name" \
      --attribute-definitions \
        "AttributeName=${pk_name},AttributeType=${pk_type}" \
        "AttributeName=${sk_name},AttributeType=${sk_type}" \
      --key-schema \
        "AttributeName=${pk_name},KeyType=HASH" \
        "AttributeName=${sk_name},KeyType=RANGE" \
      --billing-mode PAY_PER_REQUEST \
      --tags "Key=Environment,Value=sandbox" "Key=ManagedBy,Value=DevX" \
      --endpoint-url="$AWS_ENDPOINT" \
      --region="$AWS_REGION" \
      2>/dev/null || echo "  Table $table_name already exists"
  else
    # Table with only partition key
    aws dynamodb create-table \
      --table-name "$table_name" \
      --attribute-definitions \
        "AttributeName=${pk_name},AttributeType=${pk_type}" \
      --key-schema \
        "AttributeName=${pk_name},KeyType=HASH" \
      --billing-mode PAY_PER_REQUEST \
      --tags "Key=Environment,Value=sandbox" "Key=ManagedBy,Value=DevX" \
      --endpoint-url="$AWS_ENDPOINT" \
      --region="$AWS_REGION" \
      2>/dev/null || echo "  Table $table_name already exists"
  fi
}

# Create common DevX tables
create_table "nx-sessions" "session_id" "S" "ttl" "N"
create_table "nx-user-profiles" "user_id" "S"
create_table "nx-booking-data" "booking_ref" "S" "timestamp" "N"
create_table "nx-flight-cache" "flight_key" "S"
create_table "nx-offer-state" "offer_id" "S" "created_at" "N"
create_table "nx-seat-locks" "seat_id" "S" "lock_timestamp" "N"
create_table "nx-payment-transactions" "transaction_id" "S" "user_id" "S"
create_table "nx-audit-logs" "log_id" "S" "timestamp" "N"

# Create environment-specific tables
for env in dev1 sit1 uat1 prod1; do
  create_table "nx-config-${env}" "config_key" "S"
  create_table "nx-feature-flags-${env}" "flag_name" "S"
done

# Enable TTL on sessions table
echo "Enabling TTL on nx-sessions table"
aws dynamodb update-time-to-live \
  --table-name "nx-sessions" \
  --time-to-live-specification "Enabled=true,AttributeName=ttl" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || true

echo "✅ DynamoDB tables initialized successfully!"
