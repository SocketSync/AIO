# FinWise Android authentication setup

The Android launcher uses native Java screens and calls the PHP API in `php/api`.
The demo dashboard values are local sample values; the welcome line uses the name
returned by the login endpoint.

## Run locally

1. Install the PHP CLI and configure PHP `mail()` with a working local mail
   transport. The API now reports an error if the transport rejects a message;
   it never treats the development email log as a delivered message.
2. From the repository root in PowerShell, set the emulator-visible link origin
   and start PHP with:

   ```text
   $env:FINWISE_PUBLIC_URL = "http://10.0.2.2:8080"
   php -S 0.0.0.0:8080 -t .
   ```

3. Set `FINWISE_PUBLIC_URL` to the public address of this PHP server. Reset
   links need a reachable URL; `localhost` in an email points to the recipient's
   own device.
4. Build and launch the Android app. It calls `http://10.0.2.2:8080/php/api/`.
   For a physical device or deployed backend, change the `API` constant in
   `android/app/src/main/java/com/finwise/finwise_app/MainActivity.java` to the
   server's reachable HTTPS API URL and disable cleartext traffic in the
   manifest.

User, OTP, and reset-token records are stored outside the web root in
`../finwise_private_data` by default. Set `FINWISE_DATA_DIR` to choose another
private writable directory. Verification codes expire after ten minutes. Resend cooldowns
are checked against the server stored timestamp, so reopening the app cannot
reset the restriction. Password reset links are random, single-use tokens that
expire after ten minutes.
