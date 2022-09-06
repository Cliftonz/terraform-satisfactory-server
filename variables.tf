variable "region" {
  type        = string
  default = "us-east-1"
  description = "AWS Region"
}

variable "memory" {
  type = number
  default = 8
  description = "Amount of RAM in GB to give to the Satisfactory Server. Default is set to 8 as recommended in the wiki."
}

variable "cpu" {
  type = number
  default = 3
  description = "Number of CPUs to allocate to the server. Satisfactory is primarily single threaded and benefits more from a higher clock speed over multiple cores."
}

variable "max_players" {
  type = number
  default = 4
  description = "Max Number of players that the server will allow. It is recommended to bump the RAM by 1 GB per extra player actually connecting."
}

variable "launch_type" {
  type = string
  description = "The ECS launch type (valid options: FARGATE, FARGATE_SPOT or EC2)"
  default     = "FARGATE"
}

variable "prevent_data_deletion"{
  type = bool
  description = "Prevent data being lost from deleting efs volume."
  default     = true
}

variable "data_backup"{
  type = bool
  description = "Back up data to S3 "
  default     = false
}

#variable "EC2" {
#  type = object({
#    instance_type = string
#
#  })
#  default = 4
#  description = "Max Number of players that the server will allow. It is recommended to bump the RAM by 1 GB per extra player."
#}



