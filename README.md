# CloudWatch EMF
Using CloudWatch Embedded Metric Format to generate business metrics

## Deploy
```bash
python3 -m venv .venv
source .venv/bin/activate

cd code/business_metrics
pip install -r requirements.txt --target .

terraform plan
terraform apply -auto-approve
```

## Generate metrics
```bash
python3 -m venv .venv
source .venv/bin/activate

python scripts/generator.py
```

## Test
```bash
aws cloudwatch ...
```