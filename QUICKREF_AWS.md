# AWS LocalStack - Quick Reference Card

## 🚀 Essential Commands

### Setup & Management
```bash
make setup-aws          # Start LocalStack + initialize all services
make stop-aws           # Stop LocalStack (keeps data)
make clean-aws          # Remove LocalStack + all data
make restart-aws        # Clean restart
make status-aws         # Check health
make logs-aws           # View logs
```

### Testing
```bash
make test-e2e                                    # Run all E2E tests
./tests/e2e/test-create-artifact-e2e.sh         # Test artifact creation
./tests/e2e/test-add-redis-e2e.sh               # Test Redis addition
./tests/e2e/test-approve-infra-e2e.sh           # Test infrastructure approval
```

## 🔧 AWS CLI Usage

### Setup Environment
```bash
export AWS_ENDPOINT_URL=http://localhost:4566
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Or use inline
aws --endpoint-url=http://localhost:4566 <service> <command>
```

### IAM Commands
```bash
# List roles
aws --endpoint-url=$AWS_ENDPOINT_URL iam list-roles

# Get specific role
aws --endpoint-url=$AWS_ENDPOINT_URL iam get-role --role-name nx-artifact-service-account

# List attached policies
aws --endpoint-url=$AWS_ENDPOINT_URL iam list-attached-role-policies --role-name ROLE_NAME
```

### ECR Commands
```bash
# List repositories
aws --endpoint-url=$AWS_ENDPOINT_URL ecr describe-repositories

# Get specific repo
aws --endpoint-url=$AWS_ENDPOINT_URL ecr describe-repositories --repository-names nx-bff-web-offer

# List images
aws --endpoint-url=$AWS_ENDPOINT_URL ecr list-images --repository-name REPO_NAME
```

### S3 Commands
```bash
# List buckets
aws --endpoint-url=$AWS_ENDPOINT_URL s3 ls

# List bucket contents
aws --endpoint-url=$AWS_ENDPOINT_URL s3 ls s3://nx-artifacts/

# Upload file
aws --endpoint-url=$AWS_ENDPOINT_URL s3 cp file.txt s3://nx-artifacts/

# Download file
aws --endpoint-url=$AWS_ENDPOINT_URL s3 cp s3://nx-artifacts/file.txt ./
```

### DynamoDB Commands
```bash
# List tables
aws --endpoint-url=$AWS_ENDPOINT_URL dynamodb list-tables

# Describe table
aws --endpoint-url=$AWS_ENDPOINT_URL dynamodb describe-table --table-name nx-sessions

# Scan table
aws --endpoint-url=$AWS_ENDPOINT_URL dynamodb scan --table-name nx-sessions

# Get item
aws --endpoint-url=$AWS_ENDPOINT_URL dynamodb get-item \
  --table-name nx-sessions \
  --key '{"session_id": {"S": "abc123"}}'
```

### Redis (ElastiCache) Commands
```bash
# List clusters
aws --endpoint-url=$AWS_ENDPOINT_URL elasticache describe-cache-clusters

# Get cluster details
aws --endpoint-url=$AWS_ENDPOINT_URL elasticache describe-cache-clusters \
  --cache-cluster-id nx-shared-redis-dev1 \
  --show-cache-node-info

# Get endpoint
aws --endpoint-url=$AWS_ENDPOINT_URL elasticache describe-cache-clusters \
  --cache-cluster-id CLUSTER_ID \
  --query 'CacheClusters[0].CacheNodes[0].Endpoint.Address'
```

### RDS Commands
```bash
# List instances
aws --endpoint-url=$AWS_ENDPOINT_URL rds describe-db-instances

# Get instance details
aws --endpoint-url=$AWS_ENDPOINT_URL rds describe-db-instances \
  --db-instance-identifier nx-booking-db-dev1

# Get endpoint
aws --endpoint-url=$AWS_ENDPOINT_URL rds describe-db-instances \
  --db-instance-identifier INSTANCE_ID \
  --query 'DBInstances[0].Endpoint.Address'
```

## 📊 Available Resources

### IAM
- **10+ Roles**: Service accounts, execution roles, layer-specific roles
- **4 Policies**: ECR access, S3 access, DynamoDB access, combined access

### ECR
- **20+ Repositories**: All layers (al, bal, bb, bc, bff, ch, tc, xp)
- **Lifecycle Policies**: Keep last 10 images

### S3
- **6 Buckets**: artifacts, terraform-state, deployment-logs, backup, config, static-assets
- **Features**: Versioning, lifecycle policies, environment folders

### DynamoDB
- **12+ Tables**: sessions, user-profiles, booking-data, flight-cache, offers, payments, configs
- **Features**: TTL, indexes, PAY_PER_REQUEST

### Redis
- **4 Clusters**: dev1, sit1, uat1, prod1
- **Node Types**: t3.micro → r6g.large

### RDS
- **6 Instances**: PostgreSQL + MySQL across environments
- **Features**: Backups, encryption, maintenance windows

## 🔍 Health Checks

```bash
# Overall health
curl http://localhost:4566/_localstack/health | jq '.'

# Check specific service
curl http://localhost:4566/_localstack/health | jq '.services.iam'
curl http://localhost:4566/_localstack/health | jq '.services.s3'
curl http://localhost:4566/_localstack/health | jq '.services.dynamodb'
```

## 🐛 Quick Troubleshooting

### Problem: LocalStack won't start
```bash
# Check Docker
docker ps

# Check port availability
lsof -i :4566

# View logs
docker-compose -f config/docker-compose.yml logs localstack
```

### Problem: AWS commands fail
```bash
# Verify endpoint
echo $AWS_ENDPOINT_URL

# Test connectivity
curl http://localhost:4566/_localstack/health

# Use explicit endpoint
aws --endpoint-url=http://localhost:4566 sts get-caller-identity
```

### Problem: Service not initialized
```bash
# Re-initialize all services
./config/aws-setup/init-all.sh

# Or specific service
./config/aws-setup/init-iam.sh
```

### Problem: Port conflict
```bash
# Find process using port 4566
lsof -i :4566

# Kill process
kill -9 <PID>

# Restart LocalStack
make restart-aws
```

## 📁 File Locations

```
config/aws-setup/
├── init-all.sh          # Master init (run this first)
├── init-iam.sh          # IAM roles & policies
├── init-s3.sh           # S3 buckets
├── init-ecr.sh          # ECR repositories
├── init-dynamodb.sh     # DynamoDB tables
├── init-redis.sh        # Redis clusters
└── init-rds.sh          # RDS instances

tests/e2e/
├── run-all-e2e-tests.sh          # Master test runner
├── test-create-artifact-e2e.sh   # Test artifact creation
├── test-add-redis-e2e.sh         # Test Redis addition
└── test-approve-infra-e2e.sh     # Test infra approval
```

## 🎯 Common Workflows

### 1. First Time Setup
```bash
make setup-aws
make status-aws
make test-e2e
```

### 2. Daily Development
```bash
make status-aws                                  # Check if running
./tests/e2e/test-create-artifact-e2e.sh         # Test changes
aws --endpoint-url=$AWS_ENDPOINT_URL ...        # Manual testing
```

### 3. Fresh Start
```bash
make clean-aws
make setup-aws
```

### 4. Debugging
```bash
make logs-aws                    # View logs
make status-aws                  # Check health
curl http://localhost:4566/_localstack/health | jq '.'
```

## 📚 Documentation

- **Comprehensive Guide**: `docs/AWS_TESTING_GUIDE.md` (20+ pages)
- **Implementation Details**: `LOCALSTACK_IMPLEMENTATION.md`
- **Quick Start**: `docs/QUICK_START_GUIDE.md`
- **Troubleshooting**: `docs/TROUBLESHOOTING.md`

## 💡 Pro Tips

1. **Save endpoint as alias**:
   ```bash
   alias awsl='aws --endpoint-url=http://localhost:4566'
   awsl s3 ls
   ```

2. **Use jq for JSON parsing**:
   ```bash
   awsl iam list-roles | jq '.Roles[].RoleName'
   ```

3. **Create test data quickly**:
   ```bash
   ./config/aws-setup/init-all.sh
   ```

4. **Monitor resources**:
   ```bash
   watch -n 5 'curl -s http://localhost:4566/_localstack/health | jq .'
   ```

5. **Keep data between restarts**:
   ```bash
   make stop-aws    # Instead of clean-aws
   make setup-aws
   ```

---

**Quick Links**:
- LocalStack Dashboard: http://localhost:4566/_localstack/health
- Full Guide: [docs/AWS_TESTING_GUIDE.md](docs/AWS_TESTING_GUIDE.md)
- Support: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
