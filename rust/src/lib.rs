use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};
use std::sync::Mutex;
use tokio::runtime::Runtime;
use ngrok::config::ForwarderBuilder;
use ngrok::tunnel::EndpointInfo; // <-- Trait providing .url()
use url::Url;

lazy_static::lazy_static! {
    static ref RUNTIME: Runtime = Runtime::new().unwrap();
    static ref SESSION_HANDLE: Mutex<Option<ngrok::Session>> = Mutex::new(None);
}

#[no_mangle]
pub extern "C" fn ngrok_start_tunnel(
    authtoken: *const c_char,
    local_port: c_int,
) -> *mut c_char {
    if authtoken.is_null() {
        return std::ptr::null_mut();
    }

    let token_str = unsafe { CStr::from_ptr(authtoken).to_string_lossy().into_owned() };
    
    let forward_str = format!("http://127.0.0.1:{}", local_port);
    let target_url = match Url::parse(&forward_str) {
        Ok(u) => u,
        Err(_) => return std::ptr::null_mut(),
    };

    let result = RUNTIME.block_on(async move {
        let session = ngrok::Session::builder()
            .authtoken(token_str)
            .connect()
            .await
            .ok()?;

        let forwarder = session
            .http_endpoint()
            .listen_and_forward(target_url)
            .await
            .ok()?;

        let url = forwarder.url().to_string();

        let mut handle = SESSION_HANDLE.lock().unwrap();
        *handle = Some(session);

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