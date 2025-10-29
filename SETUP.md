# Setup Instructions

This document provides step-by-step instructions for completing the GitHub Pages setup for the Blazor Runtime CDN.

## ✅ What's Already Done

The repository now includes:

- **Runtime provisioning system** - Automated script to extract Blazor WASM runtime files
- **GitHub Actions workflow** - Three-job pipeline for provisioning, building, and deploying
- **Example Blazor app** - Working demonstration with custom boot loader
- **Configuration system** - JSON-based runtime version management
- **Documentation** - Comprehensive README with usage examples
- **Runtime files** - .NET 8.0.0 and 9.0.0 runtimes pre-provisioned

## 🔧 Required Setup Steps

### 1. Enable GitHub Pages

1. Go to your repository: `https://github.com/dazinator/BlazorRuntimesCdn`
2. Navigate to **Settings** → **Pages**
3. Under "Build and deployment":
   - **Source**: Select "GitHub Actions"
4. Click **Save**

### 2. Merge Pull Request

Once the pull request is merged to the `main` branch:
- The GitHub Actions workflow will trigger automatically
- It will provision runtimes, build the example app, and deploy to GitHub Pages
- First deployment may take 5-10 minutes

### 3. Configure Custom Domain (Optional)

To use the custom domain `blazor-runtime.gh.dazinator.net`:

#### DNS Configuration
Add a CNAME record in your DNS provider for `dazinator.net`:

```
Record Type: CNAME
Name: blazor-runtime.gh
Value: dazinator.github.io
TTL: 3600 (or automatic)
```

#### GitHub Settings
1. Go to **Settings** → **Pages**
2. Under "Custom domain", enter: `blazor-runtime.gh.dazinator.net`
3. Click **Save**
4. Wait for DNS check to complete (may take a few minutes)
5. Check "Enforce HTTPS" once the DNS check passes

### 4. Verify Deployment

After the workflow completes:

1. **Check workflow status**:
   - Go to **Actions** tab in GitHub
   - Verify all jobs completed successfully
   - Look for: provision-runtimes, build-example, deploy

2. **Test runtime files**:
   ```
   # Without custom domain:
   https://dazinator.github.io/BlazorRuntimesCdn/runtimes/8.0.0/
   https://dazinator.github.io/BlazorRuntimesCdn/runtimes/9.0.0/
   
   # With custom domain (after DNS propagation):
   https://blazor-runtime.gh.dazinator.net/runtimes/8.0.0/
   https://blazor-runtime.gh.dazinator.net/runtimes/9.0.0/
   ```

3. **Test example app**:
   ```
   # Without custom domain:
   https://dazinator.github.io/BlazorRuntimesCdn/example/
   
   # With custom domain:
   https://blazor-runtime.gh.dazinator.net/example/
   ```

4. **Check browser console**:
   - Open the example app
   - Open browser developer tools (F12)
   - Check Console tab for messages like:
     ```
     Loading from CDN: https://blazor-runtime.gh.dazinator.net/runtimes/9.0.0/dotnet.native.xxx.wasm
     ```

## 🔄 Adding New Runtime Versions

To add a new runtime version:

1. Edit `runtimes-config.json`:
   ```json
   {
     "version": "8.0.1",
     "dotnetVersion": "8.0.1",
     "source": "nuget",
     "enabled": true
   }
   ```

2. Commit and push to `main` branch
3. GitHub Actions will automatically provision the new runtime
4. Runtime files will be available at `/runtimes/8.0.1/`

## 🐛 Troubleshooting

### Workflow Fails on First Run

**Issue**: The workflow might fail if GitHub Pages isn't set up yet.

**Solution**: 
1. Set up GitHub Pages (see step 1 above)
2. Re-run the failed workflow from the Actions tab

### DNS Not Resolving

**Issue**: Custom domain not working after DNS configuration.

**Solution**:
1. Wait for DNS propagation (can take up to 24 hours, usually much faster)
2. Check DNS with: `nslookup blazor-runtime.gh.dazinator.net`
3. Verify CNAME points to: `dazinator.github.io`

### Example App Loads But Runtime Fails

**Issue**: Example app shows "Loading..." but doesn't start.

**Solution**:
1. Check browser console for CORS errors
2. Verify runtime files are accessible (try opening URLs directly)
3. Check that HTTPS is enforced in GitHub Pages settings
4. Ensure custom domain DNS is properly configured

### Provisioning Script Fails

**Issue**: Runtime provisioning fails in GitHub Actions.

**Solution**:
1. Check that .NET SDKs are available (8.0.x and 9.0.x)
2. Verify `jq` is installed in the workflow
3. Check workflow logs for specific error messages

## 📊 Monitoring

### Check Deployment Status
```bash
# View workflow runs
https://github.com/dazinator/BlazorRuntimesCdn/actions

# Check Pages deployment
https://github.com/dazinator/BlazorRuntimesCdn/deployments
```

### Verify Runtime Files
```bash
# List runtime files (after deployment)
curl https://blazor-runtime.gh.dazinator.net/runtimes/
```

## 🎯 Success Criteria

You'll know everything is working when:

- [x] Repository structure is created ✓ (Done)
- [x] Provisioning script successfully extracts runtime files ✓ (Done)
- [x] Example app builds successfully ✓ (Done)
- [ ] GitHub Actions workflow runs without errors (Pending first merge)
- [ ] Runtime files are accessible via GitHub Pages (Pending setup)
- [ ] Example app loads and runs (Pending deployment)
- [ ] Custom domain resolves correctly (Pending DNS)
- [ ] HTTPS is enforced (Pending Pages setup)

## 📞 Next Steps

1. **Immediate**: Enable GitHub Pages in repository settings
2. **After merge**: Monitor the first workflow run
3. **Optional**: Configure custom domain DNS
4. **Validation**: Test all endpoints and example app
5. **Documentation**: Add any project-specific notes to README.md

---

**Note**: This is an automated CDN implementation. The first deployment will take longer as GitHub Pages needs to be initialized. Subsequent deployments will be faster.
