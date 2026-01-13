# Custom Domain Setup for Fly.io

This guide explains how to add a custom domain to your Fly.io app while preserving existing email records (MX records).

## Important: Email Records Will Be Preserved

**You will NOT lose your email records.** DNS record types are independent:
- **MX records** (for email) can coexist with **A/CNAME records** (for web traffic)
- Adding web records does not affect existing MX records
- Your email will continue to work normally

## Step-by-Step Instructions

### 1. Add the Domain to Fly.io

Run this command in your terminal:

```bash
fly certs create yourdomain.com
```

Replace `yourdomain.com` with your actual domain name.

**Note:** Fly.io will provide you with DNS records to add. You'll see something like:
- An A record pointing to an IP address, OR
- A CNAME record pointing to a Fly.io hostname

### 2. Add DNS Records (Without Removing MX Records)

Go to your DNS provider (wherever you manage your domain's DNS) and add the records Fly.io provided.

**What to add:**
- Add the **A record** or **CNAME record** that Fly.io provided
- **DO NOT delete** any existing MX records
- **DO NOT delete** any other existing records (TXT, SPF, DKIM, etc.)

**Example DNS configuration:**
```
Type    Name    Value                    TTL
A       @       123.45.67.89            3600    (from Fly.io)
MX      @       mail.provider.com        3600    (keep existing)
TXT     @       "v=spf1 ..."            3600    (keep existing)
```

### 3. Verify DNS Records

After adding the records, verify they're all present:

```bash
# Check A/CNAME record (web traffic)
dig yourdomain.com A
# or
dig yourdomain.com CNAME

# Verify MX records still exist (email)
dig yourdomain.com MX
```

You should see both:
- The new A/CNAME record pointing to Fly.io
- Your existing MX records intact

### 4. Wait for SSL Certificate

Fly.io will automatically provision an SSL certificate once DNS propagates (usually 5-10 minutes). Check status:

```bash
fly certs show yourdomain.com
```

Wait until you see `Issued` status.

### 5. Update Your Rails Configuration

Update your Rails production configuration to use the new domain:

**File: `config/environments/production.rb`**

Update the mailer host:
```ruby
config.action_mailer.default_url_options = { host: "yourdomain.com" }
```

If you have host authorization enabled, update it:
```ruby
config.hosts = [
  "yourdomain.com",
  /.*\.yourdomain\.com/ # Allow subdomains
]
```

### 6. Test Everything

1. **Test web access:** Visit `https://yourdomain.com` - should load your app
2. **Test email:** Send a test email to an address at your domain - should still work
3. **Test SSL:** Verify the padlock icon appears in your browser

## Common DNS Providers

### Cloudflare
- Go to DNS → Records
- Add new A or CNAME record
- Keep all existing records

### Namecheap
- Go to Domain List → Manage → Advanced DNS
- Add new A or CNAME record
- Keep all existing records

### GoDaddy
- Go to DNS Management
- Add new A or CNAME record
- Keep all existing records

### Google Domains / Google Cloud DNS
- Go to DNS → Custom records
- Add new A or CNAME record
- Keep all existing records

## Troubleshooting

### Email stops working
- **Check MX records:** `dig yourdomain.com MX`
- If MX records are missing, restore them from your DNS provider's backup/history
- MX records should point to your email provider (e.g., Google Workspace, Microsoft 365, etc.)

### Website doesn't load
- **Check DNS propagation:** Use `dig yourdomain.com` or [whatsmydns.net](https://www.whatsmydns.net)
- **Check Fly.io cert status:** `fly certs show yourdomain.com`
- **Check Fly.io logs:** `fly logs`

### SSL certificate not issuing
- Ensure DNS records are correctly set
- Wait 10-15 minutes for propagation
- Check `fly certs show` for error messages

## Additional Notes

- **Subdomains:** If you want `www.yourdomain.com`, add it separately: `fly certs create www.yourdomain.com`
- **Root vs www:** You can have both `yourdomain.com` and `www.yourdomain.com` pointing to Fly.io
- **Email subdomains:** If you use `mail.yourdomain.com` for email, that's separate and won't be affected

## Need Help?

- Fly.io Docs: https://fly.io/docs/app-guides/custom-domains-with-fly/
- Fly.io Community: https://community.fly.io/
