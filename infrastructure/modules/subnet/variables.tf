variable "vpc_id" {

}

variable "subnet_details" {
  default = {
    public-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.0.0/27"
      tags = { "kubernetes.io/role/elb" = "1" }
    }
    public-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.0.32/27"
      tags = { "kubernetes.io/role/elb" = "1" }
    }
    inspection-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.0.64/28"
    }
    inspection-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.0.80/28"
    }
    db-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.0.96/28"
    }
    db-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.0.112/28"
    }
    app-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.0.128/26"
    }
    app-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.0.192/26"
    }
  }

}

variable "subnet_details_2" {
  default = {
    public-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.1.0/27"
    }
    public-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.1.32/27"
    }
    inspection-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.1.64/28"
    }
    inspection-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.1.80/28"
    }
    db-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.1.96/28"
    }
    db-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.1.112/28"
    }
    app-subnet-a = {
      az   = "ap-southeast-1a"
      cidr = "10.0.1.128/26"
    }
    app-subnet-b = {
      az   = "ap-southeast-1b"
      cidr = "10.0.1.192/26"
    }
  }

}