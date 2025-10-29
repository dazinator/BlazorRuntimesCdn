# Blazor Runtime CDN

A GitHub Pages-hosted CDN for Blazor WebAssembly runtime files, enabling applications to load runtime components from a centralized, versioned location.

## 🎯 Purpose

This repository provides a CDN-like distribution mechanism for Blazor WASM runtime files. Instead of bundling runtime files with every Blazor application, you can load them from this centralized location, potentially improving caching and reducing deployment sizes.

## 🚀 Available Runtimes

The following runtime versions are currently available:

- **8.0.0** - .NET 8.0.0
- **9.0.0** - .NET 9.0.0

## 📖 Usage

### Basic Setup

To use the CDN in your Blazor WebAssembly application, modify your `wwwroot/index.html`:

```html
<script src="_framework/blazor.webassembly.js" autostart="false"></script>
<script>
  Blazor.start({
    webAssembly: {
      loadBootResource: function (type, name, defaultUri, integrity) {
        console.log(`Loading: '${type}', '${name}'`);
        
        switch (type) {
          case 'dotnetjs':
          case 'dotnetwasm':
          case 'timezonedata':
            // Load runtime from CDN
            return `https://blazor-runtime.gh.dazinator.net/runtimes/8.0.0/${name}`;
        }
        
        // Load app assemblies from default location
        return defaultUri;
      }
    }
  });
</script>
```

### Resource Types

The `loadBootResource` function handles different resource types:

- **`dotnetjs`** - The main JavaScript runtime
- **`dotnetwasm`** - WebAssembly runtime files
- **`timezonedata`** - Timezone data files
- **`assembly`** - Your application's DLL assemblies (should load from default location)
- **`pdb`** - Debug symbols (should load from default location)
- **`satellite-assembly`** - Localization assemblies (should load from default location)

### Version Selection

Simply change the version number in the CDN URL to use a different runtime:

```javascript
// Use .NET 9.0
return `https://blazor-runtime.gh.dazinator.net/runtimes/9.0.0/${name}`;

// Use .NET 8.0
return `https://blazor-runtime.gh.dazinator.net/runtimes/8.0.0/${name}`;
```

## 🔍 Live Example

A working demonstration is available at:
**[https://blazor-runtime.gh.dazinator.net/example/](https://blazor-runtime.gh.dazinator.net/example/)**

This example loads its runtime files from the CDN while loading application assemblies locally.

## 🛠️ Adding New Runtimes

To add a new runtime version:

1. Edit `runtimes-config.json` in the repository root
2. Add a new runtime entry:

```json
{
  "version": "8.0.1",
  "dotnetVersion": "8.0.1",
  "source": "nuget",
  "enabled": true
}
```

3. Commit and push the changes
4. GitHub Actions will automatically provision the runtime files

### Configuration Fields

- **`version`**: Directory name under `runtimes/` (e.g., "8.0.1")
- **`dotnetVersion`**: Specific .NET SDK version to use (e.g., "8.0.1")
- **`source`**: Currently only `"nuget"` is supported
- **`enabled`**: Set to `true` to provision this runtime, `false` to skip

## 🏗️ How It Works

### Automated Provisioning

The repository uses GitHub Actions to automatically provision runtime files:

1. **Configuration**: `runtimes-config.json` declares which runtimes to maintain
2. **Provisioning Script**: `scripts/provision-runtimes.sh` extracts runtime files from published Blazor projects
3. **GitHub Actions**: Automatically runs on push to `main` branch
4. **GitHub Pages**: Deploys the runtime files and example app

### Workflow Steps

1. **Provision Runtimes**: Creates temporary Blazor projects for each configured runtime version, extracts runtime files
2. **Build Example**: Compiles the example Blazor app
3. **Deploy**: Publishes everything to GitHub Pages

### Anti-Recursion

The workflow prevents infinite loops by:
- Using `[skip ci]` in commit messages
- Only committing when actual changes are detected
- Checking git diff before making commits

## 📁 Repository Structure

```
blazor-runtime-cdn/
├── .github/
│   └── workflows/
│       └── deploy.yml          # GitHub Actions deployment workflow
├── runtimes/                   # Runtime files (auto-generated)
│   ├── 8.0.0/                 # .NET 8.0.0 runtime files
│   │   ├── dotnet.*.js
│   │   ├── dotnet.*.wasm
│   │   └── ...
│   └── 9.0.0/                 # .NET 9.0.0 runtime files
├── example/                    # Demo Blazor WASM app
│   ├── wwwroot/
│   │   ├── index.html         # Custom boot loader example
│   │   └── ...
│   └── ExampleApp.csproj
├── scripts/
│   └── provision-runtimes.sh  # Runtime provisioning script
├── runtimes-config.json        # Runtime configuration
├── CNAME                       # Custom domain configuration
├── .gitignore
└── README.md
```

## 🌐 Custom Domain Setup

This repository is configured to use the custom domain `blazor-runtime.gh.dazinator.net`.

### DNS Configuration

Add a CNAME record in your DNS settings:

```
blazor-runtime.gh  →  [your-github-username].github.io
```

### GitHub Repository Settings

1. Navigate to **Settings** > **Pages**
2. Set custom domain: `blazor-runtime.gh.dazinator.net`
3. Enable "Enforce HTTPS"

## ⚠️ Important Considerations

### CORS Support

GitHub Pages automatically serves files with appropriate CORS headers, allowing them to be loaded from any origin.

### Caching

- Runtime files are immutable for each version
- Consider adding cache-control headers via GitHub Pages configuration
- Each runtime version is isolated in its own directory

### Security

- Always use HTTPS URLs for CDN resources
- Consider implementing integrity checks for production use
- Runtime files are extracted from official .NET SDK releases

### Browser Compatibility

The Blazor runtime requires:
- WebAssembly support
- Modern JavaScript features
- Same browser compatibility as standard Blazor WASM apps

## 🔮 Future Enhancements

Potential improvements for this repository:

- [ ] Add integrity/hash validation for runtime files
- [ ] Support for multiple .NET framework versions simultaneously
- [ ] Automated version discovery from NuGet
- [ ] Usage analytics/logging
- [ ] Caching headers optimization
- [ ] Support for pre-release runtime versions
- [ ] Version selector UI on landing page
- [ ] Automatic cleanup of old runtime versions

## 📝 License

This repository hosts runtime files from the .NET SDK, which are licensed under the MIT License by Microsoft.

## 🤝 Contributing

To contribute:

1. Fork the repository
2. Add your runtime version to `runtimes-config.json`
3. Test the provisioning script locally
4. Submit a pull request

## 📧 Support

For issues or questions:
- Open an issue in this repository
- Check existing issues for similar problems

---

**Note**: This is a proof-of-concept implementation. For production use, consider implementing additional security measures, monitoring, and error handling.

