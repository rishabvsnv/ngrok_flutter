use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int};
use std::sync::Mutex;
use tokio::runtime::Runtime;
use tokio::net::TcpStream;
use tokio::io::copy_bidirectional;
use ngrok::prelude::*;
use futures::StreamExt;

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

    let result = RUNTIME.block_on(async move {
        let session = ngrok::Session::builder()
            .authtoken(token_str)
            .connect()
            .await
            .ok()?;

        let mut tunnel = session
            .http_endpoint()
            .listen()
            .await
            .ok()?;

        let url = tunnel.url().to_string();

        // Spawn a background task to proxy incoming tunnel connections to the local port
        RUNTIME.spawn(async move {
            let local_addr = format!("127.0.0.1:{}", local_port);
            while let Some(Ok(mut inbound)) = tunnel.next().await {
                let target = local_addr.clone();
                tokio::spawn(async move {
                    if let Ok(mut outbound) = TcpStream::connect(&target).await {
                        let _ = copy_bidirectional(&mut inbound, &mut outbound).await;
                    }
                });
            }
        });

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