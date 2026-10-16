#!/usr/bin/env python3
# AFG RustFS validation: provision two tenants.
#   user A (keyA): full access to bucket "bucketa" only
#   user B (keyB): full access to bucket "bucketb" only, NO access to bucketa
# Root (rustfsadmin) creates the buckets and the IAM users/policies.
import sys
from minio import Minio
from minio.minioadmin import MinioAdmin
from minio.credentials import StaticProvider

EP = "127.0.0.1:9000"
ROOT_AK = "rustfsadmin"
ROOT_SK = "rustfsadmin"

KEY_A, SEC_A = "userakey0001", "userasecret0001"
KEY_B, SEC_B = "userbkey0001", "userbsecret0001"

def pol(bucket):
    return {
        "Version": "2012-10-17",
        "Statement": [{
            "Effect": "Allow",
            "Action": ["s3:*"],
            "Resource": [f"arn:aws:s3:::{bucket}", f"arn:aws:s3:::{bucket}/*"],
        }],
    }

def main():
    s3 = Minio(EP, access_key=ROOT_AK, secret_key=ROOT_SK, secure=False)
    for b in ("bucketa", "bucketb"):
        if not s3.bucket_exists(b):
            s3.make_bucket(b)
            print(f"created bucket {b}")
        else:
            print(f"bucket {b} exists")

    adm = MinioAdmin(endpoint=EP, credentials=StaticProvider(ROOT_AK, ROOT_SK), secure=False)
    print("policy_add poli-a:", adm.policy_add("poli-a", policy=pol("bucketa")))
    print("policy_add poli-b:", adm.policy_add("poli-b", policy=pol("bucketb")))
    print("user_add A:", adm.user_add(KEY_A, SEC_A))
    print("user_add B:", adm.user_add(KEY_B, SEC_B))
    print("policy_set A:", adm.policy_set("poli-a", user=KEY_A))
    print("policy_set B:", adm.policy_set("poli-b", user=KEY_B))
    print("user_info A:", adm.user_info(KEY_A))
    print("user_info B:", adm.user_info(KEY_B))

if __name__ == "__main__":
    sys.exit(main())
