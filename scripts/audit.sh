#!/usr/bin/env bash
set -Eeuo pipefail
umask 077

# AWS Cloud Security & Governance - Read-only audit
REGION="${AWS_REGION:-us-east-1}"
TRAIL_NAME="${CLOUDTRAIL_NAME:-CloudSecurityAuditTrail}"
BUCKET_NAME="${AUDIT_BUCKET_NAME:-}"
: "${BUCKET_NAME:?AUDIT_BUCKET_NAME doit être défini}"
OUTPUT_DIR="evidence"

mkdir -p "$OUTPUT_DIR/cloudtrail" "$OUTPUT_DIR/iam" "$OUTPUT_DIR/s3"

if ! aws sts get-caller-identity --output json \
  > "$OUTPUT_DIR/iam/caller-identity.json"; then
  echo "ERREUR : impossible de vérifier l'identité AWS." >&2
  exit 1
fi

echo "Identité AWS vérifiée."

echo "1/5 - Vérification de CloudTrail..."
aws cloudtrail get-trail \
  --name "$TRAIL_NAME" \
  --region "$REGION" \
  --output json \
  > "$OUTPUT_DIR/cloudtrail/trail-config.json"

aws cloudtrail get-trail-status \
  --name "$TRAIL_NAME" \
  --region "$REGION" \
  --output json \
  > "$OUTPUT_DIR/cloudtrail/trail-status.json"

echo "2/5 - Vérification du blocage public du compte..."
aws s3control get-public-access-block \
  --account-id "$(aws sts get-caller-identity --query Account --output text)" \
  --region "$REGION" \
  --output json \
  > "$OUTPUT_DIR/s3/account-public-access-block.json"

echo "3/5 - Vérification du bucket S3..."
aws s3api get-public-access-block \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --output json \
  > "$OUTPUT_DIR/s3/bucket-public-access-block.json"

aws s3api get-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --output json \
  > "$OUTPUT_DIR/s3/bucket-encryption.json"

aws s3api get-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --output json \
  > "$OUTPUT_DIR/s3/bucket-versioning.json"

echo "4/5 - Vérification des politiques IAM de l'utilisateur..."
aws iam list-attached-user-policies \
  --user-name Bamba \
  --output json \
  > "$OUTPUT_DIR/iam/attached-policies.json"

aws iam list-groups-for-user \
  --user-name Bamba \
  --output json \
  > "$OUTPUT_DIR/iam/groups.json"

aws iam list-access-keys \
  --user-name Bamba \
  --query 'AccessKeyMetadata[].{Status:Status,CreateDate:CreateDate}' \
  --output json \
  > "$OUTPUT_DIR/iam/access-keys-metadata.json"

echo "5/5 - Audit terminé."
echo "Résultats enregistrés dans $OUTPUT_DIR/"
echo "Attention : vérifie les fichiers avant tout commit Git."
