# FinWise Production Domain & Cloud Deployment Guide
**Domain**: `finwise-app.xyz`  
**Registrar**: Namecheap (`dns1.registrar-servers.com`, `dns2.registrar-servers.com`)  
**Repository**: [`https://github.com/SocketSync/AIO`](https://github.com/SocketSync/AIO) (Branch: `main`)

---

## 1. Deploy Repository to Vercel (Recommended)

1. Open [vercel.com/new](https://vercel.com/new) and log in with your GitHub account.
2. Under **Import Git Repository**, choose `SocketSync/AIO`.
3. Configure the project:
   - **Framework Preset**: `Other`
   - **Root Directory**: `./` (leave default)
   - **Build & Development Settings**: Leave default (no build command needed; `vercel.json` and `api/` are pre-configured).
4. Click **Deploy**. Vercel will deploy the site in ~15 seconds.

---

## 2. Bind `finwise-app.xyz` in Vercel

1. In your Vercel project dashboard, go to **Settings** $\rightarrow$ **Domains**.
2. Enter `finwise-app.xyz` and click **Add**.
3. Choose the option: **Add `finwise-app.xyz` and redirect `www.finwise-app.xyz` to it**.

---

## 3. Configure DNS Records in Namecheap

Go to your Namecheap account:
1. Navigate to **Domain List** $\rightarrow$ Click **Manage** next to `finwise-app.xyz`.
2. Go to the **Advanced DNS** tab.
3. Delete any default "Parking Page" or "URL Redirect" records.
4. Add the following two records under **Host Records**:

| Type | Host | Value / Target | TTL |
| :--- | :--- | :--- | :--- |
| **A Record** | `@` | `76.76.21.21` | Automatic (or 1 min) |
| **CNAME Record** | `www` | `cname.vercel-dns.com` | Automatic (or 1 min) |

> [!NOTE]
> Vercel automatically detects the DNS records and provisions a free **Let's Encrypt SSL certificate** for `https://finwise-app.xyz` within a few minutes.

---

## 4. Update Supabase Authentication URLs

To ensure Google Sign-In and email authentication work on your live domain:
1. Open your [Supabase Dashboard](https://supabase.com/dashboard/project/vcxxsffdsznmqtpghrss).
2. Go to **Authentication** $\rightarrow$ **URL Configuration**.
3. Set **Site URL**:
   ```
   https://finwise-app.xyz
   ```
4. Under **Redirect URLs**, click **Add URL** and add:
   - `https://finwise-app.xyz/**`
   - `https://www.finwise-app.xyz/**`
   - `https://finwise-app.xyz/dashboard.html`
   - `https://finwise-app.xyz/login.html`
5. Click **Save Changes**.

---

## 5. Google Cloud Console (OAuth Credentials)

In your [Google Cloud Console Credentials](https://console.cloud.google.com/apis/credentials):
1. Select your OAuth 2.0 Web Client.
2. Under **Authorized JavaScript origins**, add:
   - `https://finwise-app.xyz`
   - `https://www.finwise-app.xyz`
3. Under **Authorized redirect URIs**, verify:
   - `https://vcxxsffdsznmqtpghrss.supabase.co/auth/v1/callback`

---

## 6. Live Verification & Demo Credentials

Once the DNS propagates, visit `https://finwise-app.xyz`.

| Account | Email | Password | Role |
| :--- | :--- | :--- | :--- |
| **Demo 1** | `ykwei2005@gmail.com` | `FinWise2026!` | Ken Wei |
| **Demo 2** | `ptutm.kengwei@gmail.com` | `FinWise2026!` | John Yeoh |

