#!/usr/bin/env zsh
# Build chrome.css with embedded data URIs for both starfield GIF and neutron stars APNG
# Includes BOTH navbar and sidebar styling in one file

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

# Create chrome.css with both navbar and sidebar styling
cat > chrome.css <<EOFINNER
/* =================================================================
   Animated Neutron Stars with Starfield Background for Zen Browser
   ================================================================= */

/* HOW ZEN MODS WORK:
 *
 * When you install a Zen mod, Zen Browser:
 * 1. Copies this entire chrome.css file content VERBATIM into zen-themes.css
 * 2. Does NOT transform paths or handle external file references
 * 3. Stores zen-themes.css in a SHA-based theme folder that changes when mods are added/removed
 *    Example path: ~/Library/Application Support/zen/Profiles/<profile>/chrome/zen-themes/<sha>/zen-themes.css
 *
 * WHY WE USE DATA URIs:
 * - External file references (url("starfield.gif")) would break because:
 *   - Zen copies CSS content but NOT the referenced files
 *   - The SHA-based folder path changes, breaking relative paths
 * - Data URIs embed the entire image as base64 directly in the CSS
 * - This makes chrome.css self-contained (no external dependencies)
 * - Trade-off: Large file size (~14MB) but guaranteed to work
 *
 * TOGGLING THE MOD:
 * - Toggle OFF then ON regenerates zen-themes.css with latest chrome.css content
 * - Restart Zen Browser after toggling to apply changes
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
   SIDEBAR (STARFIELD ONLY - NO NEUTRON STARS)
   ================================================================= */

#navigator-toolbox {
  position: relative !important;
}

/* Sidebar: Starfield (GIF) - Vertical version */
#navigator-toolbox::after {
  content: "";
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: -2 !important;
  pointer-events: none;
  background-image: url("${STARFIELD_VERTICAL_DATA_URI}");
  background-size: cover;
  background-repeat: no-repeat;
  background-position: center;
  opacity: 0.6;
}
EOFINNER

echo "✅ chrome.css generated with navbar (neutron stars + starfield) + sidebar (starfield only) ($(wc -c < chrome.css | tr -d ' ') bytes)"
