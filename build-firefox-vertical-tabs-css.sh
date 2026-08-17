#!/usr/bin/env zsh
# Build firefox-vertical-tabs.css with embedded data URI for vertical starfield
# Use ::before pseudo-element to prevent tiling

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
cd "${SCRIPT_DIR}"

echo "Generating data URI for starfield-vertical-rotated.gif..."
STARFIELD_VERTICAL_DATA_URI="data:image/gif;base64,$(base64 -i starfield-vertical-rotated.gif)"

cat > firefox-vertical-tabs.css <<EOFINNER
/* Firefox Native Vertical Tabs - Starfield Background (Single Stretched Image) */

/* Make container positioned */
#tabbrowser-arrowscrollbox,
.tabbrowser-arrowscrollbox {
  position: relative !important;
}

/* Use ::before pseudo-element for starfield background */
#tabbrowser-arrowscrollbox::before,
.tabbrowser-arrowscrollbox::before {
  content: "" !important;
  position: absolute !important;
  top: 0 !important;
  left: 0 !important;
  width: 100% !important;
  height: 100% !important;
  background: url("${STARFIELD_VERTICAL_DATA_URI}") center/100% 100% no-repeat !important;
  z-index: -1 !important;
  pointer-events: none !important;
}

/* Ensure tab elements stay on top */
#tabbrowser-arrowscrollbox > *,
.tabbrowser-arrowscrollbox > * {
  position: relative !important;
  z-index: 1 !important;
}
EOFINNER

echo "✅ firefox-vertical-tabs.css generated ($(wc -c < firefox-vertical-tabs.css | tr -d ' ') bytes)"
