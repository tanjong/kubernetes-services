resource "azuread_application" "devlab-aksdemo" {
  display_name = "devlab-aksdemo"
}

resource "azuread_service_principal" "devlab-aksdemo" {
  application_id = azuread_application.devlab-aksdemo.application_id
}

resource "azuread_service_principal_password" "devlab-aksdemo" {
  service_principal_id = azuread_service_principal.devlab-aksdemo.id
  value                = random_password.devlab-aksdemo.result
}

