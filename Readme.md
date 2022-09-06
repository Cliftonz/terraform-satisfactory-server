
# Terraform Satisfactory Deployment
## ⚠ This Module is Still in Beta; See todo section below ⚠
<p float="left">
  <img src="assests\terraform.png" width="100"  alt=""/>
  <img src="assests\ecs.png" width="100"  alt=""/> 
  <img src="assests\Satisfactory.png" width="100"  alt=""/>
</p>

This Terraform module allows you to provision a Satisfactory Server in AWS ECS in an AWS Region near to you and your friends. 

Shout out to [welveix](https://github.com/wolveix) for creating and maintaining the satisfactory docker image.

### Prerequisites 
1. Create an [AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
2. Create an [IAM user](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html#id_users_create_console) that has admin access and copy the access key and access secret (If you know what your doing feel free to make an account with the least privileges.) 
3. Install [AWS-CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html#getting-started-install-instructions) and put in your access key and access secret into the tool.
4. Install [terraform cli](https://learn.hashicorp.com/tutorials/terraform/install-cli)

![](assests\Sat2AWS.png)

Note: No dogos are harmed in the making of this satisfactory automation.

### Installing the server
1. Clone this repository locally and cd into the example directory
2. Run ```terraform init; terraform apply -auto-approve```
3. Copy the url from the console and paste it into satisfactory to connect.

If you have turned off the dns feature, follow the steps below to find your servers ip.
1. Go to [aws ecs console](https://us-east-2.console.aws.amazon.com/ecs/v2/clusters); Make sure your in the correct region.
2. Click the game cluster
3. Click tasks and choose the ```Satisfactory-Server``` task and copy the public ip into Satisfactory.

### Costs and Consideration

Note: This costs may not be up-to-date this is just and example on the cost savings.

The satisfactory server runs the best with servers that have a high single core clock speed. 
AWS offers two classes of servers that offer 4 GHz< single core speed, the m5zn and z1d server family.
An alternative and cheaper option is run fargate spot instances however these are only clocked around 2.8 GHz and 
may not give a smooth experience for larger servers or servers with more people connected.  

AWS does charge for data egress (i.e. data being sent from the server to the clients) and for the dns lookups, however these will be at most a few cents and are negligible compared to the ec2 instances.

In terms of price vs utilization for most servers the m5zn.xlarge is the optimal for both on-demand and spot pricing.

We have reflected this in our default deploy. 

#### Expected Cost and Cost Breakdown per Server
| Instance Type          | CPUs | RAM (GiB) | Clock Speed (GHz) | Cost Per Hour | Comparable Fargate Cost Per Hour |
|------------------------|------|-----------|-------------------|---------------|----------------------------------|
| z1d.large              | 2    | 16        | 4.5               | 0.186         | 0.15208                          |
| z1d.xlarge             | 4    | 32        | 4.5               | 0.372         | 0.30416                          |
| m5zn.large             | 2    | 8         | 4.5               | 0.1652        | 0.11652                          |
| m5zn.xlarge            | 4    | 16        | 4.5               | 0.3303        | 0.23304                          |
| One Fargate CPU        | 1    | Na        | 2.8               | 0.04048       | Na                               |
| One Fargate GiB of Ram | Na   | 1         | Na                | 0.004445      | Na                               |

Thus see the chart on what is the expected cost for gaming a certain amount of hours per month per ecs server type. *Spot instance pricing is not calculated*

| Cost per Set Hours a Month         | 1     | 2     | 4     | 6     | 10    | 12    | 14    |
|------------------------------------|-------|-------|-------|-------|-------|-------|-------|
| z1d.large                          | $0.19 | $0.37 | $0.74 | $1.12 | $1.49 | $2.23 | $2.60 |
| z1d.xlarge                         | $0.37 | $0.74 | $1.49 | $2.23 | $2.98 | $4.46 | $5.21 |
| m5zn.large                         | $0.17 | $0.33 | $0.66 | $0.99 | $1.32 | $1.98 | $2.31 |
| m5zn.large                         | $0.33 | $0.66 | $1.32 | $1.98 | $2.64 | $3.96 | $4.62 |
| Fargate Comparaible to z1d.large   | $0.15 | $0.30 | $0.61 | $0.91 | $1.22 | $1.82 | $2.13 |
| Fargate Comparaible to z1d.xlarge  | $0.30 | $0.61 | $1.22 | $1.82 | $2.43 | $3.65 | $4.26 |
| Fargate Comparaible to m5zn.large  | $0.12 | $0.23 | $0.47 | $0.70 | $0.93 | $1.40 | $1.63 |
| Fargate Comparaible to m5zn.xlarge | $0.23 | $0.47 | $0.93 | $1.40 | $1.86 | $2.80 | $3.26 |

## FAQ

#### Do I need to do any networking configuration in AWS?

No, this module creates all the infrastructure, networking, and security groups for you.

#### What if my server is terminated due to my Spot Request being outbid?

All the configs and saves are stored on EFS thus you will only lose the data since your last save ( up to 5 minutes). Your server will come back in 3-5 minutes.
We try to mitigate this by setting the save interval to 90 seconds if spot instances are chosen.

#### My server keeps getting terminated, and it is making me very frustrated.

We are absolutely understanding of the frustration, in this case you will want to move your underlying infrastructure to fargate servers or go with on-demand pricing instead of spot pricing.

You can also put your spot price closer to the on-demand price but there is no guarantee that your instance will be terminated.

Note: if you do go to the fargate servers the server may run slower than usual as they run at a clock speed of 2.5 GHz. 

#### I am organizing a Satisfactory party how do I ensure that everyone has a good time?


#### How do I play the beta version of Satisfactory?


#### How do I change my instance type?
Set the instance type in the tf var file and redeploy.

#### How do I change my spot price limit?

Set the limit in the tf var file and redeploy.

#### I am done with Satisfactory, how do I delete my server?
Run ```terraform destroy``` and the only infrastructure left will be your EFS instance with yours saves.

#### How do I load an existing save?
When you connect to the Server for the first time you will need to claim it and set a master password. Once you do you will be able to upload your saves for everyone to play.

## TODO

- Tighten Security Group
- Add Cloud map DNS option
- Add EC2 Deployment option
- Add Spot instance option
  - for fargate
  - for ec2
  - If ec2 spot instance, set server save interval to every minute.
- Create a lambda function to turn off the server after x many hours as a backup.

## Help / Support

Your mileage may vary with this deployment, however if you get stuck or encounter a bug create an issue and myself or someone else may come along and assist.

## References
- https://github.com/wolveix/satisfactory-server
- https://satisfactory.fandom.com/wiki/Dedicated_servers
- https://github.com/orgs/cloudposse/repositories

