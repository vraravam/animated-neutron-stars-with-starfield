#!/usr/bin/env zsh
# Build firefox.css with embedded data URIs for both starfield GIF and neutron stars APNG
# Firefox-specific file (navbar + sidebar with Firefox selectors)

set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="${0:A:h}"
cd "${SCRIPT_DIR}"

# Extract neutron stars APNG data URI from existing chrome.css
echo "Extracting neutron stars APNG data URI from chrome.css..."
if [[ -f chrome.css ]]; then
  NEUTRON_DATA_URI="$(grep -o 'data:image/png;base64,[^"]*' chrome.css | head -1)"
  if [[ -z "${NEUTRON_DATA_URI}" ]]; then
    echo "❌ Error: Could not extract neutron stars APNG data URI from chrome.css"
    exit 1
  fi
else
  echo "❌ Error: chrome.css not found. Cannot extract neutron stars APNG."
  exit 1
fi

# Generate base64 data URI for the horizontal starfield GIF (navbar)
echo "Generating data URI for starfield-horizontal-cropped.gif..."
STARFIELD_HORIZONTAL_DATA_URI="data:image/gif;base64,$(base64 -i starfield-horizontal-cropped.gif)"

# Generate base64 data URI for the vertical starfield GIF (sidebar)
echo "Generating data URI for starfield-vertical-rotated.gif..."
STARFIELD_VERTICAL_DATA_URI="data:image/gif;base64,$(base64 -i starfield-vertical-rotated.gif)"

# Create firefox.css with both navbar and sidebar styling
cat > firefox.css <<EOFINNER
/* =================================================================
   Animated Neutron Stars with Starfield Background for Firefox
   ================================================================= */

/* HOW TO INSTALL IN FIREFOX:
 *
 * 1. Find your Firefox profile directory:
 *    - Go to about:support
 *    - Look for "Profile Directory" → click "Open Directory"
 *
 * 2. Copy this mod folder to <profile-directory>/chrome/:
 *    cp -r animated-neutron-stars-with-starfield <profile-directory>/chrome/
 *
 * 3. Create or edit <profile-directory>/chrome/userChrome.css:
 *    @import url("animated-neutron-stars-with-starfield/firefox.css");
 *
 * 4. Enable custom CSS in Firefox:
 *    - Go to about:config
 *    - Search for: toolkit.legacyUserProfileCustomizations.stylesheets
 *    - Set to: true
 *
 * 5. Restart Firefox
 *
 * WHY DATA URIs:
 * - Firefox's @import only loads CSS content, not referenced image files
 * - Data URIs embed images as base64 directly in CSS (self-contained)
 * - Trade-off: Large file size (~14MB) but guaranteed to work
 */

/* =================================================================
   NAVBAR (TOP BAR)
   ================================================================= */

#nav-bar {
  position: relative !important;
  overflow: hidden !important;
}

/* Ensure all nav-bar children stay on top */
#nav-bar > * {
  position: relative;
  z-index: 10 !important;
}

/* Navbar Layer 1: Starfield (GIF) - Bottom layer, full width */
#nav-bar::after {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -2 !important;
  pointer-events: none;
  background-image: url("${STARFIELD_HORIZONTAL_DATA_URI}");
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center;
  opacity: 0.6;
}

/* Navbar Layer 2: Neutron Stars (APNG) - Middle layer, right-aligned */
#nav-bar::before {
  content: "";
  position: absolute;
  top: 0;
  right: 0;
  width: 526px;
  height: 200px;
  z-index: -1 !important;
  pointer-events: none;
  background-image: url("${NEUTRON_DATA_URI}");
  background-size: contain;
  background-repeat: no-repeat;
  background-position: top right;
}

/* =================================================================
   SIDEBAR (FIREFOX BOOKMARKS/HISTORY - STARFIELD ONLY)
   ================================================================= */

#sidebar-box {
  position: relative !important;
  overflow: hidden !important;
}

/* Ensure sidebar content stays on top */
#sidebar > * {
  position: relative !important;
  z-index: 1 !important;
}

/* Sidebar: Starfield (GIF) - Vertical version - single image, no tiling */
#sidebar-box::before {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -1 !important;
  pointer-events: none;
  background-image: url("${STARFIELD_VERTICAL_DATA_URI}");
  background-size: 100% 100%;
  background-repeat: no-repeat;
  background-position: center center;
  opacity: 0.6;
}
EOFINNER

echo "✅ firefox.css generated with navbar (neutron stars + starfield) + sidebar (starfield only) ($(wc -c < firefox.css | tr -d ' ') bytes)"
