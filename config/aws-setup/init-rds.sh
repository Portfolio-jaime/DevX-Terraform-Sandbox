#!/bin/bash
# LocalStack RDS Initialization Script
# Creates RDS instances for artifact testing

set -e

AWS_ENDPOINT="http://localhost:4566"
AWS_REGION="us-east-1"

echo "🗃️  Initializing RDS instances in LocalStack..."

# Define RDS instances for different environments
INSTANCES=(
  "nx-booking-db-dev1:postgres:14.7:db.t3.micro:20"
  "nx-booking-db-sit1:postgres:14.7:db.t3.small:50"
  "nx-booking-db-uat1:postgres:14.7:db.t3.medium:100"
  "nx-booking-db-prod1:postgres:14.7:db.r6g.large:500"
  "nx-payment-db-dev1:mysql:8.0.32:db.t3.micro:20"
  "nx-analytics-db-dev1:postgres:14.7:db.t3.small:50"
)

# Create RDS instances
for instance_config in "${INSTANCES[@]}"; do
  IFS=':' read -r instance_id engine version instance_class storage <<< "$instance_config"

  echo "Creating RDS instance: $instance_id ($engine $version, $instance_class, ${storage}GB)"

  aws rds create-db-instance \
    --db-instance-identifier "$instance_id" \
    --db-instance-class "$instance_class" \
    --engine "$engine" \
    --engine-version "$version" \
    --master-username "admin" \
    --master-user-password "DevX_Test_2024!" \
    --allocated-storage "$storage" \
    --storage-type "gp2" \
    --vpc-security-group-ids "sg-default" \
    --db-subnet-group-name "nx-db-subnet-group" \
    --backup-retention-period 7 \
    --preferred-backup-window "03:00-04:00" \
    --preferred-maintenance-window "mon:04:00-mon:05:00" \
    --multi-az false \
    --publicly-accessible false \
    --storage-encrypted true \
    --tags "Key=Environment,Value=sandbox" "Key=ManagedBy,Value=DevX" "Key=Engine,Value=${engine}" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Instance $instance_id already exists"
done

# Create RDS parameter groups
PARAM_GROUPS=(
  "nx-postgres-14:postgres14"
  "nx-mysql-8:mysql8.0"
)

for param_config in "${PARAM_GROUPS[@]}"; do
  IFS=':' read -r group_name family <<< "$param_config"

  echo "Creating DB parameter group: $group_name"
  aws rds create-db-parameter-group \
    --db-parameter-group-name "$group_name" \
    --db-parameter-group-family "$family" \
    --description "DevX RDS parameter group" \
    --endpoint-url="$AWS_ENDPOINT" \
    --region="$AWS_REGION" \
    2>/dev/null || echo "  Parameter group $group_name already exists"
done

# Create DB subnet groups
echo "Creating DB subnet group: nx-db-subnet-group"
aws rds create-db-subnet-group \
  --db-subnet-group-name "nx-db-subnet-group" \
  --db-subnet-group-description "DevX database subnet group" \
  --subnet-ids "subnet-12345" "subnet-67890" \
  --tags "Key=ManagedBy,Value=DevX" \
  --endpoint-url="$AWS_ENDPOINT" \
  --region="$AWS_REGION" \
  2>/dev/null || echo "  Subnet group already exists"

echo "✅ RDS instances initialized successfully!"
