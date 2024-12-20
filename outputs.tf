output "lb_url" {
  value = module.my-webapp.web_loadbalancer_url.dns_name
}
