terraform {
  backend "s3" {
    # Backend configuration will be provided via:
    # - terraform init -backend-config="backend.hcl"
    # - Or via environment variables
    # - Or via command line flags: -backend-config="bucket=..." etc.
  }
}
