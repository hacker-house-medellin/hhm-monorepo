fn main() {
    if let Err(error) = hhm_catalog::validate() {
        eprintln!("invalid service catalog: {error}");
        std::process::exit(2);
    }
    println!("organization={}", hhm_catalog::ORGANIZATION);
    for service in hhm_catalog::SERVICES { println!("service={service}"); }
}
