# Serverless CCP - Amazon Connect Custom Contact Control Panel

This directory contains a serverless Custom Contact Control Panel (CCP) deployment for Amazon Connect, hosted on AWS S3 and distributed via CloudFront.

## Architecture

- **S3 Bucket**: Static website hosting for CCP files
- **CloudFront**: CDN distribution with HTTPS support
- **Terraform**: Infrastructure as Code for automated deployment

## Files

### HTML Pages
- **SimpleAgentConsole.html** - Full-featured agent console with:
  - Two-panel layout (CCP on left, Contact Details on right)
  - Agent status display with color-coded badges
  - Real-time contact information display
  - Event logging panel
  - Customer phone number and name display

- **ccp.html** - Minimal CCP embedded page
  - Simple iframe wrapper for the standard CCP
  - Useful for embedding in other applications

### JavaScript Libraries
- **connect-streams-min.js** - Amazon Connect Streams API library (v2.22.0)
  - Minified build from amazon-connect-streams repository
  - Required for CCP functionality

## Deployment Instructions

### 1. Configure Instance URLs

Before deploying, update the instance URLs in both HTML files:

**In SimpleAgentConsole.html (line 211):**
```javascript
const instanceUrl = 'https://YOUR-INSTANCE-NAME.my.connect.aws/ccp-v2';
const region = 'us-east-1';  // Change to your region
```

**In ccp.html (line 24):**
```javascript
const instanceUrl = 'https://YOUR-INSTANCE-NAME.my.connect.aws/ccp-v2';
const region = 'us-east-1';  // Change to your region
```

Replace `YOUR-INSTANCE-NAME` with your actual Amazon Connect instance alias.

### 2. Deploy Infrastructure with Terraform

The S3 bucket and CloudFront distribution are managed via Terraform modules.

#### a. Update Terraform Variables

Edit `terraform/terraform.tfvars` or set the variable:
```hcl
ccp_bucket_name = "hotel-booking-ccp-hosting"  # Or your preferred bucket name
```

#### b. Deploy with Terraform

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

This will create:
- S3 bucket for hosting CCP files
- CloudFront distribution with OAI (Origin Access Identity)
- Bucket policy for CloudFront access
- All necessary security configurations

#### c. Get CloudFront URL

After deployment, get the CloudFront URL:
```bash
terraform output ccp_cloudfront_url
```

You'll see output like:
```
ccp_cloudfront_url = "https://d1234567890abc.cloudfront.net"
```

### 3. Upload Files to S3

Upload the CCP files to your S3 bucket:

```bash
# Set your bucket name
BUCKET_NAME=$(terraform output -raw ccp_s3_bucket_name)

# Upload all files
aws s3 cp SimpleAgentConsole.html s3://$BUCKET_NAME/
aws s3 cp ccp.html s3://$BUCKET_NAME/
aws s3 cp connect-streams-min.js s3://$BUCKET_NAME/
```

Or upload via AWS Console:
1. Go to AWS Console > S3
2. Find your bucket (e.g., `hotel-booking-ccp-hosting`)
3. Upload all three files

### 4. Configure Amazon Connect Approved Origins

**CRITICAL**: You must add the CloudFront domain as an approved origin.

1. Go to AWS Console > Amazon Connect
2. Click on your instance
3. In the left menu, click **"Application integration" > "Approved origins"**
4. Click **"Add origin"**
5. Add your CloudFront URL: `https://d1234567890abc.cloudfront.net`
6. Click **"Add"**

**Without this step, the CCP will not load due to CORS restrictions.**

### 5. Access Your CCP

Open your CloudFront URL in a browser:
- **Full Console**: `https://d1234567890abc.cloudfront.net/SimpleAgentConsole.html`
- **Simple CCP**: `https://d1234567890abc.cloudfront.net/ccp.html`

## Features

### SimpleAgentConsole.html Features

#### Agent Status Panel
- Agent name display
- Real-time status with color-coded badges:
  - 🟢 **Available** - Green
  - 🔴 **Offline** - Gray
  - 🟠 **ACW** (After Call Work) - Orange
  - 🔵 **On Call** - Blue
- Agent extension number

#### Contact Details Panel
Shows real-time information for active contacts:
- Contact ID
- Contact Type (Voice, Chat, Task)
- Current State (Connecting, Connected, etc.)
- Customer Name (from contact attributes)
- Customer Phone Number
- Queue Name

#### Event Log
Real-time logging of all CCP events:
- Agent state changes
- Contact arrivals
- Contact state transitions
- Connection events
- Timestamped entries

### Browser Support

- ✅ Google Chrome (Recommended)
- ✅ Mozilla Firefox
- ✅ Microsoft Edge
- ⚠️ Safari (Limited support)
- ❌ Internet Explorer (Not supported)

## Customization

### Change CCP Size

In `SimpleAgentConsole.html`, modify the CSS (lines 30-33):
```css
.ccp-panel {
    width: 420px;      /* Adjust width (320-420px recommended) */
    min-width: 420px;
}
```

### Disable Ringtone

In both HTML files, update the softphone config:
```javascript
softphone: {
    allowFramedSoftphone: true,
    disableRingtone: true  // Set to true to disable
}
```

### Use Custom Ringtone

Upload your ringtone MP3 to S3 and reference it:
```javascript
softphone: {
    allowFramedSoftphone: true,
    ringtoneUrl: './custom-ringtone.mp3'
}
```

## Troubleshooting

### CCP Not Loading

**Issue**: Blank screen or CORS error in console

**Solutions**:
1. Verify CloudFront domain is added to **Approved origins** in Amazon Connect
2. Check that instance URL is correct in HTML files
3. Ensure CloudFront distribution status is "Deployed" (check AWS Console)
4. Clear browser cache and try again

### Authentication Issues

**Issue**: Login popup doesn't appear or fails

**Solutions**:
1. Verify your user has agent permissions in Amazon Connect
2. Check if your instance uses SAML authentication (may need custom loginUrl)
3. Ensure cookies and popups are allowed in browser

### Contact Details Not Showing

**Issue**: Contact panel shows "No active contact" even when on a call

**Solutions**:
1. Check browser console for JavaScript errors
2. Verify Streams API is loaded (check Network tab)
3. Ensure agent is logged in (check Agent Status panel)
4. Refresh the page and try again

### CloudFront Updates Not Reflecting

**Issue**: Code changes not visible after S3 upload

**Solutions**:
1. CloudFront has a 60-second cache (configured in Terraform)
2. Wait 60 seconds and refresh, or
3. Create invalidation in CloudFront Console:
   ```bash
   DISTRIBUTION_ID=$(terraform output -raw ccp_cloudfront_distribution_id)
   aws cloudfront create-invalidation --distribution-id $DISTRIBUTION_ID --paths "/*"
   ```

## Security Notes

1. **HTTPS Only**: CloudFront enforces HTTPS for all connections
2. **Private S3 Bucket**: S3 bucket is not publicly accessible
3. **OAI Access**: Only CloudFront can access S3 bucket via Origin Access Identity
4. **Approved Origins**: Must explicitly allow domains in Connect instance
5. **No Credentials in Code**: Never hardcode credentials or sensitive data

## Terraform Outputs

After deployment, useful outputs:

```bash
# CloudFront URL (use this to access CCP)
terraform output ccp_cloudfront_url

# CloudFront domain (add to approved origins)
terraform output ccp_cloudfront_domain_name

# S3 bucket name (for file uploads)
terraform output ccp_s3_bucket_name

# CloudFront distribution ID (for cache invalidations)
terraform output ccp_cloudfront_distribution_id
```

## Infrastructure Details

### S3 Bucket Configuration
- **Public Access**: Blocked (all settings)
- **Bucket Policy**: Allows CloudFront OAI GetObject access only
- **Encryption**: Default S3 encryption
- **Versioning**: Not enabled (optional to enable)

### CloudFront Configuration
- **Price Class**: PriceClass_100 (North America & Europe)
- **Default TTL**: 60 seconds (for easy updates)
- **HTTPS**: Enforced via redirect-to-https
- **Compression**: Enabled (gzip/brotli)
- **IPv6**: Enabled
- **Default Root Object**: SimpleAgentConsole.html

## Maintenance

### Updating CCP Files

1. Modify HTML files locally
2. Upload to S3:
   ```bash
   BUCKET_NAME=$(cd ../terraform && terraform output -raw ccp_s3_bucket_name)
   aws s3 cp SimpleAgentConsole.html s3://$BUCKET_NAME/
   ```
3. Wait 60 seconds for cache expiration, or create invalidation
4. Refresh browser to see changes

### Updating Streams API Library

1. Rebuild from amazon-connect-streams repository:
   ```bash
   cd /path/to/amazon-connect-streams
   npm run release
   cp release/connect-streams-min.js /path/to/serverless-ccp/
   ```
2. Upload to S3
3. Create CloudFront invalidation for `connect-streams-min.js`

### Destroying Infrastructure

To remove all resources:
```bash
# First, empty S3 bucket
BUCKET_NAME=$(terraform output -raw ccp_s3_bucket_name)
aws s3 rm s3://$BUCKET_NAME --recursive

# Then destroy infrastructure
terraform destroy
```

## Cost Estimate

Approximate monthly costs (low usage):
- **S3 Storage**: $0.023/GB (~$0.02 for 647KB)
- **CloudFront Data Transfer**: $0.085/GB for first 10TB
- **CloudFront Requests**: $0.0075 per 10,000 requests
- **Estimated Total**: < $1/month for typical usage

## Additional Resources

- [Amazon Connect Streams API Documentation](https://github.com/aws/amazon-connect-streams)
- [Amazon Connect Administrator Guide](https://docs.aws.amazon.com/connect/latest/adminguide/)
- [CloudFront Developer Guide](https://docs.aws.amazon.com/cloudfront/latest/DeveloperGuide/)
- [S3 Static Website Hosting](https://docs.aws.amazon.com/AmazonS3/latest/userguide/WebsiteHosting.html)

## Support

For issues with:
- **Streams API**: Check [GitHub Issues](https://github.com/aws/amazon-connect-streams/issues)
- **Amazon Connect**: Contact AWS Support
- **Terraform Modules**: Review module documentation in `terraform/modules/`
- **This Implementation**: Check browser console logs and CloudWatch

## Next Steps

1. Customize agent console branding and styling
2. Add custom contact attributes display
3. Integrate with CRM via contact attributes
4. Implement screen pops based on customer data
5. Add custom call recording controls
6. Integrate with backend APIs for real-time data
