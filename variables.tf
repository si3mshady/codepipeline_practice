variable "username" {
    type = string
}

variable "password" {
     type = string
}

variable "appID" {
     type = string
}


variable "connectionArn" {
     type = string
}



variable "bucket_name" {
    default = "cicd-si3mshady"
}

variable "bucket_artifacts" {
  default = "cicd-si3mshady-artifacts"
}