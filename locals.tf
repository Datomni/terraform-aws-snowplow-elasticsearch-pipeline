locals {
  custom_iglu_resolvers = [
    {
      name            = "Iglu Server"
      priority        = 0
      uri             = "${var.iglu_server_url}/api"
      api_key         = var.iglu_server_apikey
      vendor_prefixes = []
    }
  ]
}
