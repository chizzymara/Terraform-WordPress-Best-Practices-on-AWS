variable "region1" {
  type        = string
  description = "aws region 1"
  default     = "eu-central-1"
}

variable "region2" {
  type        = string
  description = "aws region 2"
  default     = "eu-west-1"
}

variable "AvailabilityZone1" {
  type        = string
  description = "available zone 1"
  default     = "eu-central-1a"
}

variable "AvailabilityZone2" {
  type        = string
  description = "available zone 2"
  default     = "eu-central-1b"
}

variable "Key_pair_name" {
  type        = string
  description = "key pair name to be used to ssh to all our instances. must be created on the aws console and securely downloaded to system. only the name is required here"
  default     = "wordpress2"
}

variable "asg-max-size" {
  type        = number
  description = "maximum number of instances"
  default     = "2"
}

variable "asg-min-size" {
  type        = number
  description = "minimum number of instances"
  default     = "1"
}

variable "asg-desired-size" {
  type        = number
  description = "desired number of instances"
  default     = "2"
}

variable "dnsName" {
  type        = string
  description = "name of the dns. should aleady be connected to route53"
  default     = "cloudchaser.live"
}

variable "availability-zones" {
  type        = list(any)
  description = "list of avalaibility zones for efs"
  default     = ["eu-central-1a", "eu-central-1b"]
}