output "repositories" {
  value = { for k, m in module.repo : k => m.html_url }
}
