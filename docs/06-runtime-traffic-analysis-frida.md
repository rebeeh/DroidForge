# Runtime Traffic Analysis with Frida

When network interception fails due to custom networking stacks, binary serialization, or strict certificate validation, **dynamic runtime instrumentation** with [Frida](https://frida.re/) allows inspecting network activity directly from process memory.

---

## 1. Why Use Frida for Network Analysis?

Standard network proxies sit on the wire between the client and server. If the application rejects the proxy's TLS certificate or uses direct raw sockets, the proxy cannot display plaintext traffic.

Frida operates inside the application's process space:
- **Pre-Encryption Inspection**: Captures HTTP requests, URLs, and headers before TLS encryption takes place.
- **Post-Decryption Inspection**: Reads response bodies immediately after decryption.
- **Protocol Agnostic**: Intercepts data regardless of whether the underlying transport uses TCP, UDP, or QUIC.

```text
+-------------------------------------------------------------------------+
|                        Application Process Space                        |
|                                                                         |
|  [ Business Logic ]                                                     |
|          |                                                              |
|          v                                                              |
|  [ Network API ] ------> [ Frida Hook ] ===> Logs: URLs, Headers, Body  |
|  (OkHttp / HttpURLConnection)                                           |
|          |                                                              |
|          v                                                              |
|  [ TLS Engine ] (Encryption occurs here)                                |
|          |                                                              |
|          v                                                              |
|  [ Raw Sockets ] (Encrypted wire bytes sent to network interface)       |
+-------------------------------------------------------------------------+
```

---

## 2. Deploying frida-server on Waydroid

### Step 1: Install Frida Tools on Linux Host
```bash
python3 -m pip install --upgrade frida frida-tools
```

### Step 2: Push and Launch frida-server in Waydroid
Use the included DroidForge helper script:
```bash
./scripts/setup-frida-server.sh
```

Or manually:
1. Identify the container architecture:
   ```bash
   adb shell getprop ro.product.cpu.abi
   # e.g., arm64-v8a or x86_64
   ```
2. Download the matching `frida-server-*-android-<arch>.xz` release from [Frida GitHub Releases](https://github.com/frida/frida/releases).
3. Extract and push to the container:
   ```bash
   unxz frida-server-*-android-*.xz
   adb push frida-server-* /data/local/tmp/frida-server
   adb shell chmod 755 /data/local/tmp/frida-server
   ```
4. Run the daemon inside the container:
   ```bash
   adb shell "nohup /data/local/tmp/frida-server >/dev/null 2>&1 &"
   ```

### Step 3: Verify the Connection
From your host, list active processes in Waydroid:
```bash
frida-ps -U
```

---

## 3. Tracing Network Calls (Example Scripts)

### A. Tracing Java `HttpURLConnection`
To log all outbound HTTP/HTTPS connections created through standard Java APIs, attach the following JavaScript hook:

```javascript
// trace_http.js
Java.perform(function () {
    var HttpURLConnection = Java.use("java.net.HttpURLConnection");

    HttpURLConnection.connect.implementation = function () {
        var url = this.getURL().toString();
        var method = this.getRequestMethod();
        console.log("[HTTP Connect] " + method + " " + url);
        return this.connect();
    };

    HttpURLConnection.getInputStream.implementation = function () {
        var url = this.getURL().toString();
        var responseCode = this.getResponseCode();
        console.log("[HTTP Response] (" + responseCode + ") " + url);
        return this.getInputStream();
    };
});
```

Run against your target application:
```bash
frida -U -f <package.name> -l trace_http.js
```

---

### B. Tracing OkHttp3 Requests
Many modern Android applications use [OkHttp](https://square.github.io/okhttp/) as their underlying client. You can log requests and headers by hooking `RealCall`:

```javascript
// trace_okhttp.js
Java.perform(function () {
    try {
        var RealCall = Java.use("okhttp3.internal.connection.RealCall");
        RealCall.execute.implementation = function () {
            var request = this.request();
            console.log("[OkHttp Request] " + request.method() + " " + request.url().toString());
            return this.execute();
        };
    } catch (err) {
        console.log("[-] OkHttp3 not found or obfuscated in target: " + err);
    }
});
```

---

### C. Tracing Low-Level Socket Destinations
When an application uses native C++ networking engines (like Cronet or Tigon) that bypass Java APIs entirely, hook the native POSIX `connect` syscall to observe destination IP addresses and ports:

```javascript
// trace_sockets.js
Interceptor.attach(Module.findExportByName("libc.so", "connect"), {
    onEnter: function (args) {
        var fd = args[0].toInt32();
        var sockaddr = args[1];
        var sa_family = Memory.readU16(sockaddr);

        // AF_INET (IPv4)
        if (sa_family === 2) {
            var port = (Memory.readU8(sockaddr.add(2)) << 8) | Memory.readU8(sockaddr.add(3));
            var ip = [];
            for (var i = 0; i < 4; i++) {
                ip.push(Memory.readU8(sockaddr.add(4 + i)));
            }
            console.log("[Native Socket] Connecting to " + ip.join(".") + ":" + port + " (fd: " + fd + ")");
        }
    }
});
```

---

## 4. Summary Matrix

| Analysis Goal | Tool / Technique | Observability Level |
| :--- | :--- | :--- |
| **Discovering Hostnames & Ports** | `scripts/capture-traffic.sh` (tcpdump) | Transport wire level |
| **Unencrypted HTTP/HTTPS Inspection** | `mitmproxy` + System CA Overlay | Network proxy level |
| **Bypassed / Native Networking Analysis** | `frida` Java & Libc Socket hooks | In-process runtime level |
