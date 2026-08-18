use std::ffi::{CStr, CString};
use std::os::raw::c_char;
use std::sync::Mutex;
use tokio::runtime::Runtime;
use ngrok::config::ForwarderBuilder;
use ngrok::tunnel::EndpointInfo;
use ngrok::forwarder::Forwarder;
use ngrok::tunnel::HttpTunnel;
use url::Url;

lazy_static::lazy_static! {
    static ref RUNTIME: Runtime = Runtime::new().unwrap();
    static ref ACTIVE_FORWARDER: Mutex<Option<Forwarder<HttpTunnel>>> = Mutex::new(None);
}

#[no_mangle]
pub extern "C" fn ngrok_start_tunnel(
    authtoken: *const c_char,
    target_addr: *const c_char,
) -> *mut c_char {
    if authtoken.is_null() || target_addr.is_null() {
        return std::ptr::null_mut();
    }

    let token_str = unsafe { CStr::from_ptr(authtoken).to_string_lossy().into_owned() };
    let mut raw_target = unsafe { CStr::from_ptr(target_addr).to_string_lossy().into_owned() };

    // Auto-prefix with http:// if only host:port or port was supplied
    if !raw_target.starts_with("http://") && !raw_target.starts_with("https://") {
        if raw_target.parse::<u16>().is_ok() {
            raw_target = format!("http://127.0.0.1:{}", raw_target);
        } else {
            raw_target = format!("http://{}", raw_target);
        }
    }

    let target_url = match Url::parse(&raw_target) {
        Ok(u) => u,
        Err(_) => return std::ptr::null_mut(),
    };

    let result = RUNTIME.block_on(async move {
        // Connect session
        let session = ngrok::Session::builder()
            .authtoken(token_str)
            .connect()
            .await
            .ok()?;

        // Start forwarder with host header rewritten to the local target
        let forwarder = session
            .http_endpoint()
            .forwards_to("localhost")
            .listen_and_forward(target_url)
            .await
            .ok()?;

        let url = forwarder.url().to_string();

        let mut handle = ACTIVE_FORWARDER.lock().unwrap();
        *handle = Some(forwarder);

        Some(url)
    });

    match result {
        Some(url) => CString::new(url).unwrap().into_raw(),
        None => std::ptr::null_mut(),
    }
}

#[no_mangle]
pub extern "C" fn ngrok_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe { drop(CString::from_raw(s)) };
    }
}