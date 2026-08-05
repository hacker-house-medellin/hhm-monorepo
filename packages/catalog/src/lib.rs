pub const ORGANIZATION: &str = "hacker-house-medellin";
pub const SERVICES: &[&str] = &[
    "hhm-interfaces",
    "hhm-api",
    "hhm-web-mash",
    "hhm-web-leptos",
    "hhm-web-dioxus",
    "hhm-cli",
    "hhm-sync",
    "hhm-infra",
    "hhm-clients",
    "hhm-libs",
];

pub fn validate() -> Result<(), &'static str> {
    if SERVICES.is_empty() { return Err("service catalog is empty"); }
    if SERVICES.iter().any(|service| service.trim().is_empty()) { return Err("service name is empty"); }
    let mut sorted = SERVICES.to_vec();
    sorted.sort_unstable();
    sorted.dedup();
    if sorted.len() != SERVICES.len() { return Err("duplicate service name"); }
    Ok(())
}

#[cfg(test)]
mod tests {
    #[test]
    fn catalog_is_valid() { assert!(super::validate().is_ok()); }
}
