module "cicd" {
  source = "./cicd"
   organization =  var.organization
   key = var.key
   sonar_cloud_url = var.sonar_cloud_url
   project_name = var.project_name

}



module "s3" {
    source = "./s3"
}