# Amazon Connect Custom CCP Integration

This directory contains a custom Contact Control Panel (CCP) integration using the Amazon Connect Streams API.

## Files

- `connect-streams-min.js` - Minified Amazon Connect Streams API library (v2.22.0)
- `ccp-integration.html` - Custom CCP integration page with event logging

## Setup Instructions

### 1. Update Configuration

Open `ccp-integration.html` and update the configuration section (around line 91):

```javascript
const config = {
    // Replace with your Amazon Connect instance URL
    ccpUrl: 'https://YOUR-INSTANCE-NAME.my.connect.aws/ccp-v2',

    // Replace with your instance region
    region: 'us-east-1',  // or your region like 'us-west-2', etc.

    loginPopup: true,

    softphone: {
        allowFramedSoftphone: true,
        disableRingtone: false,
    }
};
```

**To find your CCP URL:**
1. Go to AWS Console > Amazon Connect
2. Click on your instance
3. The URL format is: `https://<instance-alias>.my.connect.aws/ccp-v2`

### 2. Serve the Files

The CCP integration must be served over HTTPS. You have several options:

#### Option A: Use a Local Web Server

```bash
# Using Python 3
cd custom-ccp
python -m http.server 8000

# Using Node.js http-server
npm install -g http-server
http-server -p 8000
```

Then access: `http://localhost:8000/ccp-integration.html`

**Note:** For production, you MUST use HTTPS.

#### Option B: Use AWS S3 + CloudFront (Recommended for Production)

1. Create an S3 bucket
2. Enable static website hosting
3. Upload the files
4. Create a CloudFront distribution with HTTPS
5. Access via CloudFront URL

#### Option C: Deploy to a Web Server

Upload the files to your web server that supports HTTPS.

### 3. Configure Amazon Connect Approved Origins

1. Go to AWS Console > Amazon Connect
2. Click on your instance
3. In the left menu, click "Approved origins"
4. Add your domain:
   - For local testing: `http://localhost:8000` or `http://127.0.0.1:8000`
   - For production: Your HTTPS domain (e.g., `https://your-domain.com`)

**Important:** Without adding your domain to approved origins, the CCP will not load.

### 4. Test the Integration

1. Open `ccp-integration.html` in your browser
2. You should see:
   - The CCP login page in the left panel
   - Event log on the right
3. Log in with your Amazon Connect agent credentials
4. The event log will show:
   - Agent connection
   - State changes
   - Contact events (when calls come in)

## Features

### Agent Events Tracked

- Agent connection/disconnection
- State changes (Available, Offline, ACW, etc.)
- Routable/Not routable status
- After Call Work (ACW) events

### Contact Events Tracked

- New contact detected
- Contact connecting/connected
- Contact accepted by agent
- Contact ended
- ACW started
- Missed contacts

### UI Elements

- **CCP Panel (Left)**: Standard Amazon Connect CCP interface
- **Status Bar**: Shows current agent name and status
- **Event Log**: Real-time log of all events with timestamps

## Customization

### Change CCP Size

In the CSS (line 28-35), modify:

```css
#containerDiv {
    width: 320px;   /* Min: 200px, Max: 320px */
    height: 465px;  /* Normal: 465px, Compact: 400px */
}
```

### Disable Ringtone

```javascript
softphone: {
    disableRingtone: true,
}
```

### Use Custom Ringtone

```javascript
softphone: {
    ringtoneUrl: './custom-ringtone.mp3'
}
```

### Disable Login Popup

```javascript
loginPopup: false,
```

## Troubleshooting

### CCP Not Loading

1. **Check approved origins** - Make sure your domain is added
2. **Verify CCP URL** - Ensure it's correct for your instance
3. **Check browser console** - Look for error messages
4. **HTTPS requirement** - Production must use HTTPS

### Authentication Issues

1. Verify your agent has proper permissions
2. Check if your instance has SAML configured
3. If using SAML, set `loginUrl` in config

### Softphone Issues

1. **Allow microphone/speaker access** in browser
2. **Single window requirement** - Don't open CCP in multiple tabs
3. **Browser compatibility** - Use Chrome, Firefox, or Edge

### No Events Appearing

1. Check browser console for JavaScript errors
2. Verify the streams library is loaded correctly
3. Ensure you're logged in as an agent

## Browser Compatibility

- ✅ Google Chrome (Recommended)
- ✅ Mozilla Firefox
- ✅ Microsoft Edge
- ⚠️ Safari (Limited support)
- ❌ Internet Explorer (Not supported)

## Security Notes

1. **Never expose credentials** in the code
2. **Use HTTPS** in production
3. **Validate approved origins** carefully
4. **Keep streams library updated** regularly

## Additional Resources

- [Amazon Connect Streams Documentation](https://github.com/aws/amazon-connect-streams)
- [Amazon Connect Administrator Guide](https://docs.aws.amazon.com/connect/latest/adminguide/)
- [Streams API Reference](https://github.com/aws/amazon-connect-streams/blob/master/Documentation.md)

## Next Steps

Once you have the basic CCP working:

1. Integrate with your customer application
2. Add custom CTI (Computer Telephony Integration) features
3. Implement screen pops based on contact attributes
4. Add custom contact handling logic
5. Integrate with CRM systems

## Support

For issues with:
- **Streams API**: Check the [GitHub repository](https://github.com/aws/amazon-connect-streams/issues)
- **Amazon Connect**: Contact AWS Support
- **This implementation**: Review the code comments and console logs
