# VPC endpoint demo

what we're able to achieve : SSH connection from monitoring VM to target_0 & target_1

## diagram of the demo
![architecture](./docs/architecture.png)

## apply


## test

after applying the terraform code, you should be able to log into target_0 & target_1 using, respectively :

```
ssh -J admin@<monitoring_public_ip> <dns_name_target_0_endpoint>
```

```
ssh -J admin@<monitoring_public_ip> <dns_name_target_1_endpoint>
```

## Endpoint specific infrastructure :

have a look at [./vpc_endpoints.tf](./vpc_endpoints.tf) to see what is actually related to vpc_endpoint (NLB, vpc_endpoint_service, vpc_endpoint )
