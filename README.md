# Grimoire Network

This configures an AWS VPC for Grimoire services and makes it available to
other manifests. This VPC also includes a default subnet, in which every node
has an IP6 address and a public IP.

This repository provides the following outputs for use in remote state:

* `vpc_id` for the `grimoire.ca` VPC.
* `subnet_id` for the default subnet.

To access these outputs, add the following data provider to your manifest:

```terraform
data "terraform_remote_state" "network" {
  backend = "s3"

  config {
    bucket = "terraform.grimoire"
    key    = "network.tfstate"
    region = "ca-central-1"
  }
}
```
