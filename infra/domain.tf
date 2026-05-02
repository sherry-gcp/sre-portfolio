resource "google_cloud_run_domain_mapping" "portfolio_domain" {
    location = google_cloud_run_v2_service.api_server.location
    name     = var.domain_name

    metadata {
        namespace = google_cloud_run_v2_service.api_server.project
    }

    spec {
        route_name = google_cloud_run_v2_service.api_server.name
    }
}

resource "google_dns_record_set" "cloudrun_dns" {
    for_each = {
        for type in toset([for r in google_cloud_run_domain_mapping.portfolio_domain.status[0].resource_records : r.type]) : type => [
            for r in google_cloud_run_domain_mapping.portfolio_domain.status[0].resource_records : r.rrdata if r.type == type
        ]
    }

    name         = "${var.domain_name}."
    managed_zone = var.managed_zone 
    type         = each.key
    ttl          = 300            
    rrdatas      = each.value
}