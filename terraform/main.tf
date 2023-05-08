#Datasource - Azure KeyVault Parameters - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault
data "azurerm_key_vault" "keyvault" {
  name = var.key_vault_name
  resource_group_name = var.keyvault_resource_group_name
}

// Resource Key for SOPS file - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_key
resource "azurerm_key_vault_key" "sops_key" {
    name         = "sops-key"
    key_vault_id = data.azurerm_key_vault.keyvault.id
    key_type     = "RSA"
    key_size     = 2048

    key_opts = [
        "decrypt",
        "encrypt"
    ]

}

output "sops_key" {
  value = azurerm_key_vault_key.sops_key.id
}


data "sops_file" "charset" {
  source_file = "../sops/src/encrypted-file.yaml"
}

# Resource Secret - https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "key_vault_secret" {
    for_each                = toset(local.secrets)
    name                    = "${each.key}-secret"
    value                   = data.sops_file.charset.data["${each.key}.value"]
    key_vault_id            = data.azurerm_key_vault.keyvault.id
}


# Resource Random Password - https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "azurerm_key_vault_secret" "key_vault_secret_with_password" {
    name                    = "random-password-secret"
    value                   = random_password.password.result
    key_vault_id            = data.azurerm_key_vault.keyvault.id
}

output "random_password" {
  value = "${random_password.password.result}"
  sensitive = true
}

