{
  # Check these out at about:config
  "zen.welcome-screen.seen" = true;
  "browser.shell.checkDefaultBrowser" = false;

  # HDR
  "gfx.color_management.native_srgb" = true;
  
  #################################
  # Hardening (Security settings) #
  #################################
  # referenced from https://gist.github.com/jolovicdev/82ed0f1667505345dccd69c7678a71ca
  
  # Captive Portal
  "network.captive-portal-service.enabled" = false;
  "captivedetect.canonicalURL" = "";

  # Additional Geolocation Hardening
  "geo.enabled" = false;
  "geo.provider.ms-windows-location" = false;
  "geo.provider.use_corelocation" = false;
  "geo.provider.use_gpsd" = false;
  "geo.provider.use_geoclue" = false;

  # Additional Push Notifications Hardening
  "dom.push.enabled" = false;
  "dom.push.connection.enabled" = false;
  "dom.push.serverURL" = "";

  # Firefox Monitor
  "signon.management.page.breach-alerts.enabled" = false;
  "extensions.fxmonitor.enabled" = false;

  # Safe Browsing
  "browser.safebrowsing.malware.enabled" = false;
  "browser.safebrowsing.phishing.enabled" = false;
  "browser.safebrowsing.blockedURIs.enabled" = false;
  "browser.safebrowsing.provider.google4.gethashURL" = "";
  "browser.safebrowsing.provider.google4.updateURL" = "";
  "browser.safebrowsing.provider.google.gethashURL" = "";
  "browser.safebrowsing.provider.google.updateURL" = "";

  # Prefetching and Predictive Connections
  "network.predictor.enable-prefetch" = false;
  "network.http.referer.disallowCrossSiteRelaxingDefault" = true;

  # Mozilla Sync
  "identity.fxaccounts.enabled" = false;

  # Extension Blocklist Updates
  "extensions.blocklist.enabled" = false;

  # Automatic Updates
  "app.update.auto" = false;
  "app.update.enabled" = false;

  # WebRTC (Prevents IP leaks)
  "media.peerconnection.enabled" = false;
  "media.navigator.enabled" = false;

  # Search Suggestions
  "browser.search.suggest.enabled.private" = false;
  "browser.urlbar.suggest.searches" = false;

  # Location Bar Suggestions
  "browser.urlbar.suggest.quicksuggest.sponsored" = false;
  "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;

  # UI Elements & Quality of Life (Ads, Firefox View, Shopping)
  "browser.vpn_promo.enabled" = false;
  "browser.tabs.firefox-view" = false;
  "browser.shopping.experience2023.enabled" = false;

  ###############################
  # End of referenced hardening #
  # Own General hardening       #
  ###############################

  # Content blocking
  "browser.contentblocking.category" = "strict";

  # Force HTTPS
  "dom.security.https_only_mode" = true;
  "dom.security.https_only_mode_ever_enabled" = true;

  # Clear cookies on shutdown
  "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = true;

  # Battery info can be used for tracking
  "dom.battery.enabled" = false;

  # Enable Multi-Account Containers
  "privacy.userContext.enabled" = true;
  "privacy.userContext.ui.enabled" = true;

  # Enable Total Cookie Protection (Dynamic First-Party Isolation)
  "network.cookie.cookieBehavior" = 5;

  # Enables newer Fingerprinting Protection
  "privacy.fingerprintingProtection" = true;
  "privacy.fingerprintingProtection.pbmode" = true;

  # Disable link prefetching and speculative connections (Without this, just hovering over links can be harmful)
  "network.dns.disablePrefetch" = true;
  "network.dns.disablePrefetchFromHTTPS" = true;
  "network.prefetch-next" = false;
  "network.http.speculative-parallel-limit" = 0;

  # Disable disk cache (forces RAM-only cache)
  "browser.cache.disk.enable" = false;
  "browser.cache.disk_cache_ssl" = false;
  "browser.cache.offline.enable" = false;
}
